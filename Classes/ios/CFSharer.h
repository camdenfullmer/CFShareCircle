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

@interface CFSharer : NSObject

@property NSString *name;
@property UIImage *image;

/**
 Initialize a custom sharer with the name that will be presented when hovering over and the name of the image.
 */
- (id)initWithName:(NSString *)name imageName:(NSString *)imageName;

+ (CFSharer *)mail;
+ (CFSharer *)cameraRoll;
+ (CFSharer *)dropbox;
+ (CFSharer *)evernote;
+ (CFSharer *)facebook;
+ (CFSharer *)googleDrive;
+ (CFSharer *)pinterest;
+ (CFSharer *)twitter;
+ (CFSharer *)airPrint;

@end
