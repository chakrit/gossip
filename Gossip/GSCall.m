//
//  GSCall.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import "GSCall.h"
#import "GSCall+Private.h"
#import "GSAccount+Private.h"
#import "GSDispatch.h"
#import "GSIncomingCall.h"
#import "GSOutgoingCall.h"
#import "GSRingback.h"
#import "GSUserAgent+Private.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSCall {
    pjsua_call_id _callId;
    float _volume;
    float _micVolume;
    float _volumeScale;
}

+ (id)outgoingCallToUri:(NSString *)remoteUri fromAccount:(GSAccount *)account {
    GSOutgoingCall *call = [GSOutgoingCall alloc];
    call = [call initWithRemoteUri:remoteUri fromAccount:account];
    
    return call;
}

+ (id)incomingCallWithId:(int)callId toAccount:(GSAccount *)account {
    GSIncomingCall *call = [GSIncomingCall alloc];
    call = [call initWithCallId:callId toAccount:account];

    return call;
}


- (id)init {
    return [self initWithAccount:nil];
}

- (id)initWithAccount:(GSAccount *)account {
    if (self = [super init]) {
        GSAccountConfiguration *config = account.configuration;

        _account = account;
        _status = GSCallStatusReady;
        _callId = PJSUA_INVALID_ID;
        
        _ringback = nil;
        if (config.enableRingback) {
            _ringback = [GSRingback ringbackWithSoundNamed:config.ringbackFilename];
        }

        _volumeScale = [GSUserAgent sharedAgent].configuration.volumeScale;
        _volume = 1.0 / _volumeScale;
        _micVolume = 1.0 / _volumeScale;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(callStateDidChange:)
                       name:GSSIPCallStateDidChangeNotification
                     object:[GSDispatch class]];
        [center addObserver:self
                   selector:@selector(callMediaStateDidChange:)
                       name:GSSIPCallMediaStateDidChangeNotification
                     object:[GSDispatch class]];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];

    if (_ringback && _ringback.isPlaying) {
        [_ringback stop];
        _ringback = nil;
    }

    if (_callId != PJSUA_INVALID_ID && pjsua_call_is_active(_callId)) {
        GSLogIfFails(pjsua_call_hangup(_callId, 0, NULL, NULL));
    }
    
    _account = nil;
    _callId = PJSUA_INVALID_ID;
    _ringback = nil;
}


- (int)callId {
    return _callId;
}

- (void)setCallId:(int)callId {
    [self willChangeValueForKey:@"callId"];
    _callId = callId;
    [self didChangeValueForKey:@"callId"];
}

- (void)setStatus:(GSCallStatus)status {
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
}


- (float)volume {
    return _volume;
}

- (BOOL)setVolume:(float)volume {
    [self willChangeValueForKey:@"volume"];
    BOOL result = [self adjustVolume:volume mic:_micVolume];
    [self didChangeValueForKey:@"volume"];
    
    return result;
}

- (float)micVolume {
    return _micVolume;
}

- (BOOL)setMicVolume:(float)micVolume {
    [self willChangeValueForKey:@"micVolume"];
    BOOL result = [self adjustVolume:_volume mic:micVolume];
    [self didChangeValueForKey:@"micVolume"];
    
    return result;
}


- (BOOL)begin {
    // for child overrides only
    return NO;
}

- (BOOL)end {
    // for child overrides only
    return NO;
}


- (BOOL)sendDTMFDigits:(NSString *)digits {
    pj_str_t pjDigits = [GSPJUtil PJStringWithString:digits];
    pjsua_call_dial_dtmf(_callId, &pjDigits);
}


- (void)startRingback {
    if (!_ringback || _ringback.isPlaying)
        return;

    [_ringback play];
}

- (void)stopRingback {
    if (!(_ringback && _ringback.isPlaying))
        return;

    [_ringback stop];
}


- (void)callStateDidChange:(NSNotification *)notif {
    pjsua_call_id callId = GSNotifGetInt(notif, GSSIPCallIdKey);
    pjsua_acc_id accountId = GSNotifGetInt(notif, GSSIPAccountIdKey);
    if (callId != _callId || accountId != _account.accountId)
        return;
    
    pjsua_call_info callInfo;
    pjsua_call_get_info(_callId, &callInfo);
    
    GSCallStatus callStatus;
    switch (callInfo.state) {
        case PJSIP_INV_STATE_NULL: {
            callStatus = GSCallStatusReady;
        } break;
            
        case PJSIP_INV_STATE_CALLING:
        case PJSIP_INV_STATE_INCOMING: {
            callStatus = GSCallStatusCalling;
        } break;
            
        case PJSIP_INV_STATE_EARLY:
        case PJSIP_INV_STATE_CONNECTING: {
            [self startRingback];
            callStatus = GSCallStatusConnecting;
        } break;
            
        case PJSIP_INV_STATE_CONFIRMED: {
            [self stopRingback];
            callStatus = GSCallStatusConnected;
        } break;
            
        case PJSIP_INV_STATE_DISCONNECTED: {
            [self stopRingback];
            callStatus = GSCallStatusDisconnected;
        } break;
    }
    
    __block id self_ = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [self_ setStatus:callStatus]; });
}

- (void)callMediaStateDidChange:(NSNotification *)notif {
    pjsua_call_id callId = GSNotifGetInt(notif, GSSIPCallIdKey);
    if (callId != _callId)
        return;

    pjsua_call_info callInfo;
    GSReturnIfFails(pjsua_call_get_info(_callId, &callInfo));
    
    if (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        pjsua_conf_port_id callPort = pjsua_call_get_conf_port(_callId);
        GSReturnIfFails(pjsua_conf_connect(callPort, 0));
        GSReturnIfFails(pjsua_conf_connect(0, callPort));
        
        [self adjustVolume:_volume mic:_micVolume];
    }
}


- (BOOL)adjustVolume:(float)volume mic:(float)micVolume {
    GSAssert(0.0 <= volume && volume <= 1.0, @"Volume value must be between 0.0 and 1.0");
    GSAssert(0.0 <= micVolume && micVolume <= 1.0, @"Mic Volume must be between 0.0 and 1.0");
    
    _volume = volume;
    _micVolume = micVolume;
    if (_callId == PJSUA_INVALID_ID)
        return YES;
    
    pjsua_call_info callInfo;
    pjsua_call_get_info(_callId, &callInfo);
    if (callInfo.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        
        // scale volume as per configured volume scale
        volume *= _volumeScale;
        micVolume *= _volumeScale;
        pjsua_conf_port_id callPort = pjsua_call_get_conf_port(_callId);
        GSReturnNoIfFails(pjsua_conf_adjust_rx_level(callPort, volume));
        GSReturnNoIfFails(pjsua_conf_adjust_tx_level(callPort, micVolume));
    }
    
    // send volume change notification
    NSDictionary *info = nil;
    info = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:volume], GSVolumeKey,
            [NSNumber numberWithFloat:micVolume], GSMicVolumeKey, nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:GSVolumeDidChangeNotification
                          object:self
                        userInfo:info];
    
    return YES;
}

@end
