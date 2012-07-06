//
//  GSConfiguration.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//


@interface GSConfiguration : NSObject <NSCopying>

@property (nonatomic) NSUInteger logLevel;
@property (nonatomic) NSUInteger consoleLogLevel;

@property (nonatomic) NSUInteger clockRate;
@property (nonatomic) NSUInteger soundClockRate;

// TODO: Separate class?
//   Since if we're gonna support more SIP stuff in the future we're gonna need more
//   authentication options
@property (nonatomic, copy) NSString *sipAddress;
@property (nonatomic, copy) NSString *sipDomain;
@property (nonatomic, copy) NSString *sipProxyServer;
@property (nonatomic, copy) NSString *sipAuthScheme;
@property (nonatomic, copy) NSString *sipAuthRealm;
@property (nonatomic, copy) NSString *sipUsername;
@property (nonatomic, copy) NSString *sipPassword;

+ (id)defaultConfiguration;
+ (id)configurationWithConfiguration:(GSConfiguration *)configuration;

@end
