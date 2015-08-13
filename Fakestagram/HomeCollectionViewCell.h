//
//  HomeCollectionViewCell.h
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/11/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeCollectionViewCellDelegate;


@interface HomeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <HomeCollectionViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imagePost;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *userNameLabel;

@end

@protocol HomeCollectionViewCellDelegate <NSObject>

@optional

-(UIImage *)homeCollectionViewCell:(HomeCollectionViewCell *)HomeCollectionViewCell;

@end
