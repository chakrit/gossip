//
//  GSAccount.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSAccount.h"
#import "GSAccountConfiguration.h"
#import "GSCall.h"
#import "GSDispatch.h"
#import "GSUserAgent.h"
#import "Util.h"

@interface GSAccount ()

@property (nonatomic, readwrite) int lastStatusCode;
@property (nonatomic, nullable, readwrite) NSString *lastStatusReason;

@end

@implementation GSAccount {
     pjsip_transport * _Nullable _current_transport;
}

@synthesize configuration = _config;

- (id)init {
    self = [super init];
    if (self) {
        _accountId = PJSUA_INVALID_ID;
        _status = GSAccountStatusOffline;
        
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
        [center addObserver:self
                   selector:@selector(transportStateDidChange:)
                       name:GSSIPTransportStateDidChangeNotification
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
}

- (BOOL)configure:(GSAccountConfiguration *)configuration {
    _config = [configuration copy];
    
    // prepare account config
    pjsua_acc_config accConfig;
    pjsua_acc_config_default(&accConfig);

    // To avoid issues with multiple invites sent to IP addresses that both route to us
//    accConfig.allow_contact_rewrite = PJ_TRUE;
//    accConfig.contact_rewrite_method = PJSUA_CONTACT_REWRITE_UNREGISTER;

    // You can use a colorbar for testing by chaning vid_cap_dev to the appropriate device number
    //    accConfig.vid_cap_dev = 4;
    accConfig.reg_retry_interval = 20;
    accConfig.id = [GSPJUtil PJStringWithString:_config.address];
    accConfig.reg_uri = [GSPJUtil PJStringWithString:_config.registrar];
    accConfig.register_on_acc_add = PJ_FALSE; // connect manually
    accConfig.publish_enabled = _config.enableStatusPublishing ? PJ_TRUE : PJ_FALSE;
    
    accConfig.vid_in_auto_show = _config.autoShowIncomingVideo ? PJ_TRUE : PJ_FALSE;
    accConfig.vid_out_auto_transmit = _config.autoTransmitOutgoingVideo ? PJ_TRUE : PJ_FALSE;
    
    if (!_config.proxyServer) {
        accConfig.proxy_cnt = 0;
    } else {
        accConfig.proxy_cnt = 1;
        accConfig.proxy[0] = [GSPJUtil PJStringWithString:_config.proxyServer];
    }
    
    if (!_config.proxyServer) {
        accConfig.proxy_cnt = 0;
    } else {
        accConfig.proxy_cnt = 1;
        accConfig.proxy[0] = [GSPJUtil PJStringWithString:_config.proxyServer];
    }
    
    // Enable TURN
    if (_config.TURNServer != nil) {
        accConfig.turn_cfg_use = PJSUA_TURN_CONFIG_USE_CUSTOM;
        
        accConfig.turn_cfg.enable_turn = PJ_TRUE;
        accConfig.turn_cfg.turn_server = [GSPJUtil PJStringWithString:_config.TURNServer];
        accConfig.turn_cfg.turn_conn_type = _config.TURNTransportType;
        
        if (_config.TURNUsername != nil && _config.TURNCredential != nil) {
            pj_stun_auth_cred cred;
            pj_bzero(&cred, sizeof(cred));
            cred.type = PJ_STUN_AUTH_CRED_STATIC;
            cred.data.static_cred.username = [GSPJUtil PJStringWithString:_config.TURNUsername];
            cred.data.static_cred.data_type = PJ_STUN_PASSWD_PLAIN;
            cred.data.static_cred.data = [GSPJUtil PJStringWithString:_config.TURNCredential];
            accConfig.turn_cfg.turn_auth_cred = cred;
        }
    }

    // Credentials
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

- (BOOL)setSTUNEnabled:(BOOL)enabled {    
    pj_status_t status;
    pjsua_acc_config acc_cfg_existing;
    
    // create a new pj pool used when copying the existing config
    pj_pool_t *pool = pjsua_pool_create("GSAccount", 1000, 1000);
    if (pool == NULL) {
        return NO;
    }
    
    // now copy the existing account config - if you already have one
    status = pjsua_acc_get_config(self.accountId, pool, &acc_cfg_existing);
    if (status != PJ_SUCCESS) {
        return NO;
    }
    
    pjsua_acc_config acc_cfg_new;
    
    pjsua_acc_config_dup(pool, &acc_cfg_new, &acc_cfg_existing);
    
    pj_pool_release(pool);
    
    acc_cfg_new.sip_stun_use = enabled ? PJSUA_STUN_USE_DEFAULT : PJSUA_STUN_USE_DISABLED;
    acc_cfg_new.media_stun_use = enabled ? PJSUA_STUN_USE_DEFAULT : PJSUA_STUN_USE_DISABLED;
    
    // Now apply the new config without STUN to the current config
    status = pjsua_acc_modify(self.accountId, &acc_cfg_new);
    if (status != PJ_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)updateTURNServers {
    pj_status_t status;
    pjsua_acc_config acc_cfg_existing;
    
    // create a new pj pool used when copying the existing config
    pj_pool_t *pool = pjsua_pool_create("GSAccount", 1000, 1000);
    if (pool == NULL) {
        return NO;
    }
    
    // now copy the existing account config - if you already have one
    status = pjsua_acc_get_config(self.accountId, pool, &acc_cfg_existing);
    if (status != PJ_SUCCESS) {
        return NO;
    }
    
    pjsua_acc_config acc_cfg_new;
    
    pjsua_acc_config_dup(pool, &acc_cfg_new, &acc_cfg_existing);
    
    pj_pool_release(pool);

    if (_config.TURNServer != nil) {
        acc_cfg_new.turn_cfg_use = PJSUA_TURN_CONFIG_USE_CUSTOM;
        
        acc_cfg_new.turn_cfg.enable_turn = PJ_TRUE;
        acc_cfg_new.turn_cfg.turn_server = [GSPJUtil PJStringWithString:_config.TURNServer];
        acc_cfg_new.turn_cfg.turn_conn_type = _config.TURNTransportType;
        
        pj_stun_auth_cred cred;
        pj_bzero(&cred, sizeof(cred));
        if (_config.TURNUsername != nil && _config.TURNCredential != nil) {
            cred.type = PJ_STUN_AUTH_CRED_STATIC;
            cred.data.static_cred.username = [GSPJUtil PJStringWithString:_config.TURNUsername];
            cred.data.static_cred.data_type = PJ_STUN_PASSWD_PLAIN;
            cred.data.static_cred.data = [GSPJUtil PJStringWithString:_config.TURNCredential];
        }
        acc_cfg_new.turn_cfg.turn_auth_cred = cred;
    } else {
        acc_cfg_new.turn_cfg_use = PJSUA_TURN_CONFIG_USE_DEFAULT;
        acc_cfg_new.turn_cfg.enable_turn = PJ_FALSE;
    }

    // Now apply the new config without STUN to the current config
    status = pjsua_acc_modify(self.accountId, &acc_cfg_new);
    if (status != PJ_SUCCESS) {
        return NO;
    }
    
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

/// This avoids the Disconnecting delay when you don't have reachability
- (pj_status_t)disconnectWithoutReachability {
    NSAssert(!!_config, @"GSAccount not configured.");
    
    pj_status_t status = pjsua_acc_set_online_status(_accountId, PJ_FALSE);
    if (status != PJ_SUCCESS) {
        PJ_PERROR(1, (__FILENAME__, status, "pjsua_acc_set_online_status(PJ_FALSE) error"));
    }
    
    status = pjsua_acc_set_registration(_accountId, PJ_FALSE);
    if (status != PJ_SUCCESS) {
        PJ_PERROR(1, (__FILENAME__, status, "pjsua_acc_set_registration(PJ_FALSE) error"));
    }
    
    [self setStatus:GSAccountStatusOffline];
    
    status = [self shutdownAndUnsetCurrentTransport];
    if (status != PJ_SUCCESS) {
        return status;
    }
    
    return PJ_SUCCESS;
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
    
    pjsip_rx_data *invite = GSNotifGetPointer(notif, GSSIPDataKey);

    __block GSAccount *self_ = self;
    __block id delegate_ = _delegate;
    dispatch_async(dispatch_get_main_queue(), ^{
        GSIncomingCall *call = [GSCall incomingCallWithId:callId
                                                   invite:invite
                                                toAccount:self];
        if (![delegate_ respondsToSelector:@selector(account:didReceiveIncomingCall:)])
            return; // call is disposed/hungup on dealloc
        
        [delegate_ performSelector:@selector(account:didReceiveIncomingCall:)
                        withObject:self_
                        withObject:call];
    });
}

- (void)registrationDidStart:(NSNotification *)notif {
    pjsua_acc_id accountId = GSNotifGetInt(notif, GSSIPAccountIdKey);
    if (accountId == PJSUA_INVALID_ID || accountId != _accountId)
        return;
    
    pj_bool_t renew = GSNotifGetBool(notif, GSSIPRenewKey);
    // Note that the Disconnecting status will be mistakenly set if you use PJSUA_CONTACT_REWRITE_UNREGISTER. This requires a patch to PJSIP to know for what purpose a REGISTER message was sent.
    GSAccountStatus accStatus = renew ? GSAccountStatusConnecting : GSAccountStatusDisconnecting;
    
    [self setStatus:accStatus];
    
    // IP Address Change
    if (accountId != _accountId)
        return;
    
    pjsua_reg_info *info = GSNotifGetPointer(notif, GSSIPDataKey);
    
    pjsip_regc_info regc_info;
    pjsip_regc_get_info(info->regc, &regc_info);
    
    [self setCurrentTransport:regc_info.transport];
}

- (void)registrationStateDidChange:(NSNotification *)notif {
    pjsua_acc_id accountId = GSNotifGetInt(notif, GSSIPAccountIdKey);
    if (accountId == PJSUA_INVALID_ID || accountId != _accountId)
        return;
    
    GSAccountStatus accStatus;
    
    pjsua_acc_info acc_info;
    GSReturnIfFails(pjsua_acc_get_info(accountId, &acc_info));
    
    if (acc_info.reg_last_err != PJ_SUCCESS) {
        accStatus = GSAccountStatusInvalid;
    } else {
        pjsip_status_code code = acc_info.status;
        if (code == 0 || (acc_info.online_status == PJ_FALSE)) {
            if (code == PJSIP_SC_REQUEST_TIMEOUT) {
                PJ_LOG(3, (__FILENAME__, "Registration Did Change Timeout!.."));
                accStatus = GSAccountStatusInvalid;
            } else {
                accStatus = GSAccountStatusOffline;
            }
        } else if (PJSIP_IS_STATUS_IN_CLASS(code, 100) || PJSIP_IS_STATUS_IN_CLASS(code, 300)) {;
            accStatus = GSAccountStatusConnecting;
        } else if (PJSIP_IS_STATUS_IN_CLASS(code, 200)) {
            accStatus = GSAccountStatusConnected;
        } else {
            accStatus = GSAccountStatusInvalid;
        }
    }
    
    pjsua_reg_info *info = GSNotifGetPointer(notif, GSSIPDataKey);
    
    pjsip_regc_info regc_info;
    pjsip_regc_get_info(info->regc, &regc_info);
    [self setCurrentTransport:regc_info.transport];
    
    struct pjsip_regc_cbparam *rp = info->cbparam;

    self.lastStatusCode = rp->code;
    self.lastStatusReason = [GSPJUtil stringWithPJString:&rp->reason];

    [self setStatus:accStatus];
    
    // IP address change
    if (rp->code/100 == 2 && rp->expiration > 0 && rp->contact_cnt > 0) {
        /* We already saved the transport instance */
    } else {
        [self unsetCurrentTransport];
    }
}

- (void)transportStateDidChange:(NSNotification *)notification {
    pjsip_transport_state state = GSNotifGetInt(notification, GSSIPTransportStateKey);
    pjsip_transport *tp = GSNotifGetPointer(notification, GSSIPTransportKey);
    
    if (state == PJSIP_TP_STATE_DISCONNECTED && _current_transport == tp) {
        [self unsetCurrentTransport];
    }
}

#pragma mark - Transport

- (pj_status_t)setCurrentTransport:(pjsip_transport * _Nullable)transport {
    if (_current_transport != transport) {
        pj_status_t status;
        if (_current_transport) {
            PJ_LOG(3, (__FILENAME__, "Releasing transport.."));
            status = pjsip_transport_dec_ref(_current_transport);
            if (status != PJ_SUCCESS) {
                PJ_PERROR(1, (__FILENAME__, status, "pjsip_transport_dec_ref() error"));
                return status;
            }
            
            _current_transport = NULL;
        }
        /* Save transport instance so that we can close it later when
         * new IP address is detected.
         */
        PJ_LOG(3, (__FILENAME__, "Saving transport.."));
        _current_transport = transport;
        if (_current_transport != NULL) {
            status = pjsip_transport_add_ref(_current_transport);
            if (status != PJ_SUCCESS) {
                PJ_PERROR(1, (__FILENAME__, status, "pjsip_transport_add_ref() error"));
                return status;
            }
        }
        
        return PJ_SUCCESS;
    }
    
    return PJ_FALSE;
}

- (pj_status_t)shutdownAndUnsetCurrentTransport {
    if (_current_transport) {
        pj_status_t status = pjsip_transport_shutdown(_current_transport);
        if (status != PJ_SUCCESS) {
            PJ_PERROR(1, (__FILENAME__, status, "pjsip_transport_shutdown() error"));
            return status;
        }
        
        return [self unsetCurrentTransport];
    }
    
    return PJ_FALSE;
}

- (pj_status_t)unsetCurrentTransport {
    if (_current_transport) {
        PJ_LOG(3, (__FILENAME__, "Releasing transport.."));
        pj_status_t status = pjsip_transport_dec_ref(_current_transport);
        if (status != PJ_SUCCESS) {
            PJ_PERROR(1, (__FILENAME__, status, "pjsip_transport_dec_ref() error"));
            return status;
        }
        _current_transport = NULL;
        return PJ_SUCCESS;
    }
    
    return PJ_FALSE;
}

#pragma mark - Network Changes

- (pj_status_t)networkAddressChanged {
    pj_status_t status;
    
    PJ_LOG(3, (__FILENAME__, "IP address changed... will shutdown transport and reregister"));
    
    status = [self shutdownAndUnsetCurrentTransport];
    if (status != PJ_SUCCESS) {
        PJ_PERROR(1, (__FILENAME__, status, "Could not shut down the current transport, reregistration may not work initially"));
    }
    
    // Go online
    status = pjsua_acc_set_registration(_accountId, PJ_TRUE);
    if (status != PJ_SUCCESS) {
        PJ_PERROR(1, (__FILENAME__, status, "pjsua_acc_set_registration(PJ_TRUE) error"));
        return status;
    }
    
    status = pjsua_acc_set_online_status(_accountId, PJ_TRUE);
    if (status != PJ_SUCCESS) {
        PJ_PERROR(1, (__FILENAME__, status, "pjsua_acc_set_online_status(PJ_TRUE) error"));
        return status;
    }
    
    return PJ_SUCCESS;
}

@end
