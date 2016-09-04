//
//  GSCall.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import "GSCall.h"
#import "GSCall+Private.h"

#import "GSAccount.h"
#import "GSRingback.h"
#import "GSDispatch.h"
#import "GSIncomingCall.h"
#import "GSOutgoingCall.h"
#import "GSRingback.h"
#import "GSUserAgent+Private.h"
#import "PJSIP.h"
#import "Util.h"
#import "RFC3326ReasonParser.h"

@interface GSCall()

@property (nonatomic, nullable, readwrite) NSDictionary <NSString *, NSString *> *inviteHeaders;
@property (nonatomic, readwrite, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readwrite) pjsip_status_code cancellationReasonCode;
@property (nullable, nonatomic, readwrite) NSString *cancellationReasonText;

@end

@implementation GSCall {
    pjsua_call_id _callId;
    float _volume;
    float _micVolume;
    float _volumeScale;
}

#ifdef PJMEDIA_HAS_VIDEO

@dynamic receivingVideo, transmittingVideo, videoEnabled;

#endif

@dynamic durationConnected, remoteInfo;

+ (BOOL)verifySIPURIString:(NSString *)URIString
{
    return [GSPJUtil verifySIPURIString:URIString];
}

+ (GSOutgoingCall *)outgoingCallToURI:(NSString *)outgoingCallToURI
                          fromAccount:(GSAccount *)account
                         videoEnabled:(BOOL)videoEnabled
                        customHeaders:(NSDictionary *)customHeaders {
    GSOutgoingCall *call = [GSOutgoingCall alloc];
    call = [call initWithRemoteURI:outgoingCallToURI
                       fromAccount:account
                      videoEnabled:videoEnabled
                     customHeaders:customHeaders];
    
    return call;
}

+ (GSIncomingCall *)incomingCallWithId:(pjsua_call_id)callId
                                invite:(pjsip_rx_data *)invite
                             toAccount:(GSAccount *)account {
    return [[GSIncomingCall alloc] initWithCallId:callId
                                           invite:invite
                                        toAccount:account];
}

- (instancetype)initWithAccount:(GSAccount *)account {
    self = [super init];
    
    if (self) {
        GSAccountConfiguration *config = account.configuration;
        
        _account = account;
        _status = GSCallStatusReady;
        _callId = PJSUA_INVALID_ID;
        
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
        [center addObserver:self
                   selector:@selector(callMediaEvent:)
                       name:GSSIPCallMediaEventNotification
                     object:[GSDispatch class]];
        [center addObserver:self
                   selector:@selector(callCancelledWithReason:)
                       name:GSSIPParsedCancelReasonHeaderNotification
                     object:[GSDispatch class]];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    
    if (_ringback && _ringback.isPlaying) {
        [_ringback stop];
    }
    
    if (_callId != PJSUA_INVALID_ID && pjsua_call_is_active(_callId)) {
        GSLogIfFails(pjsua_call_hangup(_callId, 0, NULL, NULL));
    }
    
    _callId = PJSUA_INVALID_ID;
}

- (pjsua_call_id)callId {
    return _callId;
}

// TODO: Automatic KVO?
- (void)setCallId:(pjsua_call_id)callId {
    [self willChangeValueForKey:@"callId"];
    _callId = callId;
    [self didChangeValueForKey:@"callId"];
}

- (void)setStatus:(GSCallStatus)status {
    [self willChangeValueForKey:@"status"];
    _status = status;
    [self didChangeValueForKey:@"status"];
}

- (void)setLastStatusCode:(pjsip_status_code)lastStatusCode {
    [self willChangeValueForKey:@"lastStatusCode"];
    _lastStatusCode = lastStatusCode;
    [self didChangeValueForKey:@"lastStatusCode"];
}

- (void)setLastStatusText:(NSString *)lastStatusText {
    [self willChangeValueForKey:@"lastStatusText"];
    _lastStatusText = lastStatusText;
    [self didChangeValueForKey:@"lastStatusText"];
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

- (BOOL)hasEnded {
    return (self.callId == PJSUA_INVALID_ID);
}

- (BOOL)begin {
    // for child overrides only
    return NO;
}

- (BOOL)end {
    // for child overrides only
    return NO;
}

- (BOOL)answerWithCode:(unsigned)code {
    // for child overrides only
    return NO;
}

//- (nullable NSString *)stringForHeaderKey:(NSString *)headerKey {
//    // for child overrides only
//    return nil;
//}

- (BOOL)sendDTMFDigits:(NSString *)digits {
    pj_str_t pjDigits = [GSPJUtil PJStringWithString:digits];
    if (pjsua_call_dial_dtmf(_callId, &pjDigits) == PJ_SUCCESS) {
        return YES;
    }
    
    return NO;
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
    GSReturnIfFails(pjsua_call_get_info(_callId, &callInfo));
    
    pjsip_status_code lastStatusCode = callInfo.last_status;
    NSString *lastStatusText;
    if (lastStatusCode != 0) {
        lastStatusText = [GSPJUtil stringWithPJString:&callInfo.last_status_text];
    }
    
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
            
            //            int vid_idx;
            //            pjsua_vid_win_id wid;
            //            
            //            vid_idx = pjsua_call_get_vid_stream_idx(callId);
            //            if (vid_idx >= 0) {
            //                pjsua_call_info ci;
            //                
            //                pjsua_call_get_info(callId, &ci);
            //                wid = ci.media[vid_idx].stream.vid.win_in;
            //            }
            
        } break;
            
        case PJSIP_INV_STATE_DISCONNECTED: {
            [self stopRingback];
            callStatus = GSCallStatusDisconnected;
        } break;
    }
    
    [self setLastStatusCode:lastStatusCode];
    [self setLastStatusText:lastStatusText];
    [self setStatus:callStatus];
}

#if PJMEDIA_HAS_VIDEO

- (void)enumerateVideoViews:(nonnull void (^)(UIView *view, BOOL isNative, BOOL *stop))block {
    NSParameterAssert(block);
    if (!block) {
        return;
    }
    
    if (![self isReceivingVideo] && ![self isTransmittingVideo]) {
        PJ_LOG(3, (__FILENAME__, "Cannot enumerate video views when not transmitting or receiving video"));
        return;
    }
    
    BOOL stop = NO;
    
    for (pjsua_vid_win_id i = 0; i < PJSUA_MAX_VID_WINS; ++i) {
        if (stop == YES) {
            break;
        }
        
        pjsua_vid_win_info wi;
        
        if (pjsua_vid_win_get_info(i, &wi) == PJ_SUCCESS) {
            UIView *view = (__bridge UIView *)wi.hwnd.info.ios.window;
            if (view) {
                block(view, (wi.is_native == 1) ? YES : NO, &stop);
            }
        }
    }
}

// http://lists.pjsip.org/pipermail/pjsip_lists.pjsip.org/2016-August/019417.html
- (BOOL)sendVideoKeyframe {
    if (_callId == PJSUA_INVALID_ID) {
        return NO;
    }
    
    int med_idx = pjsua_call_get_vid_stream_idx(_callId);
    if (med_idx == -1) {
        return NO;
    }
    
    pjsua_call_vid_strm_op_param param;
    
    pjsua_call_vid_strm_op op = PJSUA_CALL_VID_STRM_SEND_KEYFRAME;
    
    pjsua_call_vid_strm_op_param_default(&param);
    param.med_idx = med_idx;
    
    pj_status_t status = pjsua_call_set_vid_strm(_callId, op, &param);
    
    if (status != PJ_SUCCESS) {
        return NO;
    }
    
    return YES;
}

#endif

// Sending PJSUA_INVALID_ID will display all of the available ones
- (void)displayWindow:(pjsua_vid_win_id)wid {
#if PJMEDIA_HAS_VIDEO
    pjsua_vid_win_id i = (wid == PJSUA_INVALID_ID) ? 0 : wid;
    pjsua_vid_win_id last = (wid == PJSUA_INVALID_ID) ? PJSUA_MAX_VID_WINS : wid + 1;
    
    for (;i < last; ++i) {
        pjsua_vid_win_info wi;
        
        if (pjsua_vid_win_get_info(i, &wi) == PJ_SUCCESS) {
            UIView *view = (__bridge UIView *)wi.hwnd.info.ios.window;
            if (view) {
                [self.delegate call:self
                       providesView:view
                           isNative:(wi.is_native == 1) ? YES : NO];
            }
        }
    }
#endif
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
    
#if PJMEDIA_HAS_VIDEO
    for (unsigned mi = 0; mi < callInfo.media_cnt; ++mi) {
        switch (callInfo.media[mi].type) {
            case PJMEDIA_TYPE_VIDEO:
                if (callInfo.media_status != PJSUA_CALL_MEDIA_ACTIVE)
                    return;
                // For now show all windows
                [self displayWindow:PJSUA_INVALID_ID];
                break;
            default:
                break;
        }
    }
    
    /* Check if remote has just tried to enable video */
    if (callInfo.rem_offerer && callInfo.rem_vid_cnt)
    {
        /* Check if there is active video */
        int vid_idx = pjsua_call_get_vid_stream_idx(callId);
        
        if (vid_idx == -1 || callInfo.media[vid_idx].dir == PJMEDIA_DIR_NONE) {
            PJ_LOG(3, (__FILENAME__, "Incoming video offer was rejected"));
        }
    }
#endif
}

- (void)callCancelledWithReason:(NSNotification *)notification {
    pjsua_call_id callId = GSNotifGetInt(notification, GSSIPCallIdKey);
    if (callId != _callId) {
        return;
    }
    
    pjsip_reason_hdr *header = GSNotifGetPointer(notification, GSSIPDataKey);
    if (header != NULL) {
        self.cancelled = YES;
        self.cancellationReasonCode = (pjsip_status_code)header->cause;
        self.cancellationReasonText = [GSPJUtil stringWithPJString:&header->text];
    }
}

- (void)callMediaEvent:(NSNotification *)notif {
    //#if PJMEDIA_HAS_VIDEO
    //    pjsua_call_id callId = GSNotifGetInt(notif, GSSIPCallIdKey);
    //    if (callId != _callId)
    //        return;
    //    
    //    pjmedia_event *event = GSNotifGetPointer(notif, GSSIPDataKey);
    //    
    //    char event_name[5];
    //    pjmedia_fourcc_name(event->type, event_name);
    //    
    //    //    PJ_LOG(3, (__FILENAME__, "Media event %s", event_name));
    //    
    //    if (event->type == PJMEDIA_EVENT_FMT_CHANGED) {
    //        /* Adjust renderer window size to original video size */
    //        pjsua_call_info ci;
    //        
    //        GSReturnIfFails(pjsua_call_get_info(_callId, &ci));
    //        
    //        unsigned med_idx = GSNotifGetUnsigned(notif, GSSIPMediaIdKey);
    //        
    //        if ((ci.media[med_idx].type == PJMEDIA_TYPE_VIDEO) &&
    //            (ci.media[med_idx].dir & PJMEDIA_DIR_DECODING))
    //        {
    //            pjsua_vid_win_id wid;
    //            pjmedia_rect_size size;
    //            pjsua_vid_win_info win_info;
    //            
    //            wid = ci.media[med_idx].stream.vid.win_in;
    //            pjsua_vid_win_get_info(wid, &win_info);
    //            
    //            size = event->data.fmt_changed.new_fmt.det.vid.size;
    //            if (size.w != win_info.size.w || size.h != win_info.size.h) {
    //                pjsua_vid_win_set_size(wid, &size);
    //                [self displayWindow:wid];
    //            }
    //        }
    //    }
    //#endif
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

#if PJMEDIA_HAS_VIDEO

// Incoming and Outgoing may override this.
// TODO: Check that the heuristics work
- (BOOL)isVideoEnabled {
    if (_callId == PJSUA_INVALID_ID) {
        return NO;
    }
    
    pjsua_call_info call_info;
    if (pjsua_call_get_info(_callId, &call_info) != PJ_SUCCESS) {
        PJ_LOG(3, (__FILENAME__, "Could not get call info"));
        return NO;
    }
    
    if (call_info.setting.vid_cnt > 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isReceivingVideo {
    if (_callId == PJSUA_INVALID_ID) {
        return NO;
    }
    
    int med_idx = pjsua_call_get_vid_stream_idx(_callId);
    if (med_idx == -1) {
        return NO;
    }
    
    if (pjsua_call_vid_stream_is_running(_callId, med_idx, PJMEDIA_DIR_DECODING) != PJ_TRUE) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isTransmittingVideo {
    if (_callId == PJSUA_INVALID_ID) {
        return NO;
    }
    
    int med_idx = pjsua_call_get_vid_stream_idx(_callId);
    if (med_idx == -1) {
        return NO;
    }
    
    if (pjsua_call_vid_stream_is_running(_callId, med_idx, PJMEDIA_DIR_ENCODING) != PJ_TRUE) {
        return NO;
    }
    
    return YES;
}

- (BOOL)setVideoTransmissionEnabled:(BOOL)enabled {
    if (_callId == PJSUA_INVALID_ID) {
        return NO;
    }
    
    int med_idx = pjsua_call_get_vid_stream_idx(_callId);
    if (med_idx == -1) {
        return NO;
    }
    
    pj_status_t transmissionAlreadyEnabled = pjsua_call_vid_stream_is_running(_callId, med_idx, PJMEDIA_DIR_ENCODING);
    
    // Check if we actually ahve something to do
    if (enabled && transmissionAlreadyEnabled) {
        return YES;
    }
    
    if (!enabled && !transmissionAlreadyEnabled) {
        return YES;
    }
    
    pjsua_call_vid_strm_op_param param;
    
    pjsua_call_vid_strm_op op = enabled ? PJSUA_CALL_VID_STRM_START_TRANSMIT : PJSUA_CALL_VID_STRM_STOP_TRANSMIT;
    
    pjsua_call_vid_strm_op_param_default(&param);
    param.med_idx = med_idx;
    
    pj_status_t status = pjsua_call_set_vid_strm(_callId, op, &param);
    
    if (status != PJ_SUCCESS) {
        return NO;
    }
    
    return YES;
}

static char *name_camera_front = "Front Camera";
static char *name_camera_back = "Back Camera";

- (AVCaptureDevicePosition)captureDevicePosition {
    if (![self isTransmittingVideo]) {
        PJ_LOG(3, (__FILENAME__, "Not encoding any video currenty"));
        return AVCaptureDevicePositionUnspecified;
    }
    
    pjsua_call_info call_info;
    if (pjsua_call_get_info(_callId, &call_info) != PJ_SUCCESS) {
        PJ_LOG(3, (__FILENAME__, "Could not get call info"));
        return AVCaptureDevicePositionUnspecified;
    }
    
    pjmedia_vid_dev_index *cap_dev_index = NULL;
    for (unsigned mi = 0; mi < call_info.media_cnt; ++mi) {
        if (call_info.media[mi].type == PJMEDIA_TYPE_VIDEO &&
            (call_info.media[mi].dir & PJMEDIA_DIR_ENCODING) != 0) {
            cap_dev_index = &call_info.media[mi].stream.vid.cap_dev;
        }
    }
    
    if (cap_dev_index == NULL) {
        PJ_LOG(3, (__FILENAME__, "Could not find capture device for PJMEDIA_DIR_ENCODING"));
        return AVCaptureDevicePositionUnspecified;
    }
    
    if (*cap_dev_index == PJMEDIA_VID_INVALID_DEV) {
        PJ_LOG(3, (__FILENAME__, "Found PJMEDIA_VID_INVALID_DEV"));
        return AVCaptureDevicePositionUnspecified;
    }
    
    pjmedia_vid_dev_info dev_info;
    
    pj_status_t status = pjsua_vid_dev_get_info(*cap_dev_index, &dev_info);
    if (status != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Could not get device info"));
        return AVCaptureDevicePositionUnspecified;
    }
    
    if (pj_ansi_strcmp(dev_info.name, name_camera_front) == 0) {
        return AVCaptureDevicePositionFront;
    } else if (pj_ansi_strcmp(dev_info.name, name_camera_back) == 0) {
        return AVCaptureDevicePositionBack;
    }
    
    return AVCaptureDevicePositionUnspecified;
}

- (BOOL)setCaptureDevicePosition:(AVCaptureDevicePosition)position {
    if (position != AVCaptureDevicePositionFront && position != AVCaptureDevicePositionBack) {
        PJ_LOG(2, (__FILENAME__, "Invalid position value"));
        return NO;
    }
    
    if (![self isTransmittingVideo]) {
        PJ_LOG(3, (__FILENAME__, "Not encoding any video currenty"));
        return NO;
    }
    
    pjsua_call_info call_info;
    if (pjsua_call_get_info(_callId, &call_info) != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Could not get call info"));
        return NO;
    }
    
    unsigned *media_idx = NULL;
    for (unsigned mi = 0; mi < call_info.media_cnt; ++mi) {
        if (call_info.media[mi].type == PJMEDIA_TYPE_VIDEO &&
            (call_info.media[mi].dir & PJMEDIA_DIR_ENCODING) != 0) {
            media_idx = &call_info.media[mi].index;
        }
    }
    
    if (media_idx == NULL) {
        PJ_LOG(2, (__FILENAME__, "Could not find media stream for PJMEDIA_DIR_ENCODING"));
        return NO;
    }
    
#define MAX_DEV_COUNT 64
    pjmedia_vid_dev_info info[MAX_DEV_COUNT];
    unsigned count = MAX_DEV_COUNT;
    pj_status_t status = pjsua_vid_enum_devs(info, &count);
    if (status != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Could not enumerate devices. Status: %s", [GSPJUtil errorWithSIPStatus:status].description.UTF8String));
        return NO;
    }
    
    pjmedia_vid_dev_index *cap_dev = NULL;
    
    char *name_match;
    if (position == AVCaptureDevicePositionFront) {
        name_match = name_camera_front;
    } else {
        name_match = name_camera_back;
    }
    
    for (unsigned i = 0; i < count; ++i) {
        if ((info[i].dir & PJMEDIA_DIR_ENCODING) != 0) {
            if (pj_ansi_strcmp(info[i].driver, "AVF") == 0) {
                if (pj_ansi_strcmp(info[i].name, name_match) == 0) {
                    cap_dev = &info[i].id;
                    break;
                }
            }
        }
    }
    
    if (cap_dev == NULL) {
        PJ_LOG(2, (__FILENAME__, "Could not find device for PJMEDIA_DIR_ENCODING"));
        return NO;
    }
    
    pjsua_call_vid_strm_op_param param;
    pjsua_call_vid_strm_op_param_default(&param);
    param.med_idx = *media_idx;
    param.cap_dev = *cap_dev;
    
    status = pjsua_call_set_vid_strm(_callId,
                                     PJSUA_CALL_VID_STRM_CHANGE_CAP_DEV,
                                     &param);
    if (status != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Could not change video stream. Status: %s", [GSPJUtil errorWithSIPStatus:status].description.UTF8String));
        return NO;
    }
    
    return YES;
}

#endif

- (NSString *)remoteInfo {
    if (_callId == PJSUA_INVALID_ID) {
        return nil;
    }
    
    pjsua_call_info callInfo;
    
    pj_status_t status = pjsua_call_get_info(_callId, &callInfo);
    
    if (status != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Could not get call info. Status: %s", [GSPJUtil errorWithSIPStatus:status].description.UTF8String));
        return nil;
    }
    
    return [GSPJUtil stringWithPJString:&callInfo.remote_info];
}

- (long)durationConnected {
    if (_callId == PJSUA_INVALID_ID) {
        return NSNotFound;
    }
    
    pjsua_call_info callInfo;
    
    pj_status_t status = pjsua_call_get_info(_callId, &callInfo);
    
    if (status != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Could not get call info. Status: %s", [GSPJUtil errorWithSIPStatus:status].description.UTF8String));
        return NSNotFound;
    }
    
    return callInfo.connect_duration.sec;
}

@end
