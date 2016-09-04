//
//  GSCodecInfo+Private.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/13/12.
//

#import "GSCodecInfo.h"
#import "PJSIP.h"

@interface GSCodecInfo (Private)

- (instancetype)initWithCodecInfo:(pjsua_codec_info *)codecInfo;

@end
