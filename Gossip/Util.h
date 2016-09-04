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
#define GSLogPJSIPError(status_)                                      \
    PJ_LOG(3, (__FILENAME__, "Gossip: %s", [GSPJUtil errorWithSIPStatus:status_].description.UTF8String));

#define GSLogIfFails(aStatement_) do {      \
    pj_status_t status = (aStatement_);     \
    if (status != PJ_SUCCESS)               \
        GSLogPJSIPError(status);              \
} while (0)

#define GSReturnValueIfFails(aStatement_, returnValue_) do {            \
    pj_status_t status = (aStatement_);                                 \
    if (status != PJ_SUCCESS) {                                         \
        GSLogPJSIPError(status);                                          \
        return returnValue_;                                            \
    }                                                                   \
} while(0)

#define GSReturnIfFails(aStatement_) GSReturnValueIfFails(aStatement_, )
#define GSReturnNoIfFails(aStatement_) GSReturnValueIfFails(aStatement_, NO)
#define GSReturnNilIfFails(aStatement_) GSReturnValueIfFails(aStatement_, nil)

#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)
