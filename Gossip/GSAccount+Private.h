//
//  GSAccount+Private.h
//  Gossip
//
//  Created by Chakrit Wichian on 8/20/12.
//
//

#import "GSAccount.h"
#import "GSAccountConfiguration.h"


@interface GSAccount (Private)

@property (nonatomic, readonly, copy) GSAccountConfiguration *configuration;

@end
