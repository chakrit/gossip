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
    
    // default values (taken form the Siphon project source)
    _logLevel = 2;
    _consoleLogLevel = 2;
    
    _clockRate = 8000;
    _soundClockRate = 8000;
    
    _account = [GSAccountConfiguration defaultConfiguration];
    
    return self;
}

- (void)dealloc {
    _account = nil;
}


- (id)copyWithZone:(NSZone *)zone {
    GSConfiguration *replica = [[[self class] allocWithZone:zone] init];
    
    // TODO: Probably better to do via property lists.
    replica.logLevel = self.logLevel;
    replica.consoleLogLevel = self.consoleLogLevel;
    replica.clockRate = self.clockRate;
    replica.soundClockRate = self.soundClockRate;
    
    replica.account = [self.account copy];
    
    return replica;
}

@end
