//
//  GSPJUtil.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSPJUtil.h"

@implementation GSPJUtil

+ (NSError *)errorWithSIPStatus:(pj_status_t)status {
    int errNumber = PJSIP_ERRNO_FROM_SIP_STATUS(status);
    
    pj_size_t bufferSize = sizeof(char) * 255;    
    NSMutableData *data = [NSMutableData dataWithLength:bufferSize];
    char *buffer = [data mutableBytes];
    pj_strerror(status, buffer, bufferSize);
    
    NSString *errorStr = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            errorStr, NSLocalizedDescriptionKey,
            [NSNumber numberWithInt:status], @"pj_status_t",
            [NSNumber numberWithInt:errNumber], @"PJSIP_ERRNO_FORM_SIP_STATUS", nil];
    
    NSError *err = nil;
    err = [NSError errorWithDomain:@"pjsip.org"
                              code:PJSIP_ERRNO_FROM_SIP_STATUS(status)
                          userInfo:info];
    
    return err;
}

+ (NSString *)stringWithPJString:(const pj_str_t *)pjString {
    return [[NSString alloc] initWithBytes:pjString->ptr
                                    length:pjString->slen
                                  encoding:NSUTF8StringEncoding];
}

+ (BOOL)verifySIPURIString:(nonnull NSString *)URIString {
    return [self verifySIPURICString:[URIString cStringUsingEncoding:NSUTF8StringEncoding]];
}

+ (BOOL)verifySIPURICString:(const char *)URIString {
    NSParameterAssert(URIString);
    if (!URIString) {
        return NO;
    }
    
    if (pjsua_verify_sip_url(URIString) == PJ_SUCCESS) {
        return YES;
    }
    
    return NO;
}

+ (pj_str_t)PJStringWithString:(NSString *)string {
    const char *cStr = [string cStringUsingEncoding:NSASCIIStringEncoding]; // TODO: UTF8?
    
    pj_str_t result;
    pj_cstr(&result, cStr);
    return result;
}

@end
