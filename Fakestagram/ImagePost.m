//
//  ImagePost.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/11/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "ImagePost.h"


@implementation ImagePost

@dynamic photoFile;
@dynamic comments;


+(void) load {
    [self registerSubclass];
}


+(NSString *)parseClassName {
    return @"ImagePost";
}

@end
