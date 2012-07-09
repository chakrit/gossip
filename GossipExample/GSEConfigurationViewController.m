//
//  GSEConfigurationViewController.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSEConfigurationViewController.h"
#import "Gossip.h"
#import "GSEMenuViewController.h"


@interface GSEConfigurationViewController () <UITableViewDataSource, UITableViewDelegate> @end


@implementation GSEConfigurationViewController {
//    UITableView *_tableView;
    NSArray *_testAccounts;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _testAccounts = nil;
        [self loadTestAccounts];
    }
    return self;
}

- (void)loadTestAccounts {
    NSMutableArray *accounts = [NSMutableArray arrayWithCapacity:2];
    
    GSAccountConfiguration *account = [GSAccountConfiguration defaultConfiguration];
    account.address = @"chakrit@getonsip.com";
    account.username = @"getonsip_chakrit";
    account.password = @"3WLDiLdLaUQiA5rr";
    account.domain = @"getonsip.com";
    account.proxyServer = @"sip.onsip.com";
    [accounts addObject:account];
    
    account = [account copy];
    account.address = @"chakrit2@getonsip.com";
    account.username = @"getonsip_chakrit2";
    account.password = @"RsbRokgpDZcbmuBT";
    [accounts addObject:account];
    
    _testAccounts = [NSArray arrayWithArray:accounts];
}

- (void)loadView {
    CGRect frame = CGRectMake(0, 0, 320, 480);
    
    UITableView *tableView = [UITableView alloc];
    tableView = [tableView initWithFrame:frame style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    UIView *container = [[UIView alloc] init];
    [container addSubview:tableView];
    [self setView:container];
}

- (void)dealloc {
    _testAccounts = nil;
}


- (NSString *)title {
    return @"Account";
}


- (void)userDidSelectAccount:(GSAccountConfiguration *)accountConfig {
    GSConfiguration *configuration = [GSConfiguration defaultConfiguration];
    configuration.account = accountConfig;
    
    GSUserAgent *agent = [GSUserAgent sharedAgent];
    [agent configure:configuration];
    [agent start];
    
    GSEMenuViewController *menu = [[GSEMenuViewController alloc] init];
    menu.account = agent.account; // only one account supported, for now.
    [[self navigationController] pushViewController:menu animated:YES];
}


#pragma mark - UITableViewDatasource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [_testAccounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kCellId = @"sip_account";
    
    NSInteger row = [indexPath row];
    if (row < 0 || row == [_testAccounts count])
        return nil;
    
    // build table cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (!cell) {
        cell = [UITableViewCell alloc];
        cell = [cell initWithStyle:UITableViewCellStyleDefault
                   reuseIdentifier:kCellId];
    }
    
    GSAccountConfiguration *account = [_testAccounts objectAtIndex:row];
    [[cell textLabel] setText:account.address];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    if (row < 0 || row == [_testAccounts count])
        return;
    
    GSAccountConfiguration *account = [_testAccounts objectAtIndex:row];
    [self userDidSelectAccount:account];
}

@end
