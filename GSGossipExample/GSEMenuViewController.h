//
//  GSEMenuViewController.h
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//


@interface GSEMenuViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

- (IBAction)userDidTapConnect;
- (IBAction)userDidTapDisconnect;
- (IBAction)userDidTapMakeCall;

@end
