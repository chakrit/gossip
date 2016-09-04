//
//  GSOutgoingCall.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/12/12.
//

#import "GSOutgoingCall.h"

#import "GSAccount.h"
#import "GSCall+Private.h"
#import "PJSIP.h"
#import "Util.h"

@implementation GSOutgoingCall {
    BOOL _enableVideoTransmissionInCallSetting;
    NSDictionary *_customHeaders;
}

- (instancetype)initWithRemoteURI:(NSString *)remoteURI
                      fromAccount:(GSAccount *)account
                     videoEnabled:(BOOL)videoEnabled
                    customHeaders:(nullable NSDictionary *)customHeaders
{
    self = [super initWithAccount:account];
    if (self) {
        _remoteURI = [remoteURI copy];
        _enableVideoTransmissionInCallSetting = videoEnabled;
        _customHeaders = customHeaders;
    }
    return self;
}

- (BOOL)isVideoEnabled {
    if (self.callId == PJSUA_INVALID_ID) {
        return _enableVideoTransmissionInCallSetting;
    }
    
    return [super isVideoEnabled];
}

- (NSString *)remoteInfo {
    if (self.callId == PJSUA_INVALID_ID) {
        return _remoteURI;
    }
    
    return [super remoteInfo];
}

- (BOOL)begin {
    NSAssert([NSThread isMainThread], @"We must be called on the main thread");
    
    pj_str_t remoteUri = [GSPJUtil PJStringWithString:_remoteURI];
    
    pjsua_call_setting callSetting;
    pjsua_call_setting_default(&callSetting);
    
    callSetting.aud_cnt = 1;
    callSetting.vid_cnt = (_enableVideoTransmissionInCallSetting == YES) ? 1 : 0;
    
    pjsua_call_id callId;
    
    if (_customHeaders.count > 0) {
        pj_pool_t *pool;
        pjsua_msg_data msg_data;
        pjsua_msg_data_init(&msg_data);
        pj_caching_pool cp;
        
        pj_caching_pool_init(&cp, &pj_pool_factory_default_policy, 0);
        pool= pj_pool_create(&cp.factory, "header", 1000, 1000, NULL);
        
        for (NSString *key in [_customHeaders allKeys]) {
//            PJ_LOG(3, (__FILENAME__, "Setting custom header in call: '%s: %s'", key.UTF8String, ((NSString *)[_customHeaders objectForKey:key]).UTF8String));
            pj_str_t hname = pj_str((char *)[key UTF8String]);
            char *headerValue = (char *)[(NSString *)[_customHeaders objectForKey:key] UTF8String];
            pj_str_t hvalue = pj_str(headerValue);
            pjsip_generic_string_hdr *add_hdr = pjsip_generic_string_hdr_create(pool, &hname, &hvalue);
            pj_list_push_back(&msg_data.hdr_list, add_hdr);
        }
        GSReturnNoIfFails(pjsua_call_make_call(self.account.accountId, &remoteUri, &callSetting, NULL, &msg_data, &callId));
    } else {
        GSReturnNoIfFails(pjsua_call_make_call(self.account.accountId, &remoteUri, &callSetting, NULL, NULL, &callId));
    }
    
    [self setCallId:callId];
    return YES;
}

- (BOOL)end {
    NSAssert(self.callId != PJSUA_INVALID_ID, @"Call has not begun yet.");
    GSReturnNoIfFails(pjsua_call_hangup(self.callId, 0, NULL, NULL));
    
    [self setStatus:GSCallStatusDisconnected];
    [self setCallId:PJSUA_INVALID_ID];
    return YES;
}

- (BOOL)answerWithCode:(unsigned)code {
    NSAssert(self.callId != PJSUA_INVALID_ID, @"Call has not begun yet.");
    GSReturnNoIfFails(pjsua_call_answer(self.callId, code, NULL, NULL));
    return YES;
}

@end
