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
#import "GSAccount+Private.h"
#import "GSDispatch.h"
#import "PJSIP.h"
#import "Util.h"
#import "RFC3326ReasonParser.h"

#include <arpa/inet.h>
#include <ifaddrs.h>
#include <resolv.h>
#include <dns.h>

NSString *GSUserAgentNetworkReachabilityChangedNotification = @"GSUserAgentNetworkReachabilityChangedNotification";

@import UIKit;

@interface GSUserAgent ()

@property (nonatomic, nullable, readwrite) GSConfiguration *configuration;

@end

@implementation GSUserAgent {
    pjsua_transport_id _transportId;
    GSReachability *_reachability;
}

@synthesize account = _account;
@synthesize status = _status;

+ (instancetype)sharedAgent {
    static dispatch_once_t onceToken;
    static GSUserAgent *agent = nil;
    dispatch_once(&onceToken, ^{ agent = [[GSUserAgent alloc] init]; });
    return agent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert([NSThread isMainThread], @"We must be called on the main thread");
        
        _transportId = PJSUA_INVALID_ID;
        _status = GSUserAgentStateUninitialized;
    }
    return self;
}

/// You must link against libresolv to use this.
- (nullable NSMutableArray <NSString *> *)systemDNSServers {
    res_state res = malloc(sizeof(struct __res_state));
    if (res == NULL) {
        return nil;
    }
    
    int result = res_ninit(res);
    
    NSMutableArray *servers;
    
    if (result == 0) {
        int count = res->nscount;
        
        if (count > 0) {
            servers = [[NSMutableArray alloc] initWithCapacity:count];
            
            for (int i = 0; i < count; i++)
            {
                sa_family_t family = res->nsaddr_list[i].sin_family;
                
                NSString *server;
                if (family == AF_INET) {
                    char address[INET_ADDRSTRLEN]; // String representation of address
                    inet_ntop(AF_INET, & (res->nsaddr_list[i].sin_addr.s_addr), address, INET_ADDRSTRLEN);
                    server = [NSString stringWithUTF8String:address];
                    if (!server) {
                        PJ_LOG(2, (__FILENAME__, "Could not create NSString for C String %s", address));
                        continue;
                    }
                } else if (family == AF_INET6) {
                    // TODO: This code is untested
                    char address[INET6_ADDRSTRLEN]; // String representation of address
                    inet_ntop(AF_INET6, &(res->nsaddr_list[i].sin_addr.s_addr), address, INET6_ADDRSTRLEN);
                    server = [NSString stringWithUTF8String:address];
                    if (!server) {
                        PJ_LOG(2, (__FILENAME__, "Could not create NSString for C String %s", address));
                        continue;
                    }
                } else {
                    PJ_LOG(3, (__FILENAME__, "Unknown sin_family"));
                    continue;
                }
                
                [servers addObject:server];
            }
        }
    }
    
    free(res);
    return servers;
}

- (void)setCodecPreferences {
    pj_status_t status;
    
    const pj_str_t codec_id_opus = {"Opus", 4};
    status = pjsua_codec_set_priority(&codec_id_opus, 255);
    if (status != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Coud not set Opus priority"));
    }
    
    const pj_str_t codec_id_h264 = {"H264", 4};
    pjmedia_vid_codec_param param;
    status = pjsua_vid_codec_get_param(&codec_id_h264, &param);
    if (status != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Coud not get information for H264"));
        return;
    }
    
    status = pjsua_vid_codec_set_priority(&codec_id_h264, 255);
    if (status != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Could not set H264 priority"));
    }
    
    const pjmedia_vid_codec_info *info;
    status = pjmedia_vid_codec_mgr_get_codec_info2(NULL, PJMEDIA_FORMAT_H264, &info);
    
    if (status != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Coud not get information for codec"));
        return;
    }
    
    /* A base16 (hexadecimal) representation of the following three bytes in the sequence parameter set NAL unit is specified in 1: 1) profile_idc, 2) a byte herein referred to as profile-iop, composed of the values of constraint_set0_flag, constraint_set1_flag, constraint_set2_flag, constraint_set3_flag, constraint_set4_flag, constraint_set5_flag, and reserved_zero_2bits in bit- significance order, starting from the most-significant bit, and 3) level_idc. */
    // https://en.wikipedia.org/wiki/H.264/MPEG-4_AVC#Profiles
    // https://en.wikipedia.org/wiki/H.264/MPEG-4_AVC#Levels
    // http://www.lighterra.com/papers/videoencodingh264/
    // http://stackoverflow.com/questions/22960928/identify-h264-profile-and-level-from-profile-level-id-in-sdp
    // http://stackoverflow.com/questions/23494168/h264-profile-iop-explained
    // https://supportforums.cisco.com/blog/150641/h264-profiles-cts-174
    
    // 42 = Binary 0100 0010 (Baseline)
    // 80 = Binary 1000 0000 (Bits 1 to 4 are flag 0 through 3. 0000 reserved 4 zero bits)
    // 33 = Binary 001 1110 (Decimal 51 which equals level 5.1)
    
    param.dec_fmtp.param[0].name = pj_str("profile-level-id");
    param.dec_fmtp.param[0].val = pj_str("428033");
    
    param.enc_fmtp.param[0].name = pj_str("profile-level-id");
    param.enc_fmtp.param[0].val = pj_str("428033");
    
    pjmedia_rect_size maximumSize = {1024, 768};
    param.dec_fmt.det.vid.size = maximumSize;
    param.enc_fmt.det.vid.size = maximumSize;
    
    param.enc_fmt.det.vid.fps.num   = 30;
    param.enc_fmt.det.vid.fps.denum = 1;
    param.dec_fmt.det.vid.fps.num   = 30;
    param.dec_fmt.det.vid.fps.denum = 1;
    
    param.enc_fmt.det.vid.avg_bps = 1500000;
    param.enc_fmt.det.vid.max_bps = 2500000;
    param.dec_fmt.det.vid.avg_bps = 1500000;
    param.dec_fmt.det.vid.max_bps = 2500000;
    
    // 640 x 480
    //    param.enc_fmt.det.vid.avg_bps = 768000;
    //    param.enc_fmt.det.vid.max_bps = 102400;
    //    param.dec_fmt.det.vid.avg_bps = 768000;
    //    param.dec_fmt.det.vid.max_bps = 102400;
    status = pjmedia_vid_codec_mgr_set_default_param(NULL, info, &param);
    if (status != PJ_SUCCESS) {
        PJ_PERROR(1, (__FILENAME__, status, "Coud not set default parameters for video"));
        return;
    }
}

- (void)willEnterForegroundNotification:(NSNotification *)notification
{
    if (_account != nil) {
        if (_account.status == GSAccountStatusOffline ||
            _account.status == GSAccountStatusInvalid ||
            _account.status == GSAccountStatusDisconnecting) {
            PJ_LOG(3, (__FILENAME__, "Entering Foreground: Account status is offline, invalid or disconnecting, so we will try to connect again. Account status is %d", _account.status));
            [_account connect];
        } else {
            PJ_LOG(3, (__FILENAME__, "Entering Foreground: Account status is not offline, invalid or disconnecting, so we will not try to connect again. Account status is %d", _account.status));
        }
    } else {
        PJ_LOG(3, (__FILENAME__, "Entering Foreground: Account is missing"));
    }
}

- (void)deviceOrientationChanged:(NSNotification *)notification
{
#if PJMEDIA_HAS_VIDEO
    const pjmedia_orient pj_ori[4] =
    {
        PJMEDIA_ORIENT_ROTATE_90DEG,  /* UIDeviceOrientationPortrait */
        PJMEDIA_ORIENT_ROTATE_270DEG, /* UIDeviceOrientationPortraitUpsideDown */
        PJMEDIA_ORIENT_ROTATE_180DEG, /* UIDeviceOrientationLandscapeLeft,
                                       home button on the right side */
        PJMEDIA_ORIENT_NATURAL        /* UIDeviceOrientationLandscapeRight,
                                       home button on the left side */
    };
    static pj_thread_desc a_thread_desc;
    static pj_thread_t *a_thread;
    static UIDeviceOrientation prev_ori = 0;
    UIDeviceOrientation dev_ori = [[UIDevice currentDevice] orientation];
    int i;
    
    if (dev_ori == prev_ori) return;
    
//    PJ_LOG(3, (__FILENAME__, "Device orientation changed: %ld", (prev_ori = dev_ori)));
    
    if (dev_ori >= UIDeviceOrientationPortrait &&
        dev_ori <= UIDeviceOrientationLandscapeRight)
    {
        if (!pj_thread_is_registered()) {
            pj_thread_register("Gossip", a_thread_desc, &a_thread);
        }
        
        /* Here we set the orientation for all video devices.
         * This may return failure for renderer devices or for
         * capture devices which do not support orientation setting,
         * we can simply ignore them.
         */
        for (i = pjsua_vid_dev_count()-1; i >= 0; i--) {
            pj_status_t status = pjsua_vid_dev_set_setting(i, PJMEDIA_VID_DEV_CAP_ORIENTATION,
                                                           &pj_ori[dev_ori-1], PJ_TRUE);
            if (status != PJ_SUCCESS) {
                PJ_PERROR(1, (__FILENAME__, status, "Could not set the video device orientation"));
            }
        }
    }
#endif
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
#if PJMEDIA_HAS_VIDEO
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:[UIDevice currentDevice]];
#endif
    
    if (_transportId != PJSUA_INVALID_ID) {
        pjsua_transport_close(_transportId, PJ_TRUE);
        _transportId = PJSUA_INVALID_ID;
    }
    
    if (_status >= GSUserAgentStateConfigured) {
        pjsua_destroy();
    }
    
    _status = GSUserAgentStateDestroyed;
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
    NSAssert([NSThread isMainThread], @"We must be called on the main thread");
    
    if (self.status != GSUserAgentStateUninitialized && self.status != GSUserAgentStateDestroyed) {
        return NO;
    }
    
    static pj_thread_desc a_thread_desc;
    static pj_thread_t *a_thread;
    
    if (!pj_thread_is_registered()) {
        pj_thread_register("Gossip", a_thread_desc, &a_thread);
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kGSReachabilityChangedNotification
                                               object:nil];
    
    _reachability = [GSReachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    [self logReachabilityStatus:_reachability];
    
    GSAssert(!_configuration, @"Gossip: User agent is already configured.");
    _configuration = [config copy];
    
    // create agent
    GSReturnNoIfFails(pjsua_create());
    [self setStatus:GSUserAgentStateCreated];
    
    // configure agent
    pjsua_config uaConfig;
    pjsua_logging_config logConfig;
    pjsua_media_config mediaConfig;
    
    pjsua_logging_config_default(&logConfig);
    pjsua_media_config_default(&mediaConfig);
    pjsua_config_default(&uaConfig);
    
    // Enable STUN
    if (_configuration.STUNServers != nil) {
        // We have TURN, so ignore STUN failures
        uaConfig.stun_ignore_failure = PJ_TRUE;
        
        NSUInteger desiredServerCount = _configuration.STUNServers.count;
        size_t stun_srv_limit = sizeof(uaConfig.stun_srv) / sizeof(uaConfig.stun_srv[0]);
        for (NSUInteger i = 0; i < desiredServerCount; i++) {
            NSString *server = _configuration.STUNServers[i];
            uaConfig.stun_srv[i] = [GSPJUtil PJStringWithString:server];
            if (i == (stun_srv_limit - 1)) {
                break;
            }
        }
        
        uaConfig.stun_srv_cnt = MIN((unsigned)desiredServerCount, (unsigned)stun_srv_limit);
    }
    
    // Enable ICE for all accounts
    mediaConfig.enable_ice = PJ_TRUE;
    
    uaConfig.use_srtp = PJMEDIA_SRTP_MANDATORY;
    uaConfig.srtp_secure_signaling = 1;
    
    pj_status_t status = pjsip_register_hdr_parser("Reason", NULL, &parse_hdr_reason);
    if (status != PJ_SUCCESS) {
        PJ_PERROR(1, (__FILENAME__, status, "Could not register RFC 3326 Reason parsing method"));
        return NO;
    }

    [GSDispatch configureCallbacksForAgent:&uaConfig];
    
    logConfig.level = _configuration.logLevel;
    logConfig.console_level = _configuration.consoleLogLevel;
    logConfig.msg_logging = _configuration.logMessages == YES ? PJ_TRUE : PJ_FALSE;
    
    mediaConfig.clock_rate = _configuration.clockRate;
    mediaConfig.snd_clock_rate = _configuration.soundClockRate;
    
    /* Echo canceller. The software AEC probably is the most CPU intensive module in PJSIP. To reduce the CPU usage, shorten the EC tail length to lower value (the pjsua_media_config.ec_tail_len setting), or even disable it altogether by setting pjsua_media_config.ec_tail_len to zero. */
    //    mediaConfig.ec_tail_len = 0;
    
    GSReturnNoIfFails(pjsua_init(&uaConfig, &logConfig, &mediaConfig));
    
    GSReturnNoIfFails([self updateDNSServers]);
    
    // TODO: Make separate class? since things like public_addr might be useful to some.
    pjsua_transport_config transportConfig;
    pjsua_transport_config_default(&transportConfig);
    
    pjsip_transport_type_e transportType = 0;
    switch (_configuration.transportType) {
        case GSTransportTypeUDP: transportType = PJSIP_TRANSPORT_UDP; break;
        case GSTransportTypeUDP6: transportType = PJSIP_TRANSPORT_UDP6; break;
        case GSTransportTypeTCP: transportType = PJSIP_TRANSPORT_TCP; break;
        case GSTransportTypeTCP6: transportType = PJSIP_TRANSPORT_TCP6; break;
        case GSTransportTypeTLS: transportType = PJSIP_TRANSPORT_TLS; break;
        case GSTransportTypeTLS6: transportType = PJSIP_TRANSPORT_TLS6; break;
    }
    
    GSReturnNoIfFails(pjsua_transport_create(transportType, &transportConfig, &_transportId));
    [self setStatus:GSUserAgentStateConfigured];
    
    [self setCodecPreferences];
    
    // configure account
    _account = [[GSAccount alloc] init];
    return [_account configure:_configuration.account];
}

- (pj_status_t)updateDNSServers {
    // Configure the DNS resolvers to handle SRV records
    NSMutableArray *DNSServers = [self systemDNSServers];
    pjsip_endpoint *endpoint = pjsua_get_pjsip_endpt();
    if (DNSServers) {
        PJ_LOG(2, (__FILENAME__, "Current system DNS servers: %s", DNSServers.description.UTF8String));
        pj_dns_resolver *resolver;
        
        NSUInteger count = DNSServers.count;
        
        pj_str_t *servers = malloc(sizeof(pj_str_t) * count);
        
        for (NSUInteger i = 0; i < count; i++) {
            NSString *server = DNSServers[i];
            pj_str_t pj_DNS = [GSPJUtil PJStringWithString:server];
            servers[i] = pj_DNS;
        }
        
        pj_status_t status = pjsip_endpt_create_resolver(endpoint, &resolver);
        if (status != PJ_SUCCESS) {
            GSLogPJSIPError(status);
            free(servers);
            return PJ_FALSE;
        }
        
        status = pj_dns_resolver_set_ns(resolver, 1, servers, nil);
        free(servers);
        if (status != PJ_SUCCESS) {
            GSLogPJSIPError(status);
            return PJ_FALSE;
        }
        
        return pjsip_endpt_set_resolver(endpoint, resolver);
    } else {
        PJ_LOG(2, (__FILENAME__, "Can not get system DNS Servers. Disabling custom DNS in PJSIP."));
        return pjsip_endpt_set_resolver(endpoint, NULL);
    }
    
    return PJ_FALSE;
}

- (BOOL)updateSTUNServers {
    if (_configuration.STUNServers == nil) {
        PJ_LOG(3, (__FILENAME__, "Can not update STUN servers with an empty set, please disable STUN on the account instead"));
        return false;
    }
    
    NSUInteger desiredServerCount = _configuration.STUNServers.count;
    
    pj_pool_t *pool = pjsua_pool_create("GSUserAgent", 1000, 1000);
    if (pool == NULL) {
        return NO;
    }
    
    // 8 is the max in pjsua_config. TODO: Get this dynamically?
    pj_size_t stun_srv_limit = 8;
    pj_str_t *stun_srv = pj_pool_calloc(pool, stun_srv_limit, sizeof(pj_str_t));
    
    pj_pool_release(pool);

    if (stun_srv == NULL) {
        return NO;
    }
    
    for (NSUInteger i = 0; i < desiredServerCount; i++) {
        NSString *server = _configuration.STUNServers[i];
        stun_srv[i] = [GSPJUtil PJStringWithString:server];
        if (i == (stun_srv_limit - 1)) {
            break;
        }
    }
    
    unsigned count = MIN((unsigned)desiredServerCount, (unsigned)stun_srv_limit);
    
    /* If \a wait parameter is non-zero, this will return
     * PJ_SUCCESS if one usable STUN server is found.
     * Otherwise it will always return PJ_SUCCESS, and
     * application will be notified about the result in
     * the callback #on_stun_resolution_complete. */
    pj_status_t status = pjsua_update_stun_servers(count, stun_srv, PJ_FALSE);
    if (status != PJ_SUCCESS) {
        return NO;
    }

    return YES;    
}

- (BOOL)start {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
#if PJMEDIA_HAS_VIDEO
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
#endif
    
    if (self.status == GSUserAgentStateStarted) {
        return NO;
    }
    
    static pj_thread_desc a_thread_desc;
    static pj_thread_t *a_thread;
    
    if (!pj_thread_is_registered()) {
        pj_thread_register("Gossip", a_thread_desc, &a_thread);
    }
    
    GSReturnNoIfFails(pjsua_start());
    [self setStatus:GSUserAgentStateStarted];
    return YES;
}

- (BOOL)reset {
    if (self.status == GSUserAgentStateDestroyed) {
        return NO;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
#if PJMEDIA_HAS_VIDEO
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:[UIDevice currentDevice]];
#endif 
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kGSReachabilityChangedNotification
                                                  object:nil];
    [_reachability stopNotifier];
    _reachability = nil;
    
    static pj_thread_desc a_thread_desc;
    static pj_thread_t *a_thread;
    
    if (!pj_thread_is_registered()) {
        pj_thread_register("Gossip", a_thread_desc, &a_thread);
    }
    
    [_account disconnect];
    
    // needs to nil account before pjsua_destroy so pjsua_acc_del succeeds.
    _transportId = PJSUA_INVALID_ID;
    _account = nil;
    _configuration = nil;
    PJ_LOG(3, (__FILENAME__, "Destroying..."));
    GSReturnNoIfFails(pjsua_destroy());
    [self setStatus:GSUserAgentStateDestroyed];
    return YES;
}

- (NSArray *)arrayOfAvailableCodecs {
    GSAssert(!!_configuration, @"Gossip: User agent not configured.");
    
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

- (void)backgroundKeepAliveHandler {
    static pj_thread_desc a_thread_desc;
    static pj_thread_t *a_thread;
    int i;
    
    if (!pj_thread_is_registered()) {
        pj_thread_register("Gossip", a_thread_desc, &a_thread);
    }
    
    /* Since iOS requires that the minimum keep alive interval is 600s,
     * application needs to make sure that the account's registration
     * timeout is long enough.
     */
    for (i = 0; i < (int)pjsua_acc_get_count(); ++i) {
        if (pjsua_acc_is_valid(i)) {
            pjsua_acc_set_registration(i, PJ_TRUE);
        }
    }
    
    //    pj_thread_sleep(5000);
}

#pragma mark - Reachability

- (void)logReachabilityStatus:(GSReachability *)currentReachability {
    GSNetworkStatus netStatus = [currentReachability currentReachabilityStatus];
    BOOL connectionRequired = [currentReachability connectionRequired];

    switch (netStatus) {
        case GSNotReachable:
            PJ_LOG(3, (__FILENAME__, "Network Not Available... Disconnecting Account"));
            connectionRequired = NO;
            break;
        case GSReachableViaWiFi:
            PJ_LOG(3, (__FILENAME__, "Reachable via Wi-Fi.."));
            break;
        case GSReachableViaWWAN:
            PJ_LOG(3, (__FILENAME__, "Reachable via WWAN.."));
            break;
    }
    
    if (connectionRequired) {
        PJ_LOG(3, (__FILENAME__, "New SIP REGISTRATION required"));
    }
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    pj_status_t status = [self updateDNSServers];
    if (status != PJ_SUCCESS) {
        PJ_PERROR(1, (__FILENAME__, status, "Reachability changed: could not update DNS servers..."));
    } else {
        PJ_LOG(3, (__FILENAME__, "Reachability changed: updated DNS servers..."));
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:GSUserAgentNetworkReachabilityChangedNotification object:notification.object userInfo:notification.userInfo];
    
    GSReachability *currentReachability = notification.object;
    
    NSAssert([currentReachability isKindOfClass:GSReachability.class], @"Wrong reachability class");
    [self logReachabilityStatus:currentReachability];
    
    GSNetworkStatus netStatus = [currentReachability currentReachabilityStatus];
    
    if (netStatus == GSNotReachable) {
        status = [self.account disconnectWithoutReachability];
        if (status != PJ_SUCCESS) {
            PJ_PERROR(1, (__FILENAME__, status, "Could not disconnect account"));
        }
    } else {
        if (self.account.status != GSAccountStatusConnected && self.account.status != GSAccountStatusConnecting) {
            PJ_LOG(3, (__FILENAME__, "Network Is Available... Will Reconnect Account with Status %d", self.account.status));
            [self.account connect];
        } else {
            PJ_LOG(3, (__FILENAME__, "Network Is Available... Will NOT reconnect account with status %d", self.account.status));
        }
    }

    if ([currentReachability currentReachabilityStatus] != GSNotReachable &&
        ![currentReachability connectionRequired]) {
        status = [self.account networkAddressChanged];
        if (status != PJ_SUCCESS) {
            PJ_PERROR(1, (__FILENAME__, status, "Could not update network address for account"));
        }
    }
}

- (GSNetworkStatus)currentReachabilityStatus {
    return _reachability.currentReachabilityStatus;
}

@end
