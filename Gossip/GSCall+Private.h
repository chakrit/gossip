//
//  GSCall+Private.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/12/12.
//

#import "GSCall.h"

@interface GSCall (Private)

@property (nonatomic, nullable, readwrite) NSDictionary <NSString *, NSString *> *inviteHeaders;

// private setter for internal use
- (void)setCallId:(pjsua_call_id)callId;
- (void)setStatus:(GSCallStatus)status;

@end
