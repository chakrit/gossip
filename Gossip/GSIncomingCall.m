//
//  GSIncomingCall.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/12/12.
//

#import "GSIncomingCall.h"
#import "GSCall+Private.h"
#import "PJSIP.h"
#import "Util.h"

@implementation GSIncomingCall {
//    pjsip_rx_data *_invite;
}

- (instancetype)initWithCallId:(pjsua_call_id)callId
                        invite:(pjsip_rx_data *)invite
                     toAccount:(GSAccount *)account {
    self = [super initWithAccount:account];
    if (self) {
        [self setCallId:callId];
        
        // Somehow PJSIP does not store it in the place you think it would store it. I would love to use their APIS rather than do the parsing myself
        NSString *inviteString = [[NSString alloc] initWithBytes:invite->pkt_info.packet
                                                          length:PJSIP_MAX_PKT_LEN
                                                        encoding:NSUTF8StringEncoding];
        NSArray *inviteLines = [inviteString componentsSeparatedByString:@"\r\n"];
        
        NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithCapacity:inviteLines.count];
        
        for (NSString *line in inviteLines) {
            NSArray *headerValue = [line componentsSeparatedByString:@": "];
            NSUInteger count = headerValue.count;
            if (count > 1) {
                [headers setObject:headerValue[1] forKey:headerValue.firstObject];
            }
        }
        
        self.inviteHeaders = [headers copy];
    }
    return self;
}

//- (nullable NSString *)stringForHeaderKey:(nonnull NSString *)headerKey {
//    NSParameterAssert(headerKey);

//    if (!_invite) {
//        return nil;
//    }
//
//    pj_str_t event_hdr_name = [GSPJUtil PJStringWithString:headerKey];
//    pjsip_generic_string_hdr *event_hdr = (pjsip_generic_string_hdr*)pjsip_msg_find_hdr_by_name(_invite->msg_info.msg, &event_hdr_name, NULL);
//    if (event_hdr == NULL) {
//        return nil;
//    }
//    
//    pj_str_t event_value = event_hdr->hvalue;
//    return [GSPJUtil stringWithPJString:&event_value];
//}

- (BOOL)begin {
    NSAssert(self.callId != PJSUA_INVALID_ID, @"Call has already ended.");
    
    GSReturnNoIfFails(pjsua_call_answer(self.callId, 200, NULL, NULL));
    return YES;
}

- (BOOL)end {
    NSAssert(self.callId != PJSUA_INVALID_ID, @"Call has already ended.");
    
    GSReturnNoIfFails(pjsua_call_hangup(self.callId, 0, NULL, NULL));
    
    [self setStatus:GSCallStatusDisconnected];
    [self setCallId:PJSUA_INVALID_ID];
    return YES;
}

- (BOOL)answerWithCode:(unsigned)code {
    NSAssert(self.callId != PJSUA_INVALID_ID, @"Call has not begun yet.");
    GSReturnNoIfFails(pjsua_call_answer(self.callId, code, NULL, NULL));
    return YES;
}

- (BOOL)isVideoEnabled {
    if (self.callId == PJSUA_INVALID_ID) {
        return NO;
    }
    
    pjsua_call_info call_info;
    if (pjsua_call_get_info(self.callId, &call_info) != PJ_SUCCESS) {
        PJ_LOG(2, (__FILENAME__, "Could not get call info"));
        return NO;
    }
    
    if (call_info.rem_vid_cnt > 0) {
        return YES;
    }
        
    return NO;
}

@end
