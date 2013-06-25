//
//  GSEConfigurationViewController.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSEConfigurationViewController.h"
#import "Gossip.h"
#import "GSECodecsViewController.h"
#import "GSEMenuViewController.h"


@interface GSEConfigurationViewController () <UITableViewDataSource, UITableViewDelegate> @end


@implementation GSEConfigurationViewController {
    UITableView *_tableView;
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
    
    account = [GSAccountConfiguration defaultConfiguration];
    account.address = @"chakrit@sip2sip.info";
    account.username = @"chakrit";
    account.password = @"tyixr52w9k";
    account.domain = @"sip2sip.info";
    account.authRealm = @"sip2sip.info";
    account.proxyServer = @"proxy.sipthor.net";
    [accounts addObject:account];
    
    account = [GSAccountConfiguration defaultConfiguration];
    account.address = @"1664470@sipgate.co.uk";
    account.username = @"1664470";
    account.password = @"N34TYU8M";
    account.domain = @"sipgate.co.uk";
    account.proxyServer = @"sipgate.co.uk";
    [accounts addObject:account];
    
    _testAccounts = [NSArray arrayWithArray:accounts];
}

- (void)dealloc {
    _testAccounts = nil;
}


- (NSString *)title {
    return @"Account";
}


- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    _tableView = [UITableView alloc];
    _tableView = [_tableView initWithFrame:frame style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    UIView *container = [[UIView alloc] init];
    [container setFrame:frame];
    [container addSubview:_tableView];
    [self setView:container];
}

- (void)viewDidAppear:(BOOL)animated {
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}


- (void)userDidSelectAccount:(GSAccountConfiguration *)accountConfig {
    GSConfiguration *configuration = [GSConfiguration defaultConfiguration];
    configuration.account = accountConfig;
    configuration.logLevel = 3;
    configuration.consoleLogLevel = 3;
    
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
