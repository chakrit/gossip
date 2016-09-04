//
//  GSPJUtil.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

@import Foundation;

#import "PJSIP.h"

NS_ASSUME_NONNULL_BEGIN

/// General utilities for working with PJSIP in ObjC land.
/** Had to use a static class instead since categories cause compilation problems
 *  when linked to an application. */
@interface GSPJUtil : NSObject

/// Creates an NSError from the given PJSIP status using PJSIP macros and functions.
+ (NSError *)errorWithSIPStatus:(pj_status_t)status;

/// Creates NSString from pj_str_t. Instance usable as long as pj_str_t lives.
+ (NSString *)stringWithPJString:(const pj_str_t *)pjString;

/// Creates pj_str_t from NSString. Instance lifetime depends on the NSString instance.
+ (pj_str_t)PJStringWithString:(NSString *)string;

/// Verifies that `URIString` is a valid SIP URI such as `sip:user@host`
+ (BOOL)verifySIPURIString:(NSString *)URIString;

@end

NS_ASSUME_NONNULL_END
