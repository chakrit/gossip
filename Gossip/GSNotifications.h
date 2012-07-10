//
//  GSNotifications.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import <Foundation/Foundation.h>

/// Defines notification names
#define NOTIF_DECL(name_) extern NSString *const name_;

NOTIF_DECL(GSSIPRegistrationStateDidChangeNotification);
NOTIF_DECL(GSSIPRegistrationDidStartNotification);
NOTIF_DECL(GSSIPCallStateDidChangeNotification);
NOTIF_DECL(GSSIPIncomingCallNotification);
NOTIF_DECL(GSSIPCallMediaStateDidChangeNotification);

NOTIF_DECL(GSSIPAccountIdKey);
NOTIF_DECL(GSSIPRenewKey);
NOTIF_DECL(GSSIPCallIdKey);
NOTIF_DECL(GSSIPDataKey);
