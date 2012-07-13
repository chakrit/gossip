//
//  GSCodecInfo.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/13/12.
//

#import "GSCodecInfo.h"
#import "GSCodecInfo+Private.h"
#import "PJSIP.h"
#import "GSPJUtil.h"


@implementation GSCodecInfo {
    pjsua_codec_info _info;
}

- (NSString *)codecId {
    return [GSPJUtil stringWithPJString:&_info.codec_id];
}

- (NSString *)description {
    return [GSPJUtil stringWithPJString:&_info.desc];
}

- (NSUInteger)priority {
    return _info.priority;
}


- (id)initWithCodecInfo:(pjsua_codec_info *)codecInfo {
    if (self = [super init]) {
        _info = *codecInfo;
    }
    return self;
}

@end
