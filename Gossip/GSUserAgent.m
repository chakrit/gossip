//
//  GSUserAgent.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/5/12.
//

#import "GSUserAgent.h"
#import "GSDispatch.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSUserAgent {
    GSConfiguration *_config;
    BOOL _suaCreated;
    BOOL _suaInitialized;
    
    pjsua_transport_id _transportId;
}

@synthesize account = _account;


+ (GSUserAgent *)sharedAgent {
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
        _account = nil;
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
    
    _account = nil;
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
    [GSDispatch configureCallbacksForAgent:&uaConfig];
    
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
    
    // configure account
    _account = [[GSAccount alloc] init];
    return [_account configure:_config.account];
}


- (BOOL)connect {
    NSAssert(_suaInitialized && !!_account, @"User agent not configured.");
    return [_account connect];
}

@end
