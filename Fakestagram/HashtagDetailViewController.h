//
//  HashtagDetailViewController.h
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/13/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HashtagDetailViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property NSString *hashtag;

@end
