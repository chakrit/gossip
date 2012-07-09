//
//  GSDispatch.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSDispatch.h"


void onRegistrationState(pjsua_acc_id accountId);
void onIncomingCall(pjsua_acc_id accountId, pjsua_call_id callId, pjsip_rx_data *rdata);
void onCallMediaState(pjsua_call_id callId);
void onCallState(pjsua_call_id callId, pjsip_event *e);


@implementation GSDispatch

+ (void)configureCallbacksForAgent:(pjsua_config *)uaConfig {
    uaConfig->cb.on_incoming_call = &onIncomingCall;
    uaConfig->cb.on_call_media_state = &onCallMediaState;
    uaConfig->cb.on_call_state = &onCallState;
    uaConfig->cb.on_reg_state = &onRegistrationState;
}


+ (void)dispatchRegistrationState:(pjsua_acc_id)accountId {
    // TODO: May need to implement some form of subscriber filtering
    //   orthogonaly/globally if we're to scale. But right now a few
    //   dictionary lookups on the receiver side probably wouldn't hurt much.
    NSLog(@"Gossip: dispatchRegistrationState(%d)", accountId);
    
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:accountId]
                                       forKey:GSSIPAccountIdKey];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPRegistrationStateDidChangeNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchIncomingCall:(pjsua_acc_id)accountId
                      callId:(pjsua_call_id)callId
                        data:(pjsip_rx_data *)data {
    NSLog(@"Gossip: dispatchIncomingCall(%d, %d)", accountId, callId);
    
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:accountId], GSSIPAccountIdKey,
            [NSNumber numberWithInt:callId], GSSIPCallIdKey,
            [NSValue valueWithPointer:data], GSSIPDataKey,nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPIncomingCallNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchCallMediaState:(pjsua_call_id)callId {
    NSLog(@"Gossip: dispatchCallMediaState(%d)", callId);
    
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:callId]
                                       forKey:GSSIPCallIdKey];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPCallMediaStateDidChangeNotification
                          object:self
                        userInfo:info];
}

+ (void)dispatchCallState:(pjsua_call_id)callId event:(pjsip_event *)e {
    NSLog(@"Gossip: dispatchCallState(%d)", callId);

    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:callId], GSSIPCallIdKey,
            [NSValue valueWithPointer:e], GSSIPDataKey, nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSSIPCallStateDidChangeNotification
                          object:self
                        userInfo:info];
}

@end


#pragma mark - C event sink

// Bridge C-land callbacks to ObjC-land.

// NOTE: Why dispatch_sync() instead of dispatch_async() ?
//   Needs to use dispatch_sync because we do not know the lifetime of the stuff being
//   given to us by PJSIP (e.g. pjsip_rx_data*) so we must process it completely before
//   the method ends.

// NOTE: Why dispatch_get_current_queue() and not dispatch_get_main_queue() ?
//   These almost alway gets called from a PJSIP-owned thread (not the main thread.)
//   And that most pjsua calls will expects this to be true as well so we can't dispatch
//   cross thread boundary immediately. This should be done at the notification receiver
//   end once all processing is complete (to avoid any weird PJSIP cross-thread errors.)
//   For example, pjsua_acc_get_info when used on the wrong thread in onRegistrationState
//   change callback will cause the calling method to exit abrubtly without even returning
//   any error value.

static inline void dispatch(dispatch_block_t block) {
    dispatch_sync(dispatch_get_current_queue(), block);
}


void onRegistrationState(pjsua_acc_id accountId) {
    dispatch(^{ [GSDispatch dispatchRegistrationState:accountId]; });
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
