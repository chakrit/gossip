//
//  GSECodecsViewController.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/13/12.
//

#import "GSECodecsViewController.h"
#import "Gossip.h"


@interface GSECodecsViewController () <UITableViewDataSource, UITableViewDelegate> @end


@implementation GSECodecsViewController {
    NSArray *_codecs;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _codecs = [[GSUserAgent sharedAgent] arrayOfAvailableCodecs];
    }
    return self;
}

- (void)loadView {
    UITableView *tableView = [UITableView alloc];
    tableView = [tableView initWithFrame:CGRectMake(0, 0, 320, 480)
                                   style:UITableViewStyleGrouped];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:tableView];
    [self setView:view];
}

- (void)dealloc {
    _codecs = nil;
}


- (NSString *)title {
    return @"Codecs";
}


#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_codecs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const CellId = @"codec";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (!cell) {
        cell = [UITableViewCell alloc];
        cell = [cell initWithStyle:UITableViewCellStyleValue1
                   reuseIdentifier:CellId];
    }
    
    GSCodecInfo *codec = [_codecs objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:codec.codecId];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterBehaviorDefault];
    [formatter setLocale:[NSLocale systemLocale]];
    
    NSNumber *priorityNum = [NSNumber numberWithUnsignedInteger:codec.priority];
    NSString *priorityStr = [formatter stringFromNumber:priorityNum];    
    [[cell detailTextLabel] setText:priorityStr];    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                           animated:YES
                     scrollPosition:UITableViewScrollPositionNone];
    
    GSCodecInfo *codec = [_codecs objectAtIndex:[indexPath row]];
    [codec disable];    
    [tableView reloadData];
}


@end
