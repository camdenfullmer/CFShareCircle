//
//  Sharer.h
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class CFSharer;

@interface CFSharer : NSObject

@property NSString *name;
@property UIImage *image;

- (id)initWithName:(NSString *)name imageName:(NSString *)imageName;
- (id)initWithType:(NSInteger)type;

@end
