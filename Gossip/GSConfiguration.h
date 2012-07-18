//
//  GSConfiguration.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import <Foundation/Foundation.h>
#import "GSAccountConfiguration.h"


/// Supported transport types.
typedef enum {
    GSUDPTransportType, ///< UDP transport type.
    GSUDP6TransportType, ///< UDP on IPv6 transport type.
    GSTCPTransportType, ///< TCP transport type.
    GSTCP6TransportType, ///< TCP on IPv6 transport type.
} GSTransportType;


/// Main class for configuring a SIP user agent.
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
