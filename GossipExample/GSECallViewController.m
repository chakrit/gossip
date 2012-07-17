//
//  GSECallViewController.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import "GSECallViewController.h"


@implementation GSECallViewController

@synthesize call = _call;

@synthesize statusLabel = _statusLabel;
@synthesize hangupButton = _hangupButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _call = nil;
        _statusLabel = nil;
        _hangupButton = nil;
    }
    return self;
}

- (void)dealloc {
    self.call = nil;
    
    _statusLabel = nil;
    _hangupButton = nil;
}


- (NSString *)title {
    return @"Call";
}

- (void)setCall:(GSCall *)call {
    [self willChangeValueForKey:@"call"];
    [_call removeObserver:self forKeyPath:@"status"];
    _call = call;
    [_call addObserver:self
            forKeyPath:@"status"
               options:NSKeyValueObservingOptionInitial
               context:nil];
    [self didChangeValueForKey:@"call"];
}


- (void)viewDidLoad {
    [[self navigationItem] setHidesBackButton:YES];
    [_hangupButton setEnabled:NO];
    
    // update calling status
    [self callStatusDidChange];
    
    // begin calling after 1s
    const double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    __block GSCall *call_ = _call;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [call_ begin];
    });
}


- (void)userDidTapHangUp {
    [_call end];
}


- (void)callStatusDidChange {
    switch (_call.status) {
        case GSCallStatusReady: {
            [_statusLabel setText:@"Ready."];
            [_hangupButton setEnabled:NO];
        } break;
            
        case GSCallStatusConnecting: {
            [_statusLabel setText:@"Connecting..."];
            [_hangupButton setEnabled:NO];
        } break;
            
        case GSCallStatusCalling: {
            [_statusLabel setText:@"Calling..."];
            [_hangupButton setEnabled:YES];
        } break;
            
        case GSCallStatusConnected: {
            [_statusLabel setText:@"Connected."];
            [_hangupButton setEnabled:YES];
        } break;
            
        case GSCallStatusDisconnected: {
            [_statusLabel setText:@"Disconnected."];
            [_hangupButton setEnabled:YES];
            
            // pop view after 2s
            const double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            
            __block id self_ = self;
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[self_ navigationController] popViewControllerAnimated:YES];
            });
        } break;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"])
        [self callStatusDidChange];
}

@end
