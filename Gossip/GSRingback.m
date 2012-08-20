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
    pj_pool_t *_pool;
    pjmedia_port *_mediaPort;
    pjsua_conf_port_id _confPort;
}

+ (id)ringbackWithSoundNamed:(NSString *)filename {
    return [[self alloc] initWithSoundNamed:filename];
}


- (id)initWithSoundNamed:(NSString *)filename {
    if (self = [super init]) {
        _isConnected = NO;
        _mediaPort = NULL;
        _confPort = PJSUA_INVALID_ID;

        // create pjsua memory pool... (TODO: can't we just use the default pool?)
        // REF: http://www.pjsip.org/pjmedia/docs/html/group__PJMEDIA__WAV__PLAYLIST.htm
        pj_pool_factory *factory = pjsua_get_pool_factory();
        _pool = pj_pool_create(factory, "GSRingback", 4096, 4096, NULL);

        const pj_str_t filenames[] = { [GSPJUtil PJStringWithString:filename] };
        const pj_str_t portLabel = pj_str("GSRingback");

        GSReturnNilIfFails(pjmedia_wav_playlist_create(_pool, &portLabel, filenames, 1, 0, 0, 0, &_mediaPort));
        GSReturnNilIfFails(pjsua_conf_add_port(_pool, _mediaPort, &_confPort));
    }
    return self;
}

- (void)dealloc {
    if (_confPort != PJSUA_INVALID_ID) {
        GSLogIfFails(pjsua_conf_remove_port(_confPort));
        _confPort = PJSUA_INVALID_ID;
    }

    if (!_mediaPort) {
        GSLogIfFails(pjmedia_port_destroy(_mediaPort));
        _mediaPort = NULL;
    }

    if (!_pool) {
        pj_pool_release(_pool);
        _pool = NULL;
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
