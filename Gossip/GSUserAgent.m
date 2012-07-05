//
//  GSUserAgent.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/5/12.
//

#import "GSUserAgent.h"


@implementation GSUserAgent

+ (id)currentAgent {
    static GSUserAgent *agent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        agent = [[GSUserAgent alloc] init];
    });
    
    return agent;
}

@end
