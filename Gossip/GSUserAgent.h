//
//  GSUserAgent.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/5/12.
//

#import <Foundation/Foundation.h>
#import "GSAccount.h"
#import "GSConfiguration.h"


/// Mains user agent interface. Applications should interact mainly with this class.
/// Applications must call -(void)configure on launch.
@interface GSUserAgent : NSObject

@property (nonatomic, strong, readonly) GSAccount *account;

/// Obtains the shared user agent instance.
+ (GSUserAgent *)sharedAgent;

/// Configure the agent for use.
/// For implementors, check the http://www.pjsip.org/pjsip/docs/html/structpjsua__acc__config.htm for reference.
- (BOOL)configure:(GSConfiguration *)config;

@end
