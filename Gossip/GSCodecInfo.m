//
//  GSCodecInfo.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/13/12.
//

#import "GSCodecInfo.h"
#import "GSCodecInfo+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSCodecInfo {
    pjsua_codec_info _info;
}

- (id)initWithCodecInfo:(pjsua_codec_info *)codecInfo {
    if (self = [super init]) {
        _info = *codecInfo;
    }
    return self;
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

- (BOOL)setPriority:(NSUInteger)newPriority {
    GSReturnNoIfFails(pjsua_codec_set_priority(&_info.codec_id, newPriority));
    
    _info.priority = newPriority; // update cached info
    return YES;
}

- (BOOL)setMaxPriority {
    return [self setPriority:254];
}


- (BOOL)disable {
    return [self setPriority:0]; // 0 disables the codec as said in pjsua online doc
}

@end
