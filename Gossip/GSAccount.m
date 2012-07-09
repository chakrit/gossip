//
//  GSAccount.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSAccount.h"
#import "GSDispatch.h"
#import "PJSIP.h"
#import "Util.h"


@implementation GSAccount {
    GSAccountConfiguration *_config;
}

@synthesize accountId = _accountId;
@synthesize status = _status;

- (id)init {
    if (self = [super init]) {
        _accountId = PJSUA_INVALID_ID;
        _status = GSAccountStatusOffline;
        _config = nil;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
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
    
    if (_accountId != PJSUA_INVALID_ID) {
        pj_status_t status = pjsua_acc_del(_accountId);
        LOG_IF_FAILED(status);
        _accountId = PJSUA_INVALID_ID;
    }
    
    _config = nil;
}


- (BOOL)configure:(GSAccountConfiguration *)configuration {
    _config = [configuration copy];
    
    // prepare account config
    pj_status_t status;
    pjsua_acc_config accConfig;
    pjsua_acc_config_default(&accConfig);
    
    accConfig.id = [GSPJUtil PJAddressWithString:_config.address];
    accConfig.reg_uri = [GSPJUtil PJAddressWithString:_config.domain];
    accConfig.register_on_acc_add = PJ_FALSE; // connect manually
    accConfig.publish_enabled = YES;
    
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
    
    accConfig.cred_info[0] = creds;
    accConfig.cred_count = 1;

    // finish
    status = pjsua_acc_add(&accConfig, PJ_TRUE, &_accountId);
    RETURN_NO_IF_FAILED(status);
    
    return YES;
}


- (BOOL)connect {
    NSAssert(!!_config, @"GSAccount not configured.");

    pj_status_t status = pjsua_acc_set_registration(_accountId, PJ_TRUE);
    RETURN_NO_IF_FAILED(status);
    
    status = pjsua_acc_set_online_status(_accountId, PJ_TRUE);
    RETURN_NO_IF_FAILED(status);
    
    return YES;
}

- (BOOL)disconnect {
    NSAssert(!!_config, @"GSAccount not configured.");
        
    pj_status_t status = pjsua_acc_set_online_status(_accountId, PJ_FALSE);
    RETURN_NO_IF_FAILED(status);
    
    status = pjsua_acc_set_registration(_accountId, PJ_FALSE);
    RETURN_NO_IF_FAILED(status);
    
    return YES;
}


- (void)registrationStateDidChange:(NSNotification *)notif {
    pjsua_acc_id accountId = [[[notif userInfo] objectForKey:GSSIPAccountIdKey] intValue];
    if (accountId == PJSUA_INVALID_ID || accountId != _accountId)
        return;
    
    GSAccountStatus accStatus;
    
    pjsua_acc_info info;
    pj_status_t status = pjsua_acc_get_info(accountId, &info);
    RETURN_VOID_IF_FAILED(status);

    if (info.reg_last_err != PJ_SUCCESS) {
        accStatus = GSAccountStatusInvalid;
        
    } else {
        pjsip_status_code code = info.status;
        if (code == 0 || (info.online_status == PJ_FALSE)) {
            accStatus = GSAccountStatusOffline;
        } else if (PJSIP_IS_STATUS_IN_CLASS(code, 100)) {
            accStatus = GSAccountStatusConnecting;
        } else if (PJSIP_IS_STATUS_IN_CLASS(code, 200)) {
            accStatus = GSAccountStatusConnected;
        } else {
            accStatus = GSAccountStatusInvalid;
        }
    }
    
    // TODO: Execution order guarantee?
    dispatch_async(dispatch_get_main_queue(), ^{
        [self willChangeValueForKey:@"status"];
        _status = accStatus;
        [self didChangeValueForKey:@"status"];
    });
}

@end
