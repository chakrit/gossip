//
//  GSUserAgent.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/5/12.
//

#import "GSUserAgent.h"


void onRegistrationState(pjsua_acc_id accountId);
void onIncomingCall(pjsua_acc_id accountId, pjsua_call_id callId, pjsip_rx_data *rdata);
void onCallMediaState(pjsua_call_id callId);
void onCallState(pjsua_call_id callId, pjsip_event *e);


@implementation GSUserAgent {
    GSConfiguration *_config;
    BOOL _suaCreated;
    BOOL _suaInitialized;
    
    pjsua_transport_id _transportId;
    pjsua_acc_id _accountId;
}

+ (id)sharedAgent {
    static GSUserAgent *agent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        agent = [[GSUserAgent alloc] init];
    });
    
    return agent;
}


- (id)init {
    if (self = [super init]) {
        _suaCreated = NO;
        _suaInitialized = NO;
        _config = nil;
    }
    return self;
}

- (void)dealloc {
    if (_suaCreated) {
        pjsua_destroy();
        _suaInitialized = NO;
        _suaCreated = NO;
    }
    
    _config = nil;
}


- (BOOL)configure:(GSConfiguration *)config {
    _config = [config copy];
    
    pj_status_t status;
    _suaCreated = NO;
    _suaInitialized = NO;
    
    // create agent
    status = pjsua_create();
    RETURN_NO_IF_FAILED(status);
    _suaCreated = YES;
    
    // configure agent
    pjsua_config uaConfig;
    pjsua_logging_config logConfig;
    pjsua_media_config mediaConfig;
    
    pjsua_config_default(&uaConfig);
    uaConfig.cb.on_incoming_call = &onIncomingCall;
    uaConfig.cb.on_call_media_state = &onCallMediaState;
    uaConfig.cb.on_call_state = &onCallState;
    uaConfig.cb.on_reg_state = &onRegistrationState;
    
    pjsua_logging_config_default(&logConfig);
    logConfig.level = _config.logLevel;
    logConfig.console_level = _config.consoleLogLevel;
    
    pjsua_media_config_default(&mediaConfig);
    mediaConfig.clock_rate = _config.clockRate;
    mediaConfig.snd_clock_rate = _config.soundClockRate;
    mediaConfig.ec_tail_len = 0; // not sure what this does (Siphon use this.)
    
    status = pjsua_init(&uaConfig, &logConfig, &mediaConfig);
    RETURN_NO_IF_FAILED(status);
    _suaInitialized = YES;
    
    // create UDP transport (TODO: Make configurable? i.e. which protocol to use)
    pjsua_transport_config transportConfig;
    pjsua_transport_config_default(&transportConfig);
    
    status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &transportConfig, &_transportId);
    RETURN_NO_IF_FAILED(status);
    
    return YES; // successful so far
}


// TODO: Seperate accounts from user agent.
- (BOOL)connect {
    pj_status_t status = pjsua_start();
    RETURN_NO_IF_FAILED(status);
    
    // setup account
    pjsua_acc_config accConfig;
    pjsua_acc_config_default(&accConfig);
    
    accConfig.id = [_config.sipAddress PJStringWithSIPPrefix];
    accConfig.reg_uri = [_config.sipDomain PJStringWithSIPPrefix];
    accConfig.register_on_acc_add = PJ_TRUE;
    accConfig.publish_enabled = PJ_TRUE;
    
    if (!_config.sipProxyServer) {
        accConfig.proxy_cnt = 0;
    } else {
        accConfig.proxy_cnt = 1;
        accConfig.proxy[0] = [_config.sipProxyServer PJStringWithSIPPrefix];
    }
    
    status = pjsua_acc_add(&accConfig, PJ_TRUE, 0);
    RETURN_NO_IF_FAILED(status);
    
    return YES;
}

- (BOOL)disconnect {
    pjsua_acc_del(_accountId);
    RETURN_NO_IF_FAILED(status);

    return YES;
}

@end


void onRegistrationState(pjsua_acc_id accountId) {

}

void onIncomingCall(pjsua_acc_id accountId, pjsua_call_id callId, pjsip_rx_data *rdata) {
    
}

void onCallMediaState(pjsua_call_id callId) {
    
}

void onCallState(pjsua_call_id callId, pjsip_event *e) {
    
}
