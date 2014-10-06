//
//  PJSIP.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/5/12.
//

/// Shim for loading PJSIP stuff with all the required #defines
#import "TargetConditionals.h"

// NOTE: Must be placed *before* any pjsip stuff.
#ifndef PJ_IS_LITTLE_ENDIAN
#define PJ_IS_LITTLE_ENDIAN 1
#endif

#ifndef PJ_IS_BIG_ENDIAN
#define PJ_IS_BIG_ENDIAN 0
#endif

#ifndef PJMEDIA_HAS_VIDEO
#define PJMEDIA_HAS_VIDEO 0
#endif

// Workaround buggy PJSIP arch detection logic when building for the phone. Simulator builds seems
// to be okay.
#ifndef PJ_HAS_PENTIUM
#  ifdef TARGET_IPHONE_SIMULATOR
#    define PJ_M_X86_64
#  else
#    define PJ_M_ARMV4 1
#  endif
#endif

// COMPAT: Uncomment to fix darwin typedef conflict w/ PJSIP socklen_t when linking against ios5.1
//#ifndef _SOCKLEN_T
//#define _SOCKLEN_T 1
//#endif
#import <pj/config_site.h>

// Place any required PJSIP includes/imports *below* this line
#import <pjsip/sip_transport_tls.h>
#import <pjsip/sip_multipart.h>
#import <pjsua-lib/pjsua.h>
#import <pj/types.h>
#import <pj/string.h>
#import <pjsip/sip_errno.h>
#import <pjmedia/format.h>
#import <pjsip/sip_endpoint.h>
