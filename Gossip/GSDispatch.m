//
//  GSDispatch.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSDispatch.h"
#import "GSPJUtil.h"

#import <pjsip/sip_transaction.h>
#import <pjsip/sip_parser.h>
#import <pjsip/sip_event.h>
#import "RFC3326ReasonParser.h"

void onRegistrationStarted(pjsua_acc_id accountId, pjsua_reg_info *info);
void onRegistrationState(pjsua_acc_id accountId, pjsua_reg_info *info);
void onIncomingCall(pjsua_acc_id accountId, pjsua_call_id callId, pjsip_rx_data *rdata);
void onCallMediaState(pjsua_call_id callId);
void onCallState(pjsua_call_id callId, pjsip_event *e);
void onCallMediaEvent(pjsua_call_id call_id, unsigned med_idx, pjmedia_event *event);
void onTransportState(pjsip_transport *tp, pjsip_transport_state state, const pjsip_transport_state_info *info);
void onSTUNResolutionComplete(const pj_stun_resolve_result *result);
void onNATDetection(const pj_stun_nat_detect_result *result);
void onCallTSXState(pjsua_call_id call_id, pjsip_transaction *tsx, pjsip_event *e);

static dispatch_queue_t _queue = NULL;

@implementation GSDispatch

+ (void)initialize {
    _queue = dispatch_queue_create("GSDispatch", DISPATCH_QUEUE_SERIAL);    
}

+ (void)configureCallbacksForAgent:(pjsua_config *)uaConfig {
    uaConfig->cb.on_reg_started2 = &onRegistrationStarted;
    uaConfig->cb.on_reg_state2 = &onRegistrationState;
    uaConfig->cb.on_incoming_call = &onIncomingCall;
    uaConfig->cb.on_call_media_state = &onCallMediaState;
    uaConfig->cb.on_call_state = &onCallState;
    uaConfig->cb.on_call_media_event = &onCallMediaEvent;
    uaConfig->cb.on_transport_state = &onTransportState;
    uaConfig->cb.on_stun_resolution_complete = &onSTUNResolutionComplete;
    uaConfig->cb.on_nat_detect = &onNATDetection;
    uaConfig->cb.on_call_tsx_state = &onCallTSXState;
}

#pragma mark - Dispatch sink

// TODO: May need to implement some form of subscriber filtering
//   orthogonaly/globally if we're to scale. But right now a few
//   dictionary lookups on the receiver side probably wouldn't hurt much.

+ (void)dispatchRegistrationStarted:(pjsua_acc_id)accountId info:(pjsua_reg_info *)info {
    //    PJ_LOG(3, (__FILENAME__, "dispatchRegistrationStarted(%d, %d)", accountId, info->renew));
    
    NSDictionary *userInfo = @{GSSIPAccountIdKey: @(accountId),
                               GSSIPRenewKey: @(info->renew),
                               GSSIPDataKey:[NSValue valueWithPointer:info]};
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPRegistrationDidStartNotification
                          object:self
                        userInfo:userInfo];
}

+ (void)dispatchRegistrationState:(pjsua_acc_id)accountId info:(pjsua_reg_info *)info {
    //    PJ_LOG(3, (__FILENAME__, "dispatchRegistrationState(%d)", accountId));
    
    NSDictionary *userInfo = @{GSSIPAccountIdKey: @(accountId),
                               GSSIPDataKey:[NSValue valueWithPointer:info]};
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPRegistrationStateDidChangeNotification
                          object:self
                        userInfo:userInfo];
}

+ (void)dispatchIncomingCall:(pjsua_acc_id)accountId
                      callId:(pjsua_call_id)callId
                        data:(pjsip_rx_data *)data {
    //    PJ_LOG(3, (__FILENAME__, "dispatchIncomingCall(%d, %d)", accountId, callId));
    
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:accountId], GSSIPAccountIdKey,
            [NSNumber numberWithInt:callId], GSSIPCallIdKey,
            [NSValue valueWithPointer:data], GSSIPDataKey, nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPIncomingCallNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchCallMediaState:(pjsua_call_id)callId {
    //    PJ_LOG(3, (__FILENAME__, "dispatchCallMediaState(%d)", callId));
    
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:callId]
                                       forKey:GSSIPCallIdKey];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPCallMediaStateDidChangeNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchCallState:(pjsua_call_id)callId event:(pjsip_event *)e {
    //    PJ_LOG(3, (__FILENAME__, "dispatchCallState(%d)", callId));
    
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:callId], GSSIPCallIdKey,
            [NSValue valueWithPointer:e], GSSIPDataKey, nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPCallStateDidChangeNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchCallMediaEvent:(pjsua_call_id)callId
                       mediaId:(unsigned)mediaId
                         event:(pjmedia_event *)e {
    //    PJ_LOG(3, (__FILENAME__, "dispatchCallMediaEvent(%d)", callId));
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:callId], GSSIPCallIdKey,
            [NSNumber numberWithUnsignedInt:mediaId], GSSIPMediaIdKey,
            [NSValue valueWithPointer:e], GSSIPDataKey, nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPCallMediaEventNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchTransportStateChanged:(pjsip_transport *)tp
                                state:(pjsip_transport_state)state
                                 info:(const pjsip_transport_state_info *)info {
    NSDictionary *userInfo = @{GSSIPTransportStateKey: @(state),
                               GSSIPTransportStateInfoKey: [NSValue valueWithPointer:info],
                               GSSIPTransportKey: [NSValue valueWithPointer:tp]};
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPTransportStateDidChangeNotification
                          object:self
                        userInfo:userInfo];
}

+ (void)dispatchSTUNResolutionComplete:(const pj_stun_resolve_result *)result {
    NSDictionary *info = @{GSSIPDataKey: [NSValue valueWithPointer:result]};
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPSTUNResolutionCompleteNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchNATDetected:(const pj_stun_nat_detect_result *)result {
    NSDictionary *info = @{GSSIPDataKey: [NSValue valueWithPointer:result]};
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPNATDetectedNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchParsedCancelReasonHeader:(pjsip_reason_hdr *)header
                               forCallID:(pjsua_call_id)callID {
    NSDictionary *info = @{GSSIPCallIdKey: @(callID),
                           GSSIPDataKey: [NSValue valueWithPointer:header]};
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPParsedCancelReasonHeaderNotification
                          object:self
                        userInfo:info];
}

@end


#pragma mark - C event bridge

// Bridge C-land callbacks to ObjC-land.

static inline void dispatch(dispatch_block_t block) {    
    // autorelease here since events wouldn't be triggered that often.
    // + GCD autorelease pool do not have drainage time guarantee (== possible mem headaches).
    // See the "Implementing tasks using blocks" section for more info
    // REF: http://developer.apple.com/library/ios/#documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html
    @autoreleasepool {
        
        // NOTE: Needs to use dispatch_sync() instead of dispatch_async() because we do not know
        //   the lifetime of the stuff being given to us by PJSIP (e.g. pjsip_rx_data*) so we
        //   must process it completely before the method ends.
        dispatch_sync(_queue, block);
    }
}

void onRegistrationStarted(pjsua_acc_id accountId, pjsua_reg_info *info) {
    dispatch(^{ [GSDispatch dispatchRegistrationStarted:accountId info:info]; });
}

void onRegistrationState(pjsua_acc_id accountId, pjsua_reg_info *info) {
    dispatch(^{ [GSDispatch dispatchRegistrationState:accountId info:info]; });
}

void onIncomingCall(pjsua_acc_id accountId, pjsua_call_id callId, pjsip_rx_data *rdata) {
    dispatch(^{ [GSDispatch dispatchIncomingCall:accountId callId:callId data:rdata]; });
}

void onCallMediaState(pjsua_call_id callId) {
    dispatch(^{ [GSDispatch dispatchCallMediaState:callId]; });
}

void onCallState(pjsua_call_id callId, pjsip_event *e) {
    dispatch(^{ [GSDispatch dispatchCallState:callId event:e]; });
}

void onCallMediaEvent(pjsua_call_id callId, unsigned med_idx, pjmedia_event *e) {
    dispatch(^{ [GSDispatch dispatchCallMediaEvent:callId mediaId:med_idx event:e]; });
}

void onTransportState(pjsip_transport *tp, pjsip_transport_state state, const pjsip_transport_state_info *info) {
    dispatch(^{ [GSDispatch dispatchTransportStateChanged:tp state:state info:info]; });
}

void onSTUNResolutionComplete(const pj_stun_resolve_result *result) {
    dispatch(^{ [GSDispatch dispatchSTUNResolutionComplete:result]; });
}

void onNATDetection(const pj_stun_nat_detect_result *result) {
    dispatch(^{ [GSDispatch dispatchNATDetected:result]; });
}

void onCallTSXState(pjsua_call_id call_id, pjsip_transaction *tsx, pjsip_event *e) {
    if (tsx->method.id == PJSIP_CANCEL_METHOD) {
        char *needle;
        if (asprintf(&needle, "%s%s", pjsip_reason_header_name.ptr, ": ") != -1 && needle != NULL) {
            char *position = strstr(e->body.rx_msg.rdata->pkt_info.packet, needle);
            
            if (position != NULL && position != e->body.rx_msg.rdata->pkt_info.packet) {
                position += strlen(needle);
                
                pj_pool_t *pool = pjsua_pool_create("GSDispatch.onCallTSXState", 1000, 1000);
                if (pool == NULL) {
                    PJ_LOG(3, ("GSDispatch.onCallTSXState", "Could not create pool to parse reason header"));
                    return;
                }
                
                pj_str_t headerReason = pj_str(position);
                pjsip_reason_hdr *reasonHeader = pjsip_parse_hdr(pool, &pjsip_reason_header_name, headerReason.ptr, headerReason.slen, NULL);
                
                if (reasonHeader != NULL) {
                    dispatch(^{ [GSDispatch dispatchParsedCancelReasonHeader:reasonHeader
                                                                   forCallID:call_id]; });
                } else {
                    PJ_LOG(3, ("GSDispatch.onCallTSXState", "Could not parse reason header"));
                }
                
                pj_pool_release(pool);
            }
        }
    }
}
