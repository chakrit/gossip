//
//  GSNotifications.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import "GSNotifications.h"

#define NOTIF_SYNT(name_) NSString *const name_ = @#name_;

NOTIF_SYNT(GSSIPDidChangeRegistrationStateNotification);
NOTIF_SYNT(GSSIPDidChangeCallStateNotification);
NOTIF_SYNT(GSSIPIncomingCallNotification);
NOTIF_SYNT(GSSIPDidChangeCallMediaStateNotification);

NOTIF_SYNT(GSSIPAccountIdKey);
NOTIF_SYNT(GSSIPCallIdKey);
NOTIF_SYNT(GSSIPDataKey);
