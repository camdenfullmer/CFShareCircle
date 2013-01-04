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
    shareCircleView = [[CFShareCircleView alloc] init];
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

- (void)shareCircleView:(CFShareCircleView *)aShareCircleView didSelectIndex:(int)index{
    NSLog(@"Selected index: %d", index);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [shareCircleView setFrame:CGRectMake(320, 0, 320, 480)];
    [UIView commitAnimations];
}

-(void)shareCircleViewWasCanceled{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [shareCircleView setFrame:CGRectMake(320, 0, 320, 480)];
    [UIView commitAnimations];
}

- (IBAction)shareButtonClicked:(id)sender {
    [shareCircleView setFrame:CGRectMake(320, 0, 320, 480)];
    [shareCircleView setBounds:CGRectMake(0, 0, 320, 480)];
    
    shareCircleView.hidden = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [shareCircleView setFrame:CGRectMake(0, 0, 320, 480)];
    [UIView commitAnimations];
}
@end
