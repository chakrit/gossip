//
//  GSRingback.m
//  Gossip
//
//  Created by Chakrit Wichian on 8/15/12.
//
//

#import "GSRingback.h"
#import "GSCall+Private.h"
#import "GSUserAgent.h"
#import "GSUserAgent+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSRingback {
    pjsua_conf_port_id _confPort;
    pjsua_player_id _playerId;
}

+ (id)ringbackWithSoundNamed:(NSString *)filename {
    return [[self alloc] initWithSoundNamed:filename];
}


- (id)initWithSoundNamed:(NSString *)filename {
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle mainBundle];

        _isConnected = NO;
        _confPort = PJSUA_INVALID_ID;
        _playerId = PJSUA_INVALID_ID;

        // resolve bundle filename
        filename = [filename lastPathComponent];
        filename = [bundle pathForResource:[filename stringByDeletingPathExtension]
                                    ofType:[filename pathExtension]];
        NSLog(@"Gossip: ringbackWithSoundNamed: %@", filename);

        // create pjsua media playlist
        const pj_str_t filenames[] = { [GSPJUtil PJStringWithString:filename] };
        GSReturnNilIfFails(pjsua_playlist_create(filenames, 1, NULL, 0, &_playerId));

        _confPort = pjsua_player_get_conf_port(_playerId);
    }
    return self;
}

- (void)dealloc {
    if (_confPort != PJSUA_INVALID_ID) {
        GSLogIfFails(pjsua_conf_remove_port(_confPort));
        _confPort = PJSUA_INVALID_ID;
    }

    if (_playerId != PJSUA_INVALID_ID) {
        GSLogIfFails(pjsua_player_destroy(_playerId));
        _playerId = PJSUA_INVALID_ID;
    }
}


- (void)play {
    GSAssert(!_isConnected, @"Already connected to a call.");

    GSLogIfFails(pjsua_conf_connect(_confPort, 0));
    _isConnected = YES;
}

- (void)stop {
    GSAssert(_isConnected, @"Not connected to a call.");

    GSLogIfFails(pjsua_conf_disconnect(_confPort, 0));
    _isConnected = NO;
}


@end
