//
//  RFC3326ReasonParser.c
//  Gossip
//

#include "RFC3326ReasonParser.h"

#import <pjsip/print_util.h>

const pj_str_t pjsip_reason_header_name = {"Reason", 6};

static int pjsip_reason_hdr_print(pjsip_reason_hdr *hdr, char *buf, pj_size_t size);
static pjsip_reason_hdr * pjsip_reason_hdr_clone( pj_pool_t *pool, const pjsip_reason_hdr *hdr);
static pjsip_reason_hdr * pjsip_reason_hdr_shallow_clone( pj_pool_t *pool, const pjsip_reason_hdr *hdr);

static pjsip_hdr_vptr reason_hdr_vptr =
{
    (pjsip_hdr_clone_fptr) &pjsip_reason_hdr_clone,
    (pjsip_hdr_clone_fptr) &pjsip_reason_hdr_shallow_clone,
    (pjsip_hdr_print_fptr) &pjsip_reason_hdr_print,
};

PJ_DEF(pjsip_reason_hdr *) pjsip_reason_hdr_init(pj_pool_t *pool, void *mem) {
    pjsip_reason_hdr *hdr = (pjsip_reason_hdr *)mem;
    
    PJ_UNUSED_ARG(pool);
    
    pj_bzero(mem, sizeof(pjsip_reason_hdr));
    init_hdr(hdr, PJSIP_H_OTHER, &reason_hdr_vptr);
    return hdr;
}

PJ_DEF(pjsip_reason_hdr *) pjsip_reason_hdr_create(pj_pool_t *pool) {
    void *mem = pj_pool_alloc(pool, sizeof(pjsip_cseq_hdr));
    return pjsip_reason_hdr_init(pool, mem);
}

/// TODO: This implementation is untested
static int pjsip_reason_hdr_print(pjsip_reason_hdr *hdr, char *buf, pj_size_t size) {
    int returnVal = snprintf(buf, size, "Reason: %s;cause=%lu;text=\"%s\"", hdr->reason.ptr, hdr->cause, hdr->text.ptr);

    if (returnVal < 0) {
        PJ_LOG(3, ("RFC3326ReasonParser", "Error in pjspip_reason_hdr_print"));
    }
    
    return returnVal;
}

static pjsip_reason_hdr * pjsip_reason_hdr_clone(pj_pool_t *pool, const pjsip_reason_hdr *rhs) {
    pjsip_reason_hdr *hdr = pjsip_reason_hdr_create(pool);
    
    hdr->type = rhs->type;
    hdr->name = rhs->name;
    hdr->sname = rhs->sname;
    
    hdr->cause = rhs->cause;
    pj_strdup(pool, &hdr->reason, &rhs->reason);
    pj_strdup(pool, &hdr->text, &rhs->text);
    return hdr;
}

static pjsip_reason_hdr * pjsip_reason_hdr_shallow_clone(pj_pool_t *pool, const pjsip_reason_hdr *rhs) {
    pjsip_reason_hdr *hdr = PJ_POOL_ALLOC_T(pool, pjsip_reason_hdr);
    pj_memcpy(hdr, rhs, sizeof(*hdr));
    return hdr;
}

/* Case insensitive comparison */
#define parser_stricmp(s1, s2) (s1.slen!=s2.slen || pj_stricmp_alnum(&s1, &s2))

/* Parse Reason header. */
PJ_DEF(pjsip_hdr *) parse_hdr_reason(pjsip_parse_ctx *ctx) {
    // "Reason: SIP;cause=200;text="Answered elsewhere"\r\n\r\n"
    // Once the header is parsed you get this: "SIP;cause=200;text=\"Answered elsewhere\"\r\n\r\n"
    pj_scanner *scanner = ctx->scanner;
    pjsip_reason_hdr *hdr = pjsip_reason_hdr_create(ctx->pool);
    
    // Scan 'Reason: SIP;'
    pj_scan_get_until_ch(scanner, ';', &hdr->reason);
    pj_strrtrim(&hdr->reason);
    
    if (*scanner->curptr == ';' && !pj_scan_is_eof(scanner)) {
        pj_scan_advance_n(scanner, 1, PJ_TRUE);
    }
    
    // Scan list key=value; fields
    // This can be turned into a struct if more headers are needed
    static const pj_str_t keyCause = {"cause", 5};
    static const pj_str_t keyText = {"text", 4};
    
    pj_str_t key;
    pj_str_t value;
    while (!pj_scan_is_eof(scanner)) {
        pj_scan_get_until_ch(scanner, '=', &key);
        pj_strrtrim(&key);
        
        if (*scanner->curptr == '=' && !pj_scan_is_eof(scanner)) {
            pj_scan_advance_n(scanner, 1, PJ_TRUE);
        }
        
        if (!key.slen) {
            continue;
        }
        
        if (parser_stricmp(key, keyCause) == 0) {
            pj_scan_get_until_ch(scanner, ';', &value);
            if (!value.slen) {
                continue;
            }
            
            pj_strrtrim(&value);
            hdr->cause = pj_strtoul(&value);
            
            if (*scanner->curptr == ';' && !pj_scan_is_eof(scanner)) {
                pj_scan_advance_n(scanner, 1, PJ_TRUE);
            }
        } else if (parser_stricmp(key, keyText) == 0) {
            pj_scan_get_quote(scanner, '"', '"', &value);
            
            if (!value.slen) {
                continue;
            }
            
            /* Remove the quotes */
            value.ptr++;
            value.slen -= 2;
            
            pj_strrtrim(&value);
            hdr->text = value;
            
            if (*scanner->curptr == ';' && !pj_scan_is_eof(scanner)) {
                pj_scan_advance_n(scanner, 1, PJ_TRUE);
            }
        } else {
            pj_scan_get_newline(scanner);
        }
    }
    
    return (pjsip_hdr *)hdr;
}
