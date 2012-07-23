//
//  GSUserAgent+Private.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/18/12.
//

#import "GSUserAgent.h"
#import "GSConfiguration.h"


@interface GSUserAgent (Private)

@property (nonatomic, readonly) GSConfiguration *configuration;
@property (nonatomic, readwrite) GSUserAgentState status;

@end
