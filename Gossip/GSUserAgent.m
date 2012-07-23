//
//  GSUserAgent.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/5/12.
//

#import "GSUserAgent.h"
#import "GSUserAgent+Private.h"
#import "GSCodecInfo.h"
#import "GSCodecInfo+Private.h"
#import "GSDispatch.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSUserAgent {
    GSConfiguration *_config;
    pjsua_transport_id _transportId;
}

@synthesize account = _account;
@synthesize status = _status;


+ (GSUserAgent *)sharedAgent {
    static GSUserAgent *agent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ agent = [[GSUserAgent alloc] init]; });
    
    return agent;
}


- (id)init {
    if (self = [super init]) {
        _account = nil;
        _config = nil;
        
        _transportId = PJSUA_INVALID_ID;
        _status = GSUserAgentStateUninitialized;
    }
    return self;
}

- (void)dealloc {
    if (_transportId != PJSUA_INVALID_ID) {
        pjsua_transport_close(_transportId, PJ_TRUE);
        _transportId = PJSUA_INVALID_ID;
    }
    
    if (_status >= GSUserAgentStateConfigured) {
        pjsua_destroy();
    }
    
    _account = nil;
    _config = nil;
    _status = GSUserAgentStateDestroyed;
}


- (GSConfiguration *)configuration {
    return _config;
}

- (GSUserAgentState)status {
    return _status;
}

- (void)setStatus:(GSUserAgentState)status {
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
}


- (BOOL)configure:(GSConfiguration *)config {
    GSAssert(!_config, @"Gossip: User agent is already configured.");
    _config = [config copy];
    
    // create agent
    GSReturnNoIfFails(pjsua_create());
    [self setStatus:GSUserAgentStateCreated];
    
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
    
    GSReturnNoIfFails(pjsua_init(&uaConfig, &logConfig, &mediaConfig));
    
    // create UDP transport
    // TODO: Make configurable? (which transport type to use/other transport opts)
    // TODO: Make separate class? since things like public_addr might be useful to some.
    pjsua_transport_config transportConfig;
    pjsua_transport_config_default(&transportConfig);
    
    pjsip_transport_type_e transportType = 0;
    switch (_config.transportType) {
        case GSUDPTransportType: transportType = PJSIP_TRANSPORT_UDP; break;
        case GSUDP6TransportType: transportType = PJSIP_TRANSPORT_UDP6; break;
        case GSTCPTransportType: transportType = PJSIP_TRANSPORT_TCP; break;
        case GSTCP6TransportType: transportType = PJSIP_TRANSPORT_TCP6; break;
    }
    
    GSReturnNoIfFails(pjsua_transport_create(transportType, &transportConfig, &_transportId));
    [self setStatus:GSUserAgentStateConfigured];

    // configure account
    _account = [[GSAccount alloc] init];
    return [_account configure:_config.account];
}

- (BOOL)start {
    GSReturnNoIfFails(pjsua_start());
    [self setStatus:GSUserAgentStateStarted];
    return YES;
}


- (NSArray *)arrayOfAvailableCodecs {
    GSAssert(!!_config, @"Gossip: User agent not configured.");
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    unsigned int count = 255;
    pjsua_codec_info codecs[count];
    GSReturnNilIfFails(pjsua_enum_codecs(codecs, &count));
    
    for (int i = 0; i < count; i++) {
        pjsua_codec_info pjCodec = codecs[i];
        
        GSCodecInfo *codec = [GSCodecInfo alloc];
        codec = [codec initWithCodecInfo:&pjCodec];
        [arr addObject:codec];
    }
    
    return [NSArray arrayWithArray:arr];
}

@end
