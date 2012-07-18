//
//  GSAccountConfiguration.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import <Foundation/Foundation.h>


/// Account configuration. Only supports "digest" and plain-text password authentication atm.
@interface GSAccountConfiguration : NSObject <NSCopying>

@property (nonatomic, copy) NSString *address; ///< SIP address.
@property (nonatomic, copy) NSString *domain; ///< SIP domain.
@property (nonatomic, copy) NSString *proxyServer; ///< SIP outbound proxy server.
@property (nonatomic, copy) NSString *authScheme; ///< Authentication scheme. Defaults to "digest".
@property (nonatomic, copy) NSString *authRealm; ///< Authentication realm. Defaults to "*".
@property (nonatomic, copy) NSString *username; ///< SIP username.
@property (nonatomic, copy) NSString *password; ///< SIP password.

+ (id)defaultConfiguration; ///< Creates a GSAccountConfiguration instance with default configuration values.
+ (id)configurationWithConfiguration:(GSAccountConfiguration *)configuration; ///< Copy constructor.

@end
