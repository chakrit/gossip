//
//  GSRingback.m
//  Gossip
//
//  Created by Chakrit Wichian on 8/15/12.
//
//

#import "GSRingback.h"
#import "GSUserAgent.h"
#import "GSUserAgent+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSRingback {
    float _volume;
    float _volumeScale;

    pjsua_conf_port_id _confPort;
    pjsua_player_id _playerId;
}

+ (id)ringbackWithSoundNamed:(NSString *)filename {
    return [[self alloc] initWithSoundNamed:filename];
}


- (id)initWithSoundNamed:(NSString *)filename {
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle mainBundle];

        _isPlaying = NO;
        _confPort = PJSUA_INVALID_ID;
        _playerId = PJSUA_INVALID_ID;

        _volumeScale = [GSUserAgent sharedAgent].configuration.volumeScale;
        _volume = 0.5 / _volumeScale; // half volume by default

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
    if (_playerId != PJSUA_INVALID_ID) {
        GSLogIfFails(pjsua_player_destroy(_playerId));
        _playerId = PJSUA_INVALID_ID;
    }
}


- (BOOL)setVolume:(float)volume {
    GSAssert(0.0 <= volume && volume <= 1.0, @"Volume value must be between 0.0 and 1.0");

    _volume = volume;
    volume *= _volumeScale;
    GSReturnNoIfFails(pjsua_conf_adjust_rx_level(_confPort, volume));
    GSReturnNoIfFails(pjsua_conf_adjust_tx_level(_confPort, volume));

    return YES;
}


- (BOOL)play {
    GSAssert(!_isPlaying, @"Already connected to a call.");

    GSReturnNoIfFails(pjsua_conf_connect(_confPort, 0));
    _isPlaying = YES;
    return YES;
}

- (BOOL)stop {
    GSAssert(_isPlaying, @"Not connected to a call.");

    GSReturnNoIfFails(pjsua_conf_disconnect(_confPort, 0));
    _isPlaying = NO;
    return YES;
}


@end
