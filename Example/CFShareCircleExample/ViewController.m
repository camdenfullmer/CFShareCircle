//
//  ViewController.m
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) CFShareCircleView *shareCircleView;

@end

@implementation ViewController

- (void)viewDidLoad {    
	// Do any additional setup after loading the view, typically from a nib.
    self.shareCircleView = [[CFShareCircleView alloc] init];
    self.shareCircleView.delegate = self;
    [super viewDidLoad];
}

- (void)shareCircleView:(CFShareCircleView *)aShareCircleView didSelectSharer:(CFSharer *)sharer {
    NSLog(@"Selected sharer: %@", sharer.name);
}

- (void)shareCircleCanceled: (NSNotification*)notification{ 
    NSLog(@"Share circle view was canceled.");
}

- (IBAction)shareButtonClicked:(id)sender {
    [self.shareCircleView show];
}
@end
