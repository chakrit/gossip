//
//  NSError+pj_status_t.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/5/12.
//

#import "NSError+pj_status_t.h"


@implementation NSError (PJSIP)

+ (id)errorWithSIPStatus:(pj_status_t)status {
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

@end
