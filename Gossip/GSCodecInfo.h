//
//  GSCodecInfo.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/13/12.
//

#import <Foundation/Foundation.h>


/// Contains information for a codec.
@interface GSCodecInfo : NSObject

@property (nonatomic, readonly) NSString *codecId; ///< Codec id as given by PJSIP
@property (nonatomic, readonly) NSString *description; ///< Codec descrition as given by PJSIP
@property (nonatomic, readonly) NSUInteger priority; ///< Codec priority in the range 1-254 or 0 to disable.

- (BOOL)setPriority:(NSUInteger)newPriority; ///< Sets codec priority.
- (BOOL)setMaxPriority; ///< Sets codec priority to maximum (254)

- (BOOL)disable; ///< Disable the codec. (Sets priority to 0)

@end
