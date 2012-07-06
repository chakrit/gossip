//
//  GSEMenuViewController.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSEMenuViewController.h"
#import "Gossip.h"


@implementation GSEMenuViewController

@synthesize statusLabel = _statusLabel;

- (void)dealloc {
    _statusLabel = nil;
}


- (NSString *)title {
    return @"Menu";
}


- (void)viewDidLoad {
    [[self navigationItem] setHidesBackButton:YES];
}


- (IBAction)userDidTapConnect {
    GSUserAgent *agent = [GSUserAgent sharedAgent];
    [agent.account connect];
}

- (IBAction)userDidTapDisconnect {
    GSUserAgent *agent = [GSUserAgent sharedAgent];
    [agent.account disconnect];    
}

- (IBAction)userDidTapMakeCall {
    // TODO: Show call screen.
}

@end
