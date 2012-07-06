//
//  GSConfiguration.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//


@interface GSConfiguration : NSObject <NSCopying>

@property (nonatomic) NSUInteger logLevel;
@property (nonatomic) NSUInteger consoleLogLevel;

@property (nonatomic) NSUInteger clockRate;
@property (nonatomic) NSUInteger soundClockRate;

+ (id)defaultConfiguration;

@end
