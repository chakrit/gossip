//
//  GSCallInfo.h
//  FingiSDK
//
//  Created by Hlung on 9/25/13.
//  Copyright (c) 2013 Oozou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GSCall;

/// Information accompanying GSCall derived from pjsua_call_get_info() function.
@interface GSCallInfo : NSObject

@property (nonatomic, copy) NSString* localAddress; ///< address of local caller, e.g. @"local@sip.com"
@property (nonatomic, copy) NSString* remoteAddress;///< address of remote caller, e.g. @"remote@sip.com"
@property (nonatomic, copy) NSString* remoteName;   ///< name of remote caller, independent from remoteAddress, e.g. @"John"
@property (nonatomic, copy) NSString* callID;       ///< a random string

- (id)initWithGSCall:(GSCall*)call;

@end
