//
//  GSAccountConfiguration.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSAccountConfiguration.h"

@implementation GSAccountConfiguration

+ (instancetype)defaultConfiguration {
    return [[self alloc] init];
}

+ (instancetype)configurationWithConfiguration:(GSAccountConfiguration *)configuration {
    return [configuration copy];
}

- (id)init {
    self = [super init];
    
    if (self) {
        _authScheme = @"digest";
        _authRealm = @"*";
        
        _enableRingback = YES;
        _ringbackFilename = @"ringtone.wav";
        _TURNTransportType = PJ_TURN_TP_UDP;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    GSAccountConfiguration *replica = [GSAccountConfiguration defaultConfiguration];
    
    replica.address = self.address;
    replica.registrar = self.registrar;
    replica.proxyServer = self.proxyServer;
    replica.authScheme = self.authScheme;
    replica.authRealm = self.authRealm;
    replica.username = self.username;
    replica.password = self.password;
    replica.TURNServer = self.TURNServer;
    replica.TURNTransportType = self.TURNTransportType;
    replica.TURNUsername = self.TURNUsername;
    replica.TURNCredential = self.TURNCredential;

    replica.enableStatusPublishing = self.enableStatusPublishing;
    
    replica.enableRingback = self.enableRingback;
    replica.ringbackFilename = self.ringbackFilename;
    
    replica.autoShowIncomingVideo = self.autoShowIncomingVideo;
    replica.autoTransmitOutgoingVideo = self.autoTransmitOutgoingVideo;
    
    return replica;
}

@end
