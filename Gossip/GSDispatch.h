//
//  GSDispatch.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import <Foundation/Foundation.h>
#import "PJSIP.h"


@interface GSDispatch : NSObject

+ (void)configureCallbacksForAgent:(pjsua_config *)uaConfig;

@end
