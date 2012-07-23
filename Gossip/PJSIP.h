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

// fix darwin typedef conflict w/ PJSIP socklen_t when linking against ios5.1
#ifndef _SOCKLEN_T
#define _SOCKLEN_T 1
#endif

#define PJMEDIA_HAS_VIDEO 1
#import <pj/config_site.h>

// Place any requried PJSIP includes/imports *below* this line
#import <pjsip/sip_transport_tls.h>
#import <pjsip/sip_multipart.h>
#import <pjsua-lib/pjsua.h>
#import <pj/types.h>
#import <pj/string.h>
#import <pjsip/sip_errno.h>
#import <pjmedia/format.h>
