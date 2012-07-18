//
//  GSNotifications.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import <Foundation/Foundation.h>

/// Defines notification names
#define GSConstDefine(name_) extern NSString *const name_;

GSConstDefine(GSSIPRegistrationStateDidChangeNotification);
GSConstDefine(GSSIPRegistrationDidStartNotification);
GSConstDefine(GSSIPCallStateDidChangeNotification);
GSConstDefine(GSSIPIncomingCallNotification);
GSConstDefine(GSSIPCallMediaStateDidChangeNotification);
GSConstDefine(GSSIPVolumeDidChangeNotification);

GSConstDefine(GSVolumeDidChangeNotification);

GSConstDefine(GSSIPAccountIdKey);
GSConstDefine(GSSIPRenewKey);
GSConstDefine(GSSIPCallIdKey);
GSConstDefine(GSSIPDataKey);

GSConstDefine(GSVolumeKey);
GSConstDefine(GSMicVolumeKey);


// helper macros
#define GSNotifGetInt(notif_, key_) ([[[notif_ userInfo] objectForKey:key_] intValue])
#define GSNotifGetBool(notif_, key_) ([[[notif_ userInfo] objectForKey:key_] boolValue])
#define GSNotifGetString(info_, key_) ((NSString *)[[notif_ userInfo] objectForKey:key_]) 

