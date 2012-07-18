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

@synthesize transportType = _transportType;

@synthesize clockRate = _clockRate;
@synthesize soundClockRate = _soundClockRate;
@synthesize volumeScale = _volumeScale;

@synthesize account = _account;


+ (id)defaultConfiguration {
    return [[GSConfiguration alloc] init];
}

+ (id)configurationWithConfiguration:(GSConfiguration *)configuration {
    return [configuration copy];
}


- (id)init {
    if (!(self = [super init]))
        return nil; // init failed.

    // default values
    _logLevel = 2;
    _consoleLogLevel = 2;
    
    _transportType = GSUDPTransportType;
    
    // clock rates taken from Siphon project, not sure why 8k
    // maybe better to read the default from the codecs
    _clockRate = 8000;
    _soundClockRate = 8000;
    
    // default volume scale to 2.0 so 1.0 is twice as loud as PJSIP would normally emit.
    _volumeScale = 2.0;
    
    _account = [GSAccountConfiguration defaultConfiguration];
    return self;
}

- (void)dealloc {
    _account = nil;
}


- (id)copyWithZone:(NSZone *)zone {
    GSConfiguration *replica = [[[self class] allocWithZone:zone] init];
    
    // TODO: Probably better to do via class_copyPropertyList.
    replica.logLevel = self.logLevel;
    replica.consoleLogLevel = self.consoleLogLevel;
    replica.transportType = self.transportType;
    replica.clockRate = self.clockRate;
    replica.soundClockRate = self.soundClockRate;
    replica.volumeScale = self.volumeScale;
    
    replica.account = [self.account copy];
    
    return replica;
}

@end
