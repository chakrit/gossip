//
//  GSCodecInfo.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/13/12.
//

#import <Foundation/Foundation.h>


@interface GSCodecInfo : NSObject

@property (nonatomic, readonly) NSString *codecId;
@property (nonatomic, readonly) NSString *description;
@property (nonatomic, readonly) NSUInteger priority;

@end
