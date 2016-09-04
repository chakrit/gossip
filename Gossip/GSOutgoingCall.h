//
//  GSOutgoingCall.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/12/12.
//

#import "GSCall.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSOutgoingCall : GSCall

@property (nonatomic, copy, readonly) NSString *remoteURI;

- (instancetype)initWithRemoteURI:(NSString *)remoteURI
                      fromAccount:(GSAccount *)account
                     videoEnabled:(BOOL)videoEnabled
                    customHeaders:(nullable NSDictionary <NSString *, NSString *> *)customHeaders;

@end

NS_ASSUME_NONNULL_END
