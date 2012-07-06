//
//  GSDispatch.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSDispatch.h"
#import "PJSIP.h"


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
    NSLog(@"DISPATCH: dispatchRegistrationState");
}

+ (void)dispatchIncomingCall:(pjsua_acc_id)accountId
                      callId:(pjsua_call_id)callId
                        data:(pjsip_rx_data *)data {
    NSLog(@"DISPATCH: incoming call...");
}

+ (void)dispatchCallMediaState:(pjsua_call_id)callId {
    NSLog(@"DISPATCH: call media state changed!");
}

+ (void)dispatchCallState:(pjsua_call_id)callId event:(pjsip_event *)e {
    NSLog(@"DISPATCH: call state...");
}

@end


#pragma mark - C event sink

// NOTE: Needs to use dispatch_sync because we do not know the lifetime of the stuff being
//   given to us by PJSIP (e.g. pjsip_rx_data) so we can't be doing async dispatching.

void onRegistrationState(pjsua_acc_id accountId) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [GSDispatch dispatchRegistrationState:accountId];
    });
}

void onIncomingCall(pjsua_acc_id accountId, pjsua_call_id callId, pjsip_rx_data *rdata) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [GSDispatch dispatchIncomingCall:accountId callId:callId data:rdata];
    });
}

void onCallMediaState(pjsua_call_id callId) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [GSDispatch dispatchCallMediaState:callId];
    });
}

void onCallState(pjsua_call_id callId, pjsip_event *e) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        [GSDispatch dispatchCallState:callId event:e];
    });
}
