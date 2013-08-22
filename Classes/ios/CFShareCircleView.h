//
//  CFShareCircleView.h
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "CFSharer.h"

@class CFShareCircleView;

@protocol CFShareCircleViewDelegate
- (void)shareCircleView:(CFShareCircleView *)aShareCircleView didSelectSharer:(CFSharer *)sharer;
@end

@interface CFShareCircleView : UIView<UITableViewDelegate, UITableViewDataSource>

@property (assign) id <CFShareCircleViewDelegate> delegate;

- (id)initWithSharers:(NSArray *)sharers;
- (void)show;
- (void)dismissAnimated:(BOOL)animated;

@end
