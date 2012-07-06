//
//  GSConfiguration.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSConfiguration.h"


@implementation GSConfiguration

@synthesize logLevel = _logLevel;
@synthesize consoleLogLevel = _consoleLogLevel;

@synthesize clockRate = _clockRate;
@synthesize soundClockRate = _soundClockRate;

@synthesize sipAddress = _sipAddress;
@synthesize sipDomain = _sipDomain;
@synthesize sipProxyServer = _sipProxyServer;
@synthesize sipAuthScheme = _sipAuthScheme;
@synthesize sipAuthRealm = _sipAuthRealm;
@synthesize sipUsername = _sipUsername;
@synthesize sipPassword = _sipPassword;


+ (id)defaultConfiguration {
    return [[GSConfiguration alloc] init];
}

+ (id)configurationWithConfiguration:(GSConfiguration *)configuration {
    return [configuration copy];
}


- (id)init {
    if (!(self = [super init]))
        return nil; // init failed.
    
    // default values (taken form the Siphon project source)
    _logLevel = 3;
    _consoleLogLevel = 3;
    
    _clockRate = 8000;
    _soundClockRate = 8000;
    
    return self;
}

- (void)dealloc {
    _sipAddress = nil;
    _sipDomain = nil;
    _sipProxyServer = nil;
    _sipAuthScheme = nil;
    _sipAuthRealm = nil;
    _sipUsername = nil;
    _sipPassword = nil;
}


- (id)copyWithZone:(NSZone *)zone {
    GSConfiguration *replica = [[[self class] allocWithZone:zone] init];
    
    // TODO: Probably better to do via property lists.
    replica.logLevel = self.logLevel;
    replica.consoleLogLevel = self.consoleLogLevel;
    replica.clockRate = self.clockRate;
    replica.soundClockRate = self.soundClockRate;
    
    replica.sipAddress = self.sipAddress;
    replica.sipDomain = self.sipDomain;
    replica.sipProxyServer = self.sipProxyServer;
    replica.sipAuthScheme = self.sipAuthScheme;
    replica.sipUsername = self.sipUsername;
    replica.sipPassword = self.sipPassword;
    
    return replica;
}

@end
