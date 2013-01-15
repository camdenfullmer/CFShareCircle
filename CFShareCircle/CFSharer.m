//
//  Sharer.m
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import "CFSharer.h"

@implementation CFSharer

@synthesize name;

- (id) initWithName:(NSString*)aName{
    self = [super init];
    if (self) {
        [self setName:aName];
    }
    return self;    
}

- (UIImage*)mainImage {
    NSString *temp = [[NSString alloc] initWithString:name];
    // Replace spaces with underscores.
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    // Add .png to the end.
    temp = [temp stringByAppendingPathExtension:@"png"];
    // Convert to lowercase
    
    return [UIImage imageNamed:[temp lowercaseString]];
}

- (UIImage*)titleImage{
    NSString *temp = [[NSString alloc] initWithString:name];
    // Replace spaces with underscores.
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    // Add "_title" to the end.
    temp = [temp stringByAppendingString:@"_title"];
    // Add .png to the end.
    temp = [temp stringByAppendingPathExtension:@"png"];
    // Convert to lowercase
    return [UIImage imageNamed:[temp lowercaseString]];
}

@end
