//
//  GSEMenuViewController.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//


@interface GSEMenuViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UIButton *connectButton;
@property (nonatomic, strong) IBOutlet UIButton *disconnectButton;
@property (nonatomic, strong) IBOutlet UIButton *makeCallButton;

- (IBAction)userDidTapConnect;
- (IBAction)userDidTapDisconnect;
- (IBAction)userDidTapMakeCall;

@end
