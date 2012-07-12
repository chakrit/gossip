//
//  Util.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//


// additional util imports
#import "GSPJUtil.h"


// just in case we need to compile w/o assertions
#define GSAssert NSAssert


// PJSIP status check macros
#define GSLogSipError(status_)                                      \
    NSLog(@"Gossip: %@", [GSPJUtil errorWithSIPStatus:status_]);

#define GSLogIfFails(aStatement_) do {      \
    pj_status_t status = (aStatement_);     \
    if (status != PJ_SUCCESS)               \
        GSLogSipError(status);              \
} while (0)

#define GSReturnValueIfFails(aStatement_, returnValue_) do {            \
    pj_status_t status = (aStatement_);                                 \
    if (status != PJ_SUCCESS) {                                         \
        GSLogSipError(status);                                          \
        return returnValue_;                                            \
    }                                                                   \
} while(0)

#define GSReturnIfFails(aStatement_) GSReturnValueIfFails(aStatement_, )
#define GSReturnNoIfFails(aStatement_) GSReturnValueIfFails(aStatement_, NO)
#define GSReturnNilIfFails(aStatement_) GSReturnValueIfFails(aStatement_, nil)
