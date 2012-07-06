//
//  GSAccountConfiguration.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//


@interface GSAccountConfiguration : NSObject <NSCopying>

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *proxyServer;
@property (nonatomic, copy) NSString *authScheme;
@property (nonatomic, copy) NSString *authRealm;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

+ (id)defaultConfiguration;
+ (id)configurationWithConfiguration:(GSAccountConfiguration *)configuration;

@end
