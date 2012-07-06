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


+ (id)defaultConfiguration {
    return [[GSConfiguration alloc] init];
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


- (id)copyWithZone:(NSZone *)zone {
    GSConfiguration *replica = [[[self class] allocWithZone:zone] init];
    
    // TODO: simpler/better way?
    replica.logLevel = self.logLevel;
    replica.consoleLogLevel = self.consoleLogLevel;
    replica.clockRate = self.clockRate;
    replica.soundClockRate = self.soundClockRate;
    
    return replica;
}

@end
