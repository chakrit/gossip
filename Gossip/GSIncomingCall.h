//
//  GSIncomingCall.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/12/12.
//

@import Foundation;

#import "GSCall.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSIncomingCall : GSCall

- (instancetype)initWithCallId:(pjsua_call_id)callId
                        invite:(pjsip_rx_data *)invite
                     toAccount:(GSAccount *)account;

@end

NS_ASSUME_NONNULL_END
