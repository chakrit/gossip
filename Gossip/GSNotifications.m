//
//  GSNotifications.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import "GSNotifications.h"

#define NOTIF_SYNT(name_) NSString *const name_ = @#name_;

NOTIF_SYNT(GSSIPRegistrationStateDidChangeNotification);
NOTIF_SYNT(GSSIPCallStateDidChangeNotification);
NOTIF_SYNT(GSSIPIncomingCallNotification);
NOTIF_SYNT(GSSIPCallMediaStateDidChangeNotification);

NOTIF_SYNT(GSSIPAccountIdKey);
NOTIF_SYNT(GSSIPCallIdKey);
NOTIF_SYNT(GSSIPDataKey);
