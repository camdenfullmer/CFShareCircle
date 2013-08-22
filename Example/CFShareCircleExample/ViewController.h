//
//  ViewController.h
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFShareCircleView.h"

@interface ViewController : UIViewController <CFShareCircleViewDelegate>

- (IBAction)shareButtonClicked:(id)sender;

@end
