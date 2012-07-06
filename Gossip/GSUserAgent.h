//
//  GSUserAgent.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/5/12.
//

#import "GSConfiguration.h"

/// Mains user agent interface. Applications should interact mainly with this class.
/// Applications must call -(void)configure on launch.
@interface GSUserAgent : NSObject

/// Obtains the shared user agent instance.
+ (id)sharedAgent;

/// Configure the agent for use.
/// For implementors, check the http://www.pjsip.org/pjsip/docs/html/structpjsua__acc__config.htm for reference.
- (BOOL)configure:(GSConfiguration *)config;

/// Connects to SIP sever using credentials specified in the agent configuration.
- (BOOL)connect;

@end
