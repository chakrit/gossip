//
//  GSAccount+Private.h
//  Gossip
//
//  Created by Chakrit Wichian on 8/20/12.
//
//

#import "GSAccount.h"

@interface GSAccount (Private)

- (pj_status_t)networkAddressChanged;
- (pj_status_t)disconnectWithoutReachability;

@end
