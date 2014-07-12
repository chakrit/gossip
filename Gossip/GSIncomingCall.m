//
//  GSIncomingCall.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/12/12.
//

#import "GSIncomingCall.h"
#import "GSCall+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSIncomingCall

- (id)initWithCallId:(int)callId toAccount:(GSAccount *)account {
    if (self = [super initWithAccount:account]) {
        [self setCallId:callId];
    }
    return self;
}


- (BOOL)begin {
    NSAssert(self.callId != PJSUA_INVALID_ID, @"Call has already ended.");
    
    GSReturnNoIfFails(pjsua_call_answer(self.callId, 200, NULL, NULL));
    return YES;
}

- (BOOL)end {
    NSAssert(self.callId != PJSUA_INVALID_ID, @"Call has already ended.");
    
    GSReturnNoIfFails(pjsua_call_hangup(self.callId, 0, NULL, NULL));
    
    [self setStatus:GSCallStatusDisconnected];
    [self setCallId:PJSUA_INVALID_ID];
    return YES;
}

@end
