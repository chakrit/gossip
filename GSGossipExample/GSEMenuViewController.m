//
//  GSEMenuViewController.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSEMenuViewController.h"
#import "GSECallInitController.h"


@implementation GSEMenuViewController {
    GSECallInitController *_callInit;
}

@synthesize account = _account;

@synthesize statusLabel = _statusLabel;
@synthesize connectButton = _connectButton;
@synthesize disconnectButton = _disconnectButton;
@synthesize makeCallButton = _makeCallButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _account = nil;
        _callInit = nil;
    }
    return self;
}

- (void)dealloc {
    self.account = nil;
    _callInit = nil;
    
    _statusLabel = nil;
    _connectButton = nil;
    _disconnectButton = nil;
    _makeCallButton = nil;
}


- (NSString *)title {
    return @"Menu";
}

- (void)setAccount:(GSAccount *)account {
    [self willChangeValueForKey:@"account"];
    [_account removeObserver:self forKeyPath:@"status"];
    _account = account;
    [_account addObserver:self
               forKeyPath:@"status"
                  options:NSKeyValueObservingOptionInitial
                  context:nil];
    [self didChangeValueForKey:@"account"];
}


- (void)viewDidLoad {
    [[self navigationItem] setHidesBackButton:YES];
    [_account addObserver:self
               forKeyPath:@"status"
                  options:NSKeyValueObservingOptionInitial
                  context:nil];
}


- (IBAction)userDidTapConnect {
    [_account connect];
}

- (IBAction)userDidTapDisconnect {
    [_account disconnect];
}

- (IBAction)userDidTapMakeCall {
    if (!_callInit) {
        _callInit = [[GSECallInitController alloc] init];
        _callInit.navigationController = [self navigationController];
    }
    
    [_callInit makeNewCall];
}


- (void)statusDidChange {
    switch (_account.status) {
        case GSAccountStatusOffline: {
            [_statusLabel setText:@"Offline."];
            [_connectButton setEnabled:YES];
            [_disconnectButton setEnabled:NO];
            [_makeCallButton setEnabled:NO];
        } break;
            
        case GSAccountStatusConnecting: {
            [_statusLabel setText:@"Connecting..."];
            [_connectButton setEnabled:NO];
            [_disconnectButton setEnabled:NO];
            [_makeCallButton setEnabled:NO];
        } break;
            
        case GSAccountStatusConnected: {
            [_statusLabel setText:@"Connected."];
            [_connectButton setEnabled:NO];
            [_disconnectButton setEnabled:YES];
            [_makeCallButton setEnabled:YES];
        } break;
            
        case GSAccountStatusInvalid: {
            [_statusLabel setText:@"Invalid account info."];
            [_connectButton setEnabled:YES];
            [_disconnectButton setEnabled:NO];
            [_makeCallButton setEnabled:NO];
        } break;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"])
        [self statusDidChange];
}

@end
