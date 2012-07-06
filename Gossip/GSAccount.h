//
//  GSAccount.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSAccountConfiguration.h"


typedef enum {
    GSAccountStatusOffline,
    GSAccountStatusInvalid,
    GSAccountStatusConnected,
} GSAccountStatus;


@interface GSAccount : NSObject

@property (nonatomic, readonly) GSAccountStatus status;

- (BOOL)configure:(GSAccountConfiguration *)configuration;

- (BOOL)connect;
- (BOOL)disconnect;

@end
