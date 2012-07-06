//
//  GSAccountConfiguration.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSAccountConfiguration.h"


@implementation GSAccountConfiguration

@synthesize address = _address;
@synthesize domain = _domain;
@synthesize proxyServer = _proxyServer;
@synthesize authScheme = _authScheme;
@synthesize authRealm = _authRealm;
@synthesize username = _username;
@synthesize password = _password;

+ (id)defaultConfiguration {
    return [[self alloc] init];
}

+ (id)configurationWithConfiguration:(GSAccountConfiguration *)configuration {
    return [configuration copy];
}


- (id)init {
    if (!(self = [super init]))
        return nil; // super init failed.
    
    _address = nil;
    _domain = nil;
    _proxyServer = nil;
    _authScheme = nil;
    _authRealm = nil;
    _username = nil;
    _password = nil;
    return self;
}

- (void)dealloc {
    _address = nil;
    _domain = nil;
    _proxyServer = nil;
    _authScheme = nil;
    _authRealm = nil;
    _username = nil;
    _password = nil;
}


- (id)copyWithZone:(NSZone *)zone {
    GSAccountConfiguration *replica = [GSAccountConfiguration defaultConfiguration];
    
    replica.address = self.address;
    replica.domain = self.domain;
    replica.proxyServer = self.proxyServer;
    replica.authScheme = self.authScheme;
    replica.authRealm = self.authRealm;
    replica.username = self.username;
    replica.password = self.password;
    
    return replica;
}

@end
