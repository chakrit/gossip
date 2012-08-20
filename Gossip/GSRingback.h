//
//  GSRingback.h
//  Gossip
//
//  Created by Chakrit Wichian on 8/15/12.
//
//

#import <Foundation/Foundation.h>
#import "GSCall.h"


/// Ringback sound player.
@interface GSRingback : NSObject

@property (nonatomic, readonly) BOOL isConnected;

/// Creates GSRingback instance with ringback tone from the specified filename.
+ (id)ringbackWithSoundNamed:(NSString *)filename;

- (void)play; ///< Plays the ringback sound on the default sound device.
- (void)stop; ///< Stops the playback.

@end
