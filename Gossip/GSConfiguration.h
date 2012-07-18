//
//  GSConfiguration.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import <Foundation/Foundation.h>
#import "GSAccountConfiguration.h"


typedef enum {
    GSUDPTransportType,
    GSUDP6TransportType,
    GSTCPTransportType,
    GSTCP6TransportType,
} GSTransportType;


@interface GSConfiguration : NSObject <NSCopying>

@property (nonatomic) NSUInteger logLevel;
@property (nonatomic) NSUInteger consoleLogLevel;

@property (nonatomic) GSTransportType transportType;

@property (nonatomic) NSUInteger clockRate;
@property (nonatomic) NSUInteger soundClockRate;
@property (nonatomic) float volumeScale;

@property (nonatomic, strong) GSAccountConfiguration *account;

+ (id)defaultConfiguration;
+ (id)configurationWithConfiguration:(GSConfiguration *)configuration;

@end
