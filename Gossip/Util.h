//
//  Util.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//


// SIP Status checks macros
#define RETURN_IF_FAILED(status_, value_)                           \
    if (status != PJ_SUCCESS) {                                     \
        NSLog(@"GOSSIP: %@", [NSError errorWithSIPStatus:status]);  \
        return value_;                                              \
    }

#define RETURN_NIL_IF_FAILED(status_) RETURN_IF_FAILED(status_, nil);
#define RETURN_VOID_IF_FAILED(status_) RETURN_IF_FAILED(status_, );
