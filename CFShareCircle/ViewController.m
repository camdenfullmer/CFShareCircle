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

- (void)viewDidLoad
{    
	// Do any additional setup after loading the view, typically from a nib.
    shareCircleView = [[CFShareCircleView alloc] init];
    shareCircleView.delegate = self;
    [self.navigationController.view addSubview:shareCircleView];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareCircleView:(CFShareCircleView *)aShareCircleView didSelectIndex:(int)index{
    NSLog(@"Selected index: %d", index);
}

- (void)shareCircleCanceled: (NSNotification*)notification{
    NSLog(@"Share circle view was canceled.");
}


- (IBAction)shareButtonClicked:(id)sender {
    [shareCircleView animateIn];
}
@end
