//
//  GSNotifications.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import "GSNotifications.h"

#define GSConstSynthesize(name_) NSString *const name_ = @#name_;

GSConstSynthesize(GSSIPRegistrationStateDidChangeNotification);
GSConstSynthesize(GSSIPRegistrationDidStartNotification);
GSConstSynthesize(GSSIPCallStateDidChangeNotification);
GSConstSynthesize(GSSIPIncomingCallNotification);
GSConstSynthesize(GSSIPCallMediaStateDidChangeNotification);

GSConstSynthesize(GSVolumeDidChangeNotification);

GSConstSynthesize(GSSIPAccountIdKey);
GSConstSynthesize(GSSIPRenewKey);
GSConstSynthesize(GSSIPCallIdKey);
GSConstSynthesize(GSSIPDataKey);

GSConstSynthesize(GSVolumeKey);
GSConstSynthesize(GSMicVolumeKey);
