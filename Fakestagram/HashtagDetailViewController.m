//
//  HashtagDetailViewController.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/13/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "HashtagDetailViewController.h"
#import "ImagePost.h"
#import <Parse/Parse.h>
#import "HomeCollectionViewCell.h"


@interface HashtagDetailViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSArray *hashtagImages;

@end

@implementation HashtagDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadHashtagImages];

}

-(void)loadHashtagImages {
    PFQuery *query = [PFQuery queryWithClassName:@"ImagePost"];
    [query whereKey:@"hashtag" equalTo:self.hashtag];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        self.hashtagImages = objects;
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.hashtagImages.count;

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"hashtagCell" forIndexPath:indexPath];
    ImagePost *imagePost = self.hashtagImages[indexPath.item];

    PFUser *user = [imagePost objectForKey:@"poster"];
    cell.labelForUserName.text = user.username;
    cell.hashtag.text = [imagePost objectForKey:@"hashtag"];

    [cell.imagePost.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [cell.imagePost.layer setBorderWidth: 1.0];
    [cell.layer setMasksToBounds:NO];
    [cell.layer setShadowOffset:CGSizeMake(0, 1)];
    [cell.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [cell.layer setShadowRadius:14.0];
    [cell.layer setShadowOpacity:0.5];
    [self getPictureFromImagePost:imagePost withCompletion:^(UIImage *image) {
         cell.imagePost.image = image;
     }];
    
    return cell;
}

-(void)getPictureFromImagePost:(ImagePost *)imagePost withCompletion:(void(^)(UIImage *image))complete {
    PFFile *photoFile = imagePost.photoFile;
    [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

        if (error == nil) {
            UIImage *image = [UIImage imageWithData:data];
            complete(image);
        }
    }];

}

@end
