//
//  GSCall.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import "GSCall.h"
#import "PJSIP.h"
#import "GSDispatch.h"
#import "Util.h"


@implementation GSCall

@synthesize account = _account;

@synthesize callId = _callId;
@synthesize callUri = _callUri;
@synthesize status = _status;


- (id)init {
    NSAssert(NO, @"Must use initWithCallUri:fromAccount:");
    return nil;
}

- (id)initWithCallUri:(NSString *)callUri fromAccount:(GSAccount *)account {
    if (self = [super init]) {
        _account = account;
        _callId = PJSUA_INVALID_ID;
        _status = GSCallStatusReady;
        _callUri = [callUri copy];
        
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
    
    _account = nil;
    _callUri = nil;
    
    if (pjsua_call_is_active(_callId)) {
        pj_status_t status = pjsua_call_hangup(_callId, 0, NULL, NULL);
        LOG_IF_FAILED(status);
    }
    
    _callId = PJSUA_INVALID_ID;
}


- (BOOL)begin {
    if (![_callUri hasPrefix:@"sip:"])
        _callUri = [@"sip:" stringByAppendingString:_callUri];
    
    pj_str_t callUriStr = [GSPJUtil PJStringWithString:_callUri];
    
    pjsua_call_setting callSetting;
    pjsua_call_setting_default(&callSetting);
    callSetting.aud_cnt = 1;
    callSetting.vid_cnt = 0; // TODO: Video calling support?
    
    pj_status_t status = pjsua_call_make_call(_account.accountId, &callUriStr, &callSetting, NULL, NULL, &_callId);
    RETURN_NO_IF_FAILED(status);
    
    return YES;
}

- (BOOL)end {
    NSAssert(_callId != PJSUA_INVALID_ID, @"Call has not begun yet.");
    
    pj_status_t status = pjsua_call_hangup(_callId, 0, NULL, NULL);
    RETURN_NO_IF_FAILED(status);
    
    [self willChangeValueForKey:@"status"];
    _status = GSCallStatusDisconnected;
    [self didChangeValueForKey:@"status"];
    
    _callId = PJSUA_INVALID_ID;
    return YES;
}


- (void)callStateDidChange:(NSNotification *)notif {
    NSDictionary *info = [notif userInfo];
    pjsua_call_id callId = [[info objectForKey:GSSIPCallIdKey] intValue];
    pjsua_acc_id accountId = [[info objectForKey:GSSIPAccountIdKey] intValue];    
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
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self willChangeValueForKey:@"status"];
        _status = callStatus;
        [self didChangeValueForKey:@"status"];
    });        
}

- (void)callMediaStateDidChange:(NSNotification *)notif {
    pjsua_call_id callId = [[[notif userInfo] objectForKey:GSSIPCallIdKey] intValue];
    if (callId != _callId)
        return;
    
    pjsua_call_info callInfo;
    pjsua_call_get_info(_callId, &callInfo);
    pjsua_conf_port_id callPort = pjsua_call_get_conf_port(_callId);
    
    if (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        pjsua_conf_connect(callPort, 0);
        pjsua_conf_connect(0, callPort);
        
        pjsua_conf_adjust_rx_level(callPort, 3.0);
        pjsua_conf_adjust_tx_level(callPort, 3.0);
    }
}

@end
