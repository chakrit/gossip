//
//  GSEMenuViewController.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSEMenuViewController.h"
#import "Gossip.h"
#import "GSECallInitController.h"
#import "GSECallViewController.h"
#import "GSECodecsViewController.h"


@interface GSEMenuViewController () <GSAccountDelegate, UIAlertViewDelegate> @end


@implementation GSEMenuViewController {
    GSECallInitController *_callInit;
    GSCall *_incomingCall;
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
        _incomingCall = nil;
    }
    return self;
}

- (void)dealloc {
    [_account removeObserver:self forKeyPath:@"status"];
    _account = nil;
    
    _callInit = nil;
    _incomingCall = nil;
    
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
    _account.delegate = self;
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


- (void)userDidTapCodecs {
    GSECodecsViewController *controller = [GSECodecsViewController alloc];
    controller = [controller init];
    
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)userDidTapUseG729 {
    GSUserAgent *agent = [GSUserAgent sharedAgent];
    NSArray *codecs = [agent arrayOfAvailableCodecs];
    for (GSCodecInfo *codec in codecs) {
        if (![codec.codecId hasPrefix:@"G729"]) {
            NSLog(@"Disabling: %@", codec.codecId);
            [codec disable];
        } else {
            NSLog(@"Maximizing: %@", codec.codecId);
            [codec setPriority:254];
        }
    }
}


- (IBAction)userDidTapConnect {
    [_account connect];
}

- (IBAction)userDidTapDisconnect {
    [_account disconnect];
}

- (IBAction)userDidTapSwitchAccount:(id)sender {
    [[GSUserAgent sharedAgent] reset];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)userDidTapMakeCall {
    if (!_callInit) {
        _callInit = [[GSECallInitController alloc] init];
        _callInit.navigationController = [self navigationController];
    }
    
    [_callInit makeNewCall];
}


- (void)userDidPickupCall {
    GSECallViewController *controller = [[GSECallViewController alloc] init];
    controller.call = _incomingCall;
    
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)userDidDenyCall {
    [_incomingCall end];
    _incomingCall = nil;
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
            
        case GSAccountStatusDisconnecting: {
            [_statusLabel setText:@"Disconnecting..."];
            [_connectButton setEnabled:NO];
            [_disconnectButton setEnabled:NO];
            [_makeCallButton setEnabled:NO];
        } break;
            
        case GSAccountStatusInvalid: {
            [_statusLabel setText:@"Invalid account info."];
            [_connectButton setEnabled:YES];
            [_disconnectButton setEnabled:NO];
            [_makeCallButton setEnabled:NO];
        } break;
    }
}


#pragma mark - GSAccountDelegate

- (void)account:(GSAccount *)account didReceiveIncomingCall:(GSCall *)call {
    _incomingCall = call;
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setAlertViewStyle:UIAlertViewStyleDefault];
    [alert setDelegate:self];
    [alert setTitle:@"Incoming call."];
    [alert addButtonWithTitle:@"Deny"];
    [alert addButtonWithTitle:@"Answer"];
    [alert setCancelButtonIndex:0];
    [alert show];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        [self userDidDenyCall];
    } else {
        [self userDidPickupCall];
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"])
        [self statusDidChange];
}

@end
