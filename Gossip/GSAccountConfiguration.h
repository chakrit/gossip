//
//  GSAccountConfiguration.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "PJSIP.h"

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Account configuration. Only supports "digest" and plain-text password authentication atm.
@interface GSAccountConfiguration : NSObject <NSCopying>

@property (nonatomic, copy) NSString *address; ///< SIP address. sip:user@host
@property (nonatomic, copy) NSString *registrar; ///< SIP domain. sip:host
@property (nonatomic, copy, nullable) NSString *proxyServer; ///< SIP outbound proxy server.
@property (nonatomic, copy) NSString *authScheme; ///< Authentication scheme. Defaults to "digest".
@property (nonatomic, copy) NSString *authRealm; ///< Authentication realm. Defaults to "*".
@property (nonatomic, copy) NSString *username; ///< SIP username.
@property (nonatomic, copy) NSString *password; ///< SIP password.

@property (nonatomic, copy, nullable) NSString *TURNServer; ///< TURN Server address.

/**
 * Specify the connection type to be used to the TURN server. Valid
 * values are PJ_TURN_TP_UDP or PJ_TURN_TP_TCP.
 *
 * Default: PJ_TURN_TP_UDP
 */
@property (nonatomic) pj_turn_tp_type TURNTransportType;
@property (nonatomic, copy, nullable) NSString *TURNUsername;
@property (nonatomic, copy, nullable) NSString *TURNCredential;


@property (nonatomic) BOOL enableStatusPublishing; ///< Enable online/status publishing for services that support them. Can prevent registration for services which don't support it so NO by default.

@property (nonatomic) BOOL enableRingback; ///< Enable automatic ringback sounds.
@property (nonatomic, copy) NSString *ringbackFilename; ///< Filename to play as ringback sounds. Defaults to "ringtone.wav" so you can just include it in your bundle and Gossip will pick it up.

@property (nonatomic) BOOL autoShowIncomingVideo;
@property (nonatomic) BOOL autoTransmitOutgoingVideo;

+ (instancetype)defaultConfiguration; ///< Creates a GSAccountConfiguration instance with default configuration values.
+ (instancetype)configurationWithConfiguration:(GSAccountConfiguration *)configuration; ///< Copy constructor.

@end

NS_ASSUME_NONNULL_END
