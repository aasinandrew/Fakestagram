//
//  ImagePost.h
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/11/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface ImagePost : PFObject <PFSubclassing>

@property PFFile *photoFile;
@property NSMutableArray *comments;
@property PFUser *poster;
@property NSString *hashtag;
@property NSMutableArray *usersWhoLiked;


@end
