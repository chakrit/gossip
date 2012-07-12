//
//  GSERootViewController.m
//  Gossip
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSERootViewController.h"
#import "GSEConfigurationViewController.h"


@interface GSERootViewController () <UINavigationControllerDelegate> @end


@implementation GSERootViewController {
    UINavigationController *_nav;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        GSEConfigurationViewController *root = nil;
        root = [[GSEConfigurationViewController alloc] init];
        
        _nav = [[UINavigationController alloc] initWithRootViewController:root];
        [_nav setDelegate:self];
    }
    return self;
}

- (void)dealloc {
    _nav = nil;
}


- (void)viewDidLoad {
    [self addChildViewController:_nav];
    [[self view] addSubview:[_nav view]];
}


// nothing to do for UINavigationController yet.

@end
