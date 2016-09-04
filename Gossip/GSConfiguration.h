//
//  GSConfiguration.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

@import Foundation;

#import "GSAccountConfiguration.h"

/// Supported transport types.
typedef NS_ENUM(NSUInteger, GSTransportType)  {
    GSTransportTypeUDP, ///< UDP transport type.
    GSTransportTypeUDP6, ///< UDP on IPv6 transport type.
    GSTransportTypeTCP, ///< TCP transport type.
    GSTransportTypeTCP6, ///< TCP on IPv6 transport type.
    GSTransportTypeTLS, ///< TLS transport type.
    GSTransportTypeTLS6 ///< TLS on IPv6 transport type.
};

/// Main class for configuring a SIP user agent.
@interface GSConfiguration : NSObject <NSCopying>

@property (nonatomic) unsigned int logLevel; ///< PJSIP log level. 1 to 6 (verbose). Default 2.
@property (nonatomic) unsigned int consoleLogLevel; ///< PJSIP console output level. 1 to 6 (verbose). Default 2.
@property (nonatomic) BOOL logMessages; ///< PJSIP log SIP messages. Default NO

@property (nonatomic) GSTransportType transportType; ///< Transport type to use for connection.

@property (nonatomic) unsigned int clockRate; ///< PJSIP clock rate.
@property (nonatomic) unsigned int soundClockRate; ///< PJSIP sound clock rate.
@property (nonatomic) float volumeScale; ///< Used for scaling volumes up and down. Default 2.0.

@property (nonatomic, copy, nullable) NSOrderedSet *STUNServers; ///< STUN Server addresses.
@property (nonatomic, strong, nullable) GSAccountConfiguration *account;

+ (nonnull instancetype)defaultConfiguration;
+ (nonnull instancetype)configurationWithConfiguration:(nonnull GSConfiguration *)configuration;

@end
