//
//  GSCall.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import <Foundation/Foundation.h>
#import "GSAccount.h"


typedef enum {
    GSCallStatusReady,
    GSCallStatusCalling,
    GSCallStatusConnected,
    GSCallStatusDisconnected,
} GSCallStatus;


// TODO: Video call support?
@interface GSCall : NSObject

@property (nonatomic, unsafe_unretained, readonly) GSAccount *account;

@property (nonatomic, readonly) NSInteger callId;
@property (nonatomic, copy, readonly) NSString *callUri;
@property (nonatomic, readonly) GSCallStatus status;

- (id)initWithCallUri:(NSString *)callUri
          fromAccount:(GSAccount *)account;

- (BOOL)begin;
- (BOOL)end;

@end
