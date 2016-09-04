//
//  GSAccount.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "PJSIP.h"

@import Foundation;

@class GSAccount, GSAccountConfiguration, GSCall;

/// Account Status enum.
typedef enum {
    GSAccountStatusOffline, ///< Account is offline or no registration has been done.
    GSAccountStatusInvalid, ///< Gossip has attempted registration but the credentials were invalid.
    GSAccountStatusConnecting, ///< Gossip is trying to register the account with the SIP server.
    GSAccountStatusConnected, ///< Account has been successfully registered with the SIP server.
    GSAccountStatusDisconnecting, ///< Account is being unregistered from the SIP server.
} GSAccountStatus; ///< Account status enum.

NS_ASSUME_NONNULL_BEGIN

/// Delegate to receive account activity.
@protocol GSAccountDelegate <NSObject>

/// Called when an account receives an incoming call.
/** Call -[GSCall begin] to accept incoming call or - [GSCall end] to deny.
 *  This should be done in a timely fashion since we do not support timeouts for incoming call yet. */
- (void)account:(GSAccount *)account didReceiveIncomingCall:(GSCall *)call;

@end


/// Represents a single PJSIP account. Only one account per session is supported right now.
@interface GSAccount : NSObject

@property (nonatomic, readonly) int accountId; ///< Account Id, automatically assigned by PJSIP.
@property (nonatomic, readonly) GSAccountStatus status; ///< Account registration status. Supports KVO notification.
@property (nonatomic, readonly) int lastStatusCode; ///< Account registration error code Last registration error code. When the status field contains a SIP status code that indicates a registration failure, last registration error code contains the error code that causes the failure. In any other case, its value is zero.
@property (nonatomic, nullable, readonly) NSString *lastStatusReason; ///< Account registration error reason.

@property (nonatomic, readonly, copy) GSAccountConfiguration *configuration;

@property (nullable, nonatomic, weak) id <GSAccountDelegate> delegate; ///< Account activity delegate.

/// Configures account with the specified configuration.
/** Must be run once and only once before using the GSAccount instance.
 *  Usually this is called automatically by the GSUserAgent instance. */
- (BOOL)configure:(GSAccountConfiguration *)configuration;

- (BOOL)connect; ///< Connects and begin registering with the configured SIP registration server.
- (BOOL)disconnect; ///< Unregister from the SIP registration server and disconnects.

- (BOOL)setSTUNEnabled:(BOOL)enabled;
- (BOOL)updateTURNServers;

@end

NS_ASSUME_NONNULL_END
