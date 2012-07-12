//
//  GSOutgoingCall.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/12/12.
//

#import "GSOutgoingCall.h"
#import "GSCall+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSOutgoingCall

@synthesize remoteUri = _remoteUri;

- (id)initWithRemoteUri:(NSString *)remoteUri fromAccount:(GSAccount *)account {
    if (self = [super initWithAccount:account]) {
        _remoteUri = [remoteUri copy];
    }
    return self;
}

- (void)dealloc {
    _remoteUri = nil;
}


- (BOOL)begin {
    if (![_remoteUri hasPrefix:@"sip:"])
        _remoteUri = [@"sip:" stringByAppendingString:_remoteUri];
    
    pj_str_t remoteUri = [GSPJUtil PJStringWithString:_remoteUri];
    
    pjsua_call_setting callSetting;
    pjsua_call_setting_default(&callSetting);
    callSetting.aud_cnt = 1;
    callSetting.vid_cnt = 0; // TODO: Video calling support?
    
    pjsua_call_id callId;
    GSReturnNoIfFails(pjsua_call_make_call(self.account.accountId, &remoteUri, &callSetting, NULL, NULL, &callId));
    
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

@end
