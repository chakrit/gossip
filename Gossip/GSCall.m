//
//  GSCall.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import "GSCall.h"
#import "PJSIP.h"
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
        _callUri = callUri;
    }
    return self;
}

- (void)dealloc {
    _account = nil;
    _callUri = nil;
    
    if (pjsua_call_is_active(_callId)) {
        pj_status_t status = pjsua_call_hangup(_callId, 0, NULL, NULL);
        LOG_IF_FAILED(status);
    }
    
    _callId = PJSUA_INVALID_ID;
}


- (BOOL)begin {
    pj_str_t callUriStr = [GSPJUtil PJStringWithString:_callUri];
    
    pjsua_call_setting callSetting;
    pjsua_call_setting_default(&callSetting);
    
    pj_status_t status = pjsua_call_make_call(_account.accountId, &callUriStr, &callSetting, NULL, NULL, &_callId);
    RETURN_NO_IF_FAILED(status);
    
    return YES;
}

- (BOOL)end {
    NSAssert(_callId != PJSUA_INVALID_ID, @"Call has not begun yet.");
    
    pj_status_t status = pjsua_call_hangup(_callId, 0, NULL, NULL);
    RETURN_NO_IF_FAILED(status);
    
    _callId = PJSUA_INVALID_ID;
    return YES;
}

@end
