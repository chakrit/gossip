//
//  GSConfiguration.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSAccountConfiguration.h"


@interface GSConfiguration : NSObject <NSCopying>

@property (nonatomic) NSUInteger logLevel;
@property (nonatomic) NSUInteger consoleLogLevel;

@property (nonatomic) NSUInteger clockRate;
@property (nonatomic) NSUInteger soundClockRate;

@property (nonatomic, strong) GSAccountConfiguration *account;

+ (id)defaultConfiguration;
+ (id)configurationWithConfiguration:(GSConfiguration *)configuration;

@end
