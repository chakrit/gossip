//
//  GSAccount.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import <Foundation/Foundation.h>
#import "GSAccountConfiguration.h"
@class GSAccount, GSCall;


typedef enum {
    GSAccountStatusOffline,
    GSAccountStatusInvalid,
    GSAccountStatusConnecting,
    GSAccountStatusConnected,
    GSAccountStatusDisconnecting,
} GSAccountStatus;


@protocol GSAccountDelegate <NSObject>

- (void)account:(GSAccount *)account didReceiveIncomingCall:(GSCall *)call;

@end


@interface GSAccount : NSObject

@property (nonatomic, readonly) NSInteger accountId;
@property (nonatomic, readonly) GSAccountStatus status;

@property (nonatomic, unsafe_unretained) id<GSAccountDelegate> delegate;

- (BOOL)configure:(GSAccountConfiguration *)configuration;

- (BOOL)connect;
- (BOOL)disconnect;

@end
