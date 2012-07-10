//
//  GSAccount.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import <Foundation/Foundation.h>
#import "GSAccountConfiguration.h"


typedef enum {
    GSAccountStatusOffline,
    GSAccountStatusInvalid,
    GSAccountStatusConnecting,
    GSAccountStatusConnected,
    GSAccountStatusDisconnecting,
} GSAccountStatus;


@interface GSAccount : NSObject

@property (nonatomic, readonly) NSInteger accountId;
@property (nonatomic, readonly) GSAccountStatus status;

- (BOOL)configure:(GSAccountConfiguration *)configuration;

- (BOOL)connect;
- (BOOL)disconnect;

@end
