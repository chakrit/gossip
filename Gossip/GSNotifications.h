//
//  GSNotifications.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

@import Foundation;

#pragma mark - Defines Notification Names
#define GSConstDefine(name_) extern NSString *const name_;

GSConstDefine(GSSIPRegistrationStateDidChangeNotification);
GSConstDefine(GSSIPRegistrationDidStartNotification);
GSConstDefine(GSSIPCallStateDidChangeNotification);
GSConstDefine(GSSIPIncomingCallNotification);
GSConstDefine(GSSIPCallMediaStateDidChangeNotification);
GSConstDefine(GSSIPCallMediaEventNotification);
GSConstDefine(GSSIPTransportStateDidChangeNotification);
GSConstDefine(GSSIPSTUNResolutionCompleteNotification);
GSConstDefine(GSSIPNATDetectedNotification);
GSConstDefine(GSSIPParsedCancelReasonHeaderNotification);

GSConstDefine(GSSIPVolumeDidChangeNotification);

GSConstDefine(GSVolumeDidChangeNotification);

GSConstDefine(GSSIPAccountIdKey);
GSConstDefine(GSSIPRenewKey);
GSConstDefine(GSSIPCallIdKey);

GSConstDefine(GSSIPTransportStateKey); // pjsip_transport_state
GSConstDefine(GSSIPTransportKey); // NSValue pjsip_transport *
GSConstDefine(GSSIPTransportStateInfoKey); // NSValue pjsip_transport_state_info *

GSConstDefine(GSSIPDataKey);
GSConstDefine(GSSIPMediaIdKey);


GSConstDefine(GSVolumeKey);
GSConstDefine(GSMicVolumeKey);


#pragma mark - Helper macros

#define GSNotifGetInt(notif_, key_) ([[[notif_ userInfo] objectForKey:key_] intValue])
#define GSNotifGetUnsigned(notif_, key_) ([[[notif_ userInfo] objectForKey:key_] unsignedIntValue])
#define GSNotifGetPointer(notif_, key_) ([((NSValue *)[[notif_ userInfo] objectForKey:key_]) pointerValue])
#define GSNotifGetBool(notif_, key_) ([[[notif_ userInfo] objectForKey:key_] boolValue])
#define GSNotifGetString(info_, key_) ((NSString *)[[notif_ userInfo] objectForKey:key_]) 

