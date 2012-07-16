//
//  GSEMenuViewController.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "Gossip.h"


@interface GSEMenuViewController : UIViewController

@property (nonatomic, strong) GSAccount *account;

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UIButton *connectButton;
@property (nonatomic, strong) IBOutlet UIButton *disconnectButton;
@property (nonatomic, strong) IBOutlet UIButton *makeCallButton;

- (IBAction)userDidTapCodecs;
- (IBAction)userDidTapUseG729;

- (IBAction)userDidTapConnect;
- (IBAction)userDidTapDisconnect;
- (IBAction)userDidTapMakeCall;

@end
