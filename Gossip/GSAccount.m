//
//  GSAccount.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSAccount.h"
#import "GSAccount+Private.h"
#import "GSCall.h"
#import "GSDispatch.h"
#import "GSUserAgent.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSAccount {
    GSAccountConfiguration *_config;
}

- (id)init {
    if (self = [super init]) {
        _accountId = PJSUA_INVALID_ID;
        _status = GSAccountStatusOffline;
        _config = nil;
        
        _delegate = nil;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(didReceiveIncomingCall:)
                       name:GSSIPIncomingCallNotification
                     object:[GSDispatch class]];
        [center addObserver:self
                   selector:@selector(registrationDidStart:)
                       name:GSSIPRegistrationDidStartNotification
                     object:[GSDispatch class]];
        [center addObserver:self
                   selector:@selector(registrationStateDidChange:)
                       name:GSSIPRegistrationStateDidChangeNotification
                     object:[GSDispatch class]];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];

    GSUserAgent *agent = [GSUserAgent sharedAgent];
    if (_accountId != PJSUA_INVALID_ID && [agent status] != GSUserAgentStateDestroyed) {
        GSLogIfFails(pjsua_acc_del(_accountId));
        _accountId = PJSUA_INVALID_ID;
    }

    _accountId = PJSUA_INVALID_ID;
    _config = nil;
}


- (GSAccountConfiguration *)configuration {
    return _config;
}


- (BOOL)configure:(GSAccountConfiguration *)configuration {
    _config = [configuration copy];
    
    // prepare account config
    pjsua_acc_config accConfig;
    pjsua_acc_config_default(&accConfig);
    
    accConfig.id = [GSPJUtil PJAddressWithString:_config.address];
    accConfig.reg_uri = [GSPJUtil PJAddressWithString:_config.domain];
    accConfig.register_on_acc_add = PJ_FALSE; // connect manually
    accConfig.publish_enabled = _config.enableStatusPublishing ? PJ_TRUE : PJ_FALSE;
    
    if (!_config.proxyServer) {
        accConfig.proxy_cnt = 0;
    } else {
        accConfig.proxy_cnt = 1;
        accConfig.proxy[0] = [GSPJUtil PJAddressWithString:_config.proxyServer];
    }
    
    // adds credentials info
    pjsip_cred_info creds;
    creds.scheme = [GSPJUtil PJStringWithString:_config.authScheme];
    creds.realm = [GSPJUtil PJStringWithString:_config.authRealm];
    creds.username = [GSPJUtil PJStringWithString:_config.username];
    creds.data = [GSPJUtil PJStringWithString:_config.password];
    creds.data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    
    accConfig.cred_count = 1;
    accConfig.cred_info[0] = creds;

    // finish
    GSReturnNoIfFails(pjsua_acc_add(&accConfig, PJ_TRUE, &_accountId));    
    return YES;
}


- (BOOL)connect {
    NSAssert(!!_config, @"GSAccount not configured.");

    GSReturnNoIfFails(pjsua_acc_set_registration(_accountId, PJ_TRUE));
    GSReturnNoIfFails(pjsua_acc_set_online_status(_accountId, PJ_TRUE));    
    return YES;
}

- (BOOL)disconnect {
    NSAssert(!!_config, @"GSAccount not configured.");
        
    GSReturnNoIfFails(pjsua_acc_set_online_status(_accountId, PJ_FALSE));
    GSReturnNoIfFails(pjsua_acc_set_registration(_accountId, PJ_FALSE));
    return YES;
}


- (void)setStatus:(GSAccountStatus)newStatus {
    if (_status == newStatus) // don't send KVO notices unless it really changes.
        return;
    
    _status = newStatus;
}


- (void)didReceiveIncomingCall:(NSNotification *)notif {
    pjsua_acc_id accountId = GSNotifGetInt(notif, GSSIPAccountIdKey);
    pjsua_call_id callId = GSNotifGetInt(notif, GSSIPCallIdKey);
    if (accountId == PJSUA_INVALID_ID || accountId != _accountId)
        return;
    
    __block GSAccount *self_ = self;
    __block id delegate_ = _delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        GSCall *call = [GSCall incomingCallWithId:callId toAccount:self];        
        if (![delegate_ respondsToSelector:@selector(account:didReceiveIncomingCall:)])
            return; // call is disposed/hungup on dealloc
        
        [delegate_ performSelector:@selector(account:didReceiveIncomingCall:)
                        withObject:self_
                        withObject:call];
    });
}

- (void)registrationDidStart:(NSNotification *)notif {
    pjsua_acc_id accountId = GSNotifGetInt(notif, GSSIPAccountIdKey);
    pj_bool_t renew = GSNotifGetBool(notif, GSSIPRenewKey);
    if (accountId == PJSUA_INVALID_ID || accountId != _accountId)
        return;
    
    GSAccountStatus accStatus = 0;
    accStatus = renew ? GSAccountStatusConnecting : GSAccountStatusDisconnecting;

    __block id self_ = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [self_ setStatus:accStatus]; });
}

- (void)registrationStateDidChange:(NSNotification *)notif {
    pjsua_acc_id accountId = GSNotifGetInt(notif, GSSIPAccountIdKey);
    if (accountId == PJSUA_INVALID_ID || accountId != _accountId)
        return;
    
    GSAccountStatus accStatus;
    
    pjsua_acc_info info;
    GSReturnIfFails(pjsua_acc_get_info(accountId, &info));

    if (info.reg_last_err != PJ_SUCCESS) {
        accStatus = GSAccountStatusInvalid;
        
    } else {
        pjsip_status_code code = info.status;
        if (code == 0 || (info.online_status == PJ_FALSE)) {
            accStatus = GSAccountStatusOffline;
        } else if (PJSIP_IS_STATUS_IN_CLASS(code, 100) || PJSIP_IS_STATUS_IN_CLASS(code, 300)) {
            accStatus = GSAccountStatusConnecting;
        } else if (PJSIP_IS_STATUS_IN_CLASS(code, 200)) {
            accStatus = GSAccountStatusConnected;
        } else {
            accStatus = GSAccountStatusInvalid;
        }
    }
    
    __block id self_ = self;
    dispatch_async(dispatch_get_main_queue(), ^{ [self_ setStatus:accStatus]; });
}

@end
