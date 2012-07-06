//
//  GSAccount.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//


typedef enum {
    GSAccountStatusOffline,
    GSAccountStatusInvalid,
    GSAccountStatusConnected,
} GSAccountStatus;


@interface GSAccount : NSObject

@property (nonatomic, readonly) GSAccountStatus status;

@end
