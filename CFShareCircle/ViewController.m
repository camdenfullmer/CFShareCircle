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
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //shareCircleView = [[CFShareCircleView alloc] init];
    shareCircleView = [[CFShareCircleView alloc] initWithImageFileNames:[[NSArray alloc] initWithObjects:@"evernote.png", @"googleplus.png", @"facebook.png", @"twitter.png", @"email.png", nil]];
    shareCircleView.delegate = self;
    [self.navigationController.view addSubview:shareCircleView];
}

- (void)viewWillAppear:(BOOL)animated{
    shareCircleView.frame = self.navigationController.view.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareCircleView:(CFShareCircleView *)shareCircleView didSelectIndex:(int)index{
    NSLog(@"Selected index: %d", index);
}
- (IBAction)shareButtonClicked:(id)sender {
    [shareCircleView setHidden:NO];
}
@end
