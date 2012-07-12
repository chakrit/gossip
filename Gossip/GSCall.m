//
//  GSCall.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import "GSCall.h"
#import "GSCall+Private.h"
#import "GSDispatch.h"
#import "GSIncomingCall.h"
#import "GSOutgoingCall.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSCall {
    pjsua_call_id _callId;
}

@synthesize account = _account;
@synthesize status = _status;

+ (id)outgoingCallToUri:(NSString *)remoteUri fromAccount:(GSAccount *)account {
    GSOutgoingCall *call = [GSOutgoingCall alloc];
    call = [call initWithRemoteUri:remoteUri fromAccount:account];
    
    return call;
}

+ (id)incomingCallWithId:(NSInteger)callId toAccount:(GSAccount *)account {
    GSIncomingCall *call = [GSIncomingCall alloc];
    call = [call initWithCallId:callId toAccount:account];

    return call;
}


- (id)init {
    return [self initWithAccount:nil];
}

- (id)initWithAccount:(GSAccount *)account {
    if (self = [super init]) {
        _account = account;
        _status = GSCallStatusReady;
        _callId = PJSUA_INVALID_ID;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(callStateDidChange:)
                       name:GSSIPCallStateDidChangeNotification
                     object:[GSDispatch class]];
        [center addObserver:self
                   selector:@selector(callMediaStateDidChange:)
                       name:GSSIPCallMediaStateDidChangeNotification
                     object:[GSDispatch class]];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];

    if (_callId != PJSUA_INVALID_ID && pjsua_call_is_active(_callId)) {
        GSLogIfFails(pjsua_call_hangup(self.callId, 0, NULL, NULL));
    }
    
    _account = nil;
}


- (NSInteger)callId {
    // for child overrides only
    return PJSUA_INVALID_ID;
}

- (void)setCallId:(NSInteger)callId {
    [self willChangeValueForKey:@"callId"];
    _callId = callId;
    [self didChangeValueForKey:@"callId"];
}

- (void)setStatus:(GSCallStatus)status {
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
}


- (BOOL)begin {
    // for child overrides only
    return NO;
}

- (BOOL)end {
    // for child overrides only
    return NO;
}


- (void)callStateDidChange:(NSNotification *)notif {
    pjsua_call_id callId = GSNotifGetInt(notif, GSSIPCallIdKey);
    pjsua_acc_id accountId = GSNotifGetInt(notif, GSSIPAccountIdKey);
    if (callId != _callId || accountId != _account.accountId)
        return;
    
    pjsua_call_info callInfo;
    pjsua_call_get_info(_callId, &callInfo);
    
    GSCallStatus callStatus;
    switch (callInfo.state) {
        case PJSIP_INV_STATE_NULL: {
            callStatus = GSCallStatusReady;
        } break;
            
        case PJSIP_INV_STATE_CALLING:
        case PJSIP_INV_STATE_INCOMING: {
            callStatus = GSCallStatusCalling;
        } break;
            
        case PJSIP_INV_STATE_EARLY:
        case PJSIP_INV_STATE_CONNECTING: {
            callStatus = GSCallStatusConnecting;
        } break;
            
        case PJSIP_INV_STATE_CONFIRMED: {
            callStatus = GSCallStatusConnected;
        } break;
            
        case PJSIP_INV_STATE_DISCONNECTED: {
            callStatus = GSCallStatusDisconnected;
        } break;
    }
    
    __block id self_ = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [self_ setStatus:callStatus]; });
}

- (void)callMediaStateDidChange:(NSNotification *)notif {
    pjsua_call_id callId = GSNotifGetInt(notif, GSSIPCallIdKey);
    if (callId != _callId)
        return;
    
    pjsua_call_info callInfo;
    GSReturnIfFails(pjsua_call_get_info(_callId, &callInfo));
    
    pjsua_conf_port_id callPort = pjsua_call_get_conf_port(_callId);
    if (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        GSLogIfFails(pjsua_conf_connect(callPort, 0));
        GSLogIfFails(pjsua_conf_connect(0, callPort));        
        GSLogIfFails(pjsua_conf_adjust_rx_level(callPort, 3.0));
        GSLogIfFails(pjsua_conf_adjust_tx_level(callPort, 3.0));
    }
}

@end
