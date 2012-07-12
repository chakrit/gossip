//
//  GSECallInitController.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/9/12.
//

#import "GSECallInitController.h"
#import "GSECallViewController.h"


@interface GSECallInitController () <UIActionSheetDelegate, UIAlertViewDelegate> @end


@implementation GSECallInitController {
    NSString *_address;
    BOOL _addressIsLandline;
}

@synthesize navigationController = _navigationController;

- (id)init {
    if (self = [super init]) {
        _address = nil;
        _addressIsLandline = NO;
    }
    return self;
}

- (void)dealloc {
    _address = nil;
}


- (void)makeNewCall {
    [self showLandlineChoices];
}


- (void)showLandlineChoices {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    [sheet setTitle:@"Select Address Type"];
    [sheet setDelegate:self];
    [sheet addButtonWithTitle:@"Landline Number"];
    [sheet addButtonWithTitle:@"SIP Address"];
    [sheet addButtonWithTitle:@"Cancel"];
    [sheet setCancelButtonIndex:2];
    [sheet showInView:[_navigationController view]];
}

- (void)showNumberPrompt {
    UIAlertView *alertView = [[UIAlertView alloc] init];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView setTitle:@"Enter Address (or Number)"];
    [[alertView textFieldAtIndex:0] setText:@"chakrit2@getonsip.com"];
    [alertView setDelegate:self];
    [alertView addButtonWithTitle:@"Cancel"];
    [alertView addButtonWithTitle:@"Call"];
    [alertView setCancelButtonIndex:0];
    [alertView show];
}


- (void)userMadeLandlineChoice:(BOOL)isLandline {
    _addressIsLandline = isLandline;
    [self showNumberPrompt];
}

- (void)userDidEnterAddress:(NSString *)address {
    _address = [address copy];
    [self makeTheCall];
}


- (void)makeTheCall {
    // TODO: add call view controller
    GSAccount *account = [GSUserAgent sharedAgent].account;
    GSCall *call = [GSCall outgoingCallToUri:_address fromAccount:account];
    
    GSECallViewController *controller = [[GSECallViewController alloc] init];
    controller.call = call;
    
    [_navigationController pushViewController:controller animated:YES];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex])
        return;
    
    [self userMadeLandlineChoice:(buttonIndex == 0)];
}


#pragma mark - UIAlertViewDelegate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UITextField *textField = [alertView textFieldAtIndex:0];
    return [[textField text] length] > 0;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex])
        return;
    
    [self userDidEnterAddress:[[alertView textFieldAtIndex:0] text]];
}


@end
