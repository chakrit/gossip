//
//  NSString+pj_str_t.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//


@interface NSString (pj_str_t)

/// Creates NSString from pj_str_t. Instance lives as long as pj_str_t lives.
+ (id)stringWithPJString:(const pj_str_t *)pjString;

/// Sets supplied pj_str_t instance content to this string.
- (void)setToPJString:(pj_str_t *)pjStr;

/// Creates pj_str_t from NSString, lifetime depends on the NSString instance.
- (pj_str_t)PJString;

/// Convenience for creating a pj_str_t with a "sip:" prefix which is required in many places.
- (pj_str_t)PJStringWithSIPPrefix;

/// Convenience for adding a "sip:" prefix which is required in many places.
- (id)stringByAppendingSIPPrefix;

@end
