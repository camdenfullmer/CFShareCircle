//
//  Sharer.m
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import "CFSharer.h"

@implementation CFSharer

@synthesize name = _name;
@synthesize image = _image;

- (id)initWithName:(NSString *)name imageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        _name = name;
        _image = [UIImage imageNamed:imageName];
    }
    return self;    
}

+ (CFSharer *)mail {
    return [[CFSharer alloc] initWithName:@"Mail" imageName:@"mail.png"];
}

+ (CFSharer *)cameraRoll {
    return [[CFSharer alloc] initWithName:@"Camera Roll" imageName:@"camera_roll.png"];
}

+ (CFSharer *)dropbox {
    return [[CFSharer alloc] initWithName:@"Dropbox" imageName:@"dropbox.png"];
}

+ (CFSharer *)evernote {
    return [[CFSharer alloc] initWithName:@"Evernote" imageName:@"evernote.png"];
}

+ (CFSharer *)facebook {
    return [[CFSharer alloc] initWithName:@"Facebook" imageName:@"facebook.png"];
}

+ (CFSharer *)googleDrive {
    return [[CFSharer alloc] initWithName:@"Google Drive" imageName:@"google_drive.png"];
}

+ (CFSharer *)pinterest {
    return [[CFSharer alloc] initWithName:@"Pinterest" imageName:@"pinterest.png"];
}

+ (CFSharer *)twitter {
    return [[CFSharer alloc] initWithName:@"Twitter" imageName:@"twitter.png"];
}

+ (CFSharer *)airPrint {
    return [[CFSharer alloc] initWithName:@"AirPrint" imageName:@"print.png"];
}

@end
