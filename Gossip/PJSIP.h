//
//  PJSIP.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/5/12.
//

/// Shim for loading PJSIP stuff with all the required #defines

// NOTE: Must be placed *before* any pjsip stuff.
#ifndef PJ_IS_LITTLE_ENDIAN
#define PJ_IS_LITTLE_ENDIAN 1
#endif

#ifndef PJ_IS_BIG_ENDIAN
#define PJ_IS_BIG_ENDIAN 0
#endif

#import <pj/config_site.h>

// Place any requried PJSIP includes/imports *below* this line
#import <pj/types.h>
#import <pjsip/sip_errno.h>
#import <pjsua-lib/pjsua.h>

