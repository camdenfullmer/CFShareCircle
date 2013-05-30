//
//  ViewController.m
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {    
	// Do any additional setup after loading the view, typically from a nib.
    shareCircleView = [[CFShareCircleView alloc] initWithFrame:self.view.frame];
    shareCircleView.delegate = self;
    [self.navigationController.view addSubview:shareCircleView];    
    [super viewDidLoad];
}

- (void)shareCircleView:(CFShareCircleView *)aShareCircleView didSelectSharer:(CFSharer *)sharer {
    NSLog(@"Selected sharer: %@", sharer.name);
}

- (void)shareCircleCanceled: (NSNotification*)notification{ 
    NSLog(@"Share circle view was canceled.");
}


- (IBAction)shareButtonClicked:(id)sender {
    [shareCircleView animateIn];
}
@end
