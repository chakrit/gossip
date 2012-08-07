//
//  GSToneGenerator.h
//  Gossip
//
//  Created by Chakrit Wichian on 8/7/12.
//

#import <Foundation/Foundation.h>
#import "GSCall.h"


@interface GSToneGenerator : NSObject

- (void)connectToCall:(GSCall *)call;
- (void)disconnect;

@end
