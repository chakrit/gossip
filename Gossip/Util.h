//
//  Util.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//


// additional util imports
#import "GSPJUtil.h"


// SIP Status checks macros
#define LOG_IF_FAILED(status_)                                      \
    if (status != PJ_SUCCESS)                                       \
        NSLog(@"GOSSIP: %@", [GSPJUtil errorWithSIPStatus:status]);

#define RETURN_IF_FAILED(status_, value_)                           \
    if (status != PJ_SUCCESS) {                                     \
        NSLog(@"GOSSIP: %@", [GSPJUtil errorWithSIPStatus:status]);  \
        return value_;                                              \
    }

#define RETURN_NIL_IF_FAILED(status_) RETURN_IF_FAILED(status_, nil);
#define RETURN_NO_IF_FAILED(status_) RETURN_IF_FAILED(status_, NO);
#define RETURN_VOID_IF_FAILED(status_) RETURN_IF_FAILED(status_, );
