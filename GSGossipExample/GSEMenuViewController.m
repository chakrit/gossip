//
//  GSEMenuViewController.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSEMenuViewController.h"
#import "Gossip.h"


@implementation GSEMenuViewController {
    GSAccount *_account;
}

@synthesize statusLabel = _statusLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _account = [GSUserAgent sharedAgent].account;
    }
    return self;
}

- (void)dealloc {
    [self unobserveAccount];
    
    _account = nil;
    _statusLabel = nil;
}


- (NSString *)title {
    return @"Menu";
}


- (void)observeAccount {
    [_account addObserver:self
               forKeyPath:@"status"
                  options:NSKeyValueObservingOptionInitial
                  context:nil];
}

- (void)unobserveAccount {
    [_account removeObserver:self forKeyPath:@"status"];
}


- (void)viewDidLoad {
    [[self navigationItem] setHidesBackButton:YES];
    [self observeAccount];
}


- (IBAction)userDidTapConnect {
    [_account connect];
}

- (IBAction)userDidTapDisconnect {
    [_account disconnect];
}

- (IBAction)userDidTapMakeCall {
    // TODO: Show call screen.
}


- (void)statusDidChange {
    NSString *status = nil;
    switch (_account.status) {
        case GSAccountStatusOffline: status = @"offline"; break;
        case GSAccountStatusConnecting: status = @"connecting"; break;
        case GSAccountStatusConnected: status = @"connected"; break;
        case GSAccountStatusInvalid: status = @"invalid"; break;
    }
    
    [_statusLabel setText:status];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"])
        [self statusDidChange];
}

@end
