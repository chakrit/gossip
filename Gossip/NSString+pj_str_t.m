//
//  NSString+pj_str_t.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "NSString+pj_str_t.h"


// TODO: Test that these won't leak.
@implementation NSString (pj_str_t)

+ (id)stringWithPJString:(const pj_str_t *)pjString {
    NSString *result = [NSString alloc];
    result = [result initWithBytesNoCopy:pjString->ptr
                                  length:pjString->slen
                                encoding:NSASCIIStringEncoding
                            freeWhenDone:NO];
    
    return result;
}


- (void)setToPJString:(pj_str_t *)pjStr {
    const char *cStr = [self cStringUsingEncoding:NSASCIIStringEncoding]; // TODO: UTF8?
    pj_cstr(pjStr, cStr); // simple pointer copy
}

- (pj_str_t)PJString {
    pj_str_t result;
    [self setToPJString:&result];
    return result;
}

- (pj_str_t)PJStringWithSIPPrefix {
    return [[self stringByAppendingSIPPrefix] PJString];
}

- (id)stringByAppendingSIPPrefix {
    return [@"sip:" stringByAppendingString:self];
}

@end
