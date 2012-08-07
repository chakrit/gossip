//
//  GSToneGenerator.m
//  Gossip
//
//  Created by Chakrit Wichian on 8/7/12.
//

#import "GSToneGenerator.h"
#import "GSCall+Private.h"
#import "GSUserAgent.h"
#import "GSUserAgent+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSToneGenerator {
    GSCall *_call;
    
    pj_pool_t *_pool;
    pjmedia_port *_port;
    pjsua_conf_port_id _confPort;
}

- (id)init {
    if (self = [super init]) {
        GSUserAgent *agent = [GSUserAgent sharedAgent];
        GSConfiguration *config = agent.configuration;

        _pool = NULL;
        _port = NULL;
        _confPort = PJSUA_INVALID_ID;

        pj_pool_factory *factory = pjsua_get_pool_factory();
        _pool = pj_pool_create(factory, "gossip-tonegen", 4000, 4000, NULL);

        pj_status_t status = 0;
        status = pjmedia_tonegen_create(_pool, config.soundClockRate, 1, 64, 16, 0, &_port);
        if (status != PJ_SUCCESS) {
            GSLogSipError(status);
            pj_pool_release(_pool);
            return nil;
        }

        // TODO: Not sure if we should use the same memory pool?
        status = pjsua_conf_add_port(_pool, _port, &_confPort);
        if (status != PJ_SUCCESS) {
            GSLogSipError(status);
            pj_pool_release(_pool);
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    _call = nil;

    GSLogIfFails(pjsua_conf_remove_port(_confPort));
    _confPort = PJSUA_INVALID_ID;
    
    GSLogIfFails(pjmedia_port_destroy(_port));
    _port = NULL;

    pj_pool_release(_pool);
    _pool = NULL;
}


- (void)connectToCall:(GSCall *)call {
    pjsua_conf_port_id callPort = pjsua_call_get_conf_port(call.callId);

    // TODO: Not sure if this is the correct way to do it?
    //   what about ring back?
    pjsua_conf_connect(_confPort, callPort);
    _call = call;
}

- (void)disconnect {
    pjsua_conf_port_id callPort = pjsua_call_get_conf_port(_call.callId);
    pjsua_conf_disconnect(_confPort, callPort);

    _call = nil;
}

@end
