//
//  GSConfiguration.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSConfiguration.h"


@implementation GSConfiguration

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
    
    // match clock rate to default number provided by PJSIP.
    // http://www.pjsip.org/pjsip/docs/html/structpjsua__media__config.htm#a24792c277d6c6c309eccda9047f641a5
    // setting sound clock rate to zero makes it use the conference bridge rate
    // http://www.pjsip.org/pjsip/docs/html/structpjsua__media__config.htm#aeb0fbbdf83b12a29903509adf16ccb3b
    _clockRate = 16000;
    _soundClockRate = 0;
    
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
