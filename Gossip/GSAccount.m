//
//  GSAccount.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSAccount.h"


@implementation GSAccount {
    GSAccountConfiguration *_config;
    pjsua_acc_id _accountId;
}

@synthesize status = _status;

- (id)init {
    if (self = [super init]) {
        _status = GSAccountStatusOffline;
        _config = nil;
        _accountId = PJSUA_INVALID_ID;
    }
    return self;
}

- (void)dealloc {
    _accountId = PJSUA_INVALID_ID;
    _config = nil;
}


- (BOOL)configure:(GSAccountConfiguration *)configuration {
    _config = [configuration copy];
    
    pj_status_t status;
    pjsua_acc_config accConfig;
    pjsua_acc_config_default(&accConfig);
    
    accConfig.id = [_config.address PJStringWithSIPPrefix];
    accConfig.reg_uri = [_config.domain PJStringWithSIPPrefix];
    accConfig.register_on_acc_add = PJ_FALSE; // connect manually
    accConfig.publish_enabled = YES;
    
    if (!_config.proxyServer) {
        accConfig.proxy_cnt = 0;
    } else {
        accConfig.proxy_cnt = 1;
        accConfig.proxy[0] = [_config.proxyServer PJStringWithSIPPrefix];
    }

    status = pjsua_acc_add(&accConfig, PJ_TRUE, &_accountId);
    RETURN_NO_IF_FAILED(status);
    
    return YES;
}


- (BOOL)connect {
    pj_status_t status = pjsua_acc_set_registration(_accountId, PJ_TRUE);
    RETURN_NO_IF_FAILED(status);
    
    return YES;
}

- (BOOL)disconnect {
    pj_status_t status = pjsua_acc_set_registration(_accountId, PJ_FALSE);
    RETURN_NO_IF_FAILED(status);
    
    return YES;
}

@end
