//
//  GSCallInfo.m
//  FingiSDK
//
//  Created by Hlung on 9/25/13.
//  Copyright (c) 2013 Oozou. All rights reserved.
//

#import "GSCallInfo.h"
#import "GSPJUtil.h"

@implementation NSString (GSCallInfo)
// change @"<sip:name@sip.com>" to @"name@sip.com"
- (NSString*)removeSipTag {
    return [[self substringWithRange:NSMakeRange(1, self.length-2)] stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
}
// change @"\"John\" <sip:name@sip.com>" to @[@"John",@"name@sip.com"]
- (NSArray*)nameAndAddressComponents {
    NSArray *c = [self componentsSeparatedByString:@" "];
    
    // Address, always the last component
    NSString *addr = @"";
    if (c.count > 0) {
        addr = [[c lastObject] removeSipTag];
    }
    
    // Name, separated from Address part by a space @" ".
    // But we also have to handle the case where there is space in the name.
    NSString *name = @"";
    if (c.count > 1) {
        NSMutableArray *m = [NSMutableArray arrayWithArray:c];
        [m removeObject:[c lastObject]];
        name = [m componentsJoinedByString:@" "];
        name = [name substringWithRange:NSMakeRange(1, name.length-2)];
    }
    
    return @[name,addr];
}
@end


@implementation GSCallInfo

- (id)initWithGSCall:(GSCall*)call {
    self = [super init];
    if (self) {
        pjsua_call_info callInfo;
        if (call.callId == PJSUA_INVALID_ID) return self; // return self for fake assign
        pj_status_t status = pjsua_call_get_info(call.callId, &callInfo);
        if (status != PJ_SUCCESS) return self;
        [self setupWithPjsuaCallInfo:callInfo];
    }
    return self;
}

- (void)setupWithPjsuaCallInfo:(pjsua_call_info)callInfo {
    // Somehow need to wrap in -stringWithFormat: to get correct string encoding.
    /*
     NSLog(@"%@",[GSPJUtil stringWithPJString:&callInfo.local_info]);        // <sip:local@sip.com>
     NSLog(@"%@",[GSPJUtil stringWithPJString:&callInfo.local_contact]);     // <sip:local@11.12.13.14:35345;ob>
     NSLog(@"%@",[GSPJUtil stringWithPJString:&callInfo.remote_info]);       // "chakrit" <sip:remote@sip2sip.info>
     NSLog(@"%@",[GSPJUtil stringWithPJString:&callInfo.remote_contact]);    // "chakrit" <sip:remote@11.12.13.14:45502;ob>
     NSLog(@"%@",[GSPJUtil stringWithPJString:&callInfo.call_id]);           // a random string
     */
    
    self.localAddress = [[NSString stringWithFormat:@"%@",[GSPJUtil stringWithPJString:&callInfo.local_info]] removeSipTag];
    
    NSArray *a = [[NSString stringWithFormat:@"%@",[GSPJUtil stringWithPJString:&callInfo.remote_info]] nameAndAddressComponents];
    self.remoteAddress = valueWithDefault(a[1], nil);
    self.remoteName = valueWithDefault(a[0], nil);
    
    self.callID = [NSString stringWithFormat:@"%@",[GSPJUtil stringWithPJString:&callInfo.call_id]];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"[<%@> remoteAddr:%@ localAddr:%@]", NSStringFromClass(self.class), self.remoteAddress, self.localAddress];
}

@end
