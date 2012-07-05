//
//  NSError+pj_status_t.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/5/12.
//


@interface NSError (PJSIP)

+ (id)errorWithSIPStatus:(pj_status_t)status;

@end
