//
//  CFShareCircleView.h
//  CFShareCircle
//
//  Created by Camden on 12/18/12.
//  Copyright (c) 2012 Camden. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CFShareCircleView;

@protocol CFShareCircleViewDelegate
- (void)shareCircleView:(CFShareCircleView *)shareCircleView didSelectIndex:(int)index;
@end

@interface CFShareCircleView : UIView{
    CGPoint _currentPosition;
    CGPoint _origin;
    int _largeRectSize;
    int _smallRectSize;
    int _pathRectSize;
    int _tempRectSize;
    BOOL _dragging;
}

@property (strong, nonatomic) NSMutableArray *items;
@property (assign) id <CFShareCircleViewDelegate> delegate;

@end
