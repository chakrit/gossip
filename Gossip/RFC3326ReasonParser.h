//
//  RFC3326ReasonParser.h
//  Gossip
//

#import "PJSIP.h"

/**
 * Reason header.
 */
typedef struct pjsip_reason_hdr
{
    PJSIP_DECL_HDR_MEMBER(struct pjsip_reason_hdr);
    pj_str_t            reason; /**< Reason text. */
    unsigned long       cause;  /**< Cause code. */
    pj_str_t            text;   /**< Text. */
} pjsip_reason_hdr;

extern const pj_str_t pjsip_reason_header_name;
extern pjsip_hdr * parse_hdr_reason(pjsip_parse_ctx *ctx);
