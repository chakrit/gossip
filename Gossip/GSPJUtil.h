//
//  GSPJUtil.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import <Foundation/Foundation.h>
#import "PJSIP.h"


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

/// Creates pj_str_t from NSString prefixed with "sip:". Instance lifetime depends on the NSString instance.
+ (pj_str_t)PJAddressWithString:(NSString *)string;

@end
