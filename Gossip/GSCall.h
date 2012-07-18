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
    GSCallStatusConnecting,
    GSCallStatusConnected,
    GSCallStatusDisconnected,
} GSCallStatus;


// TODO: Video call support?
@interface GSCall : NSObject

@property (nonatomic, unsafe_unretained, readonly) GSAccount *account;

@property (nonatomic, readonly) NSInteger callId;
@property (nonatomic, readonly) GSCallStatus status;

@property (nonatomic, readonly) float volume;
@property (nonatomic, readonly) float micVolume;

+ (id)outgoingCallToUri:(NSString *)remoteUri fromAccount:(GSAccount *)account;
+ (id)incomingCallWithId:(NSInteger)callId toAccount:(GSAccount *)account;

- (id)initWithAccount:(GSAccount *)account;

- (BOOL)setVolume:(float)volume;
- (BOOL)setMicVolume:(float)volume;

- (BOOL)begin;
- (BOOL)end;

@end
