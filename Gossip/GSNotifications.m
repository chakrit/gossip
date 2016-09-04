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
GSConstSynthesize(GSSIPCallMediaEventNotification);
GSConstSynthesize(GSSIPTransportStateDidChangeNotification);
GSConstSynthesize(GSSIPSTUNResolutionCompleteNotification);
GSConstSynthesize(GSSIPNATDetectedNotification);
GSConstSynthesize(GSSIPParsedCancelReasonHeaderNotification);

GSConstSynthesize(GSVolumeDidChangeNotification);

GSConstSynthesize(GSSIPAccountIdKey);
GSConstSynthesize(GSSIPRenewKey);
GSConstSynthesize(GSSIPCallIdKey);

GSConstSynthesize(GSSIPTransportStateKey);
GSConstSynthesize(GSSIPTransportKey);
GSConstSynthesize(GSSIPTransportStateInfoKey);

GSConstSynthesize(GSSIPDataKey);
GSConstSynthesize(GSSIPMediaIdKey);

GSConstSynthesize(GSVolumeKey);
GSConstSynthesize(GSMicVolumeKey);
