//
//  OtherPeoplesProfileViewController.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/11/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "OtherPeoplesProfileViewController.h"
#import "HomeCollectionViewCell.h"
#import <Parse/Parse.h>
#import "ImagePost.h"
#import "OtherUsersCommentsTVC.h"

@interface OtherPeoplesProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, HomeCollectionViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property NSArray *photos;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property BOOL isFollowed;
@property (weak, nonatomic) IBOutlet UIImageView *otherProfileImage;



@end

@implementation OtherPeoplesProfileViewController

#pragma mark - VC and life-cycle 


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUser];
    [self loadProfileImage];


}

-(void)loadUser {

    self.title = [self.user objectForKey:@"username"];

    PFQuery *query = [PFQuery queryWithClassName:@"ImagePost"];
    [query whereKey:@"poster" equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        self.photos = objects;
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }];

    
    PFUser *user = [PFUser currentUser];

    PFRelation *following = [user relationForKey:@"following"];
    PFQuery *queryTwo = [following query];

    [queryTwo findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if ([objects containsObject:self.user]) {
            [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
            self.isFollowed = YES;
        } else {
            [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
            [self.followButton setBackgroundColor:[UIColor blueColor]];
            self.isFollowed = NO;
        }

    }];
}

-(void)loadProfileImage {

    if ([self.user objectForKey:@"profilePhoto"]) {

        PFFile *photoFile = [self.user objectForKey:@"profilePhoto"];
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

            if (error == nil) {
                UIImage *image = [UIImage imageWithData:data];
                self.otherProfileImage.image = image;
            }
        }];

    } else {

        self.otherProfileImage.image = [UIImage imageNamed:@"seahorse.png"];
        
    }

    
}


#pragma mark - Helper Method 

-(void)getPictureFromImagePost:(ImagePost *)imagePost withCompletion:(void(^)(UIImage *image))complete {
    PFFile *photoFile = imagePost.photoFile;
    [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

        if (error == nil) {
            UIImage *image = [UIImage imageWithData:data];
            complete(image);
        }
    }];

}


#pragma mark - Button methods

- (IBAction)followButtonPressed:(UIButton *)sender {

    if (self.isFollowed) {
        PFUser *user = [PFUser currentUser];
        PFRelation *relation = [user relationForKey:@"following"];
        [relation removeObject:self.user];
        [user saveInBackground];
        self.isFollowed = NO;
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followButton setBackgroundColor:[UIColor blueColor]];


    } else {
        PFUser *user = [PFUser currentUser];
        PFRelation *relation = [user relationForKey:@"following"];
        [relation addObject:self.user];
        [user saveInBackground];
        self.isFollowed = YES;
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
        [self.followButton setBackgroundColor:[UIColor greenColor]];
    }


}


#pragma mark - Collection View Delegate Methods 


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OtherProfileCell" forIndexPath:indexPath];
    cell.delegate = self;

    [cell.userNameLabel setTitle:@"" forState:UIControlStateNormal];

    ImagePost *imagePost = self.photos[indexPath.item];

    NSMutableArray *usersWhoLiked = [imagePost objectForKey:@"usersWhoLiked"] ?: [NSMutableArray new];

    if ([usersWhoLiked containsObject:[PFUser currentUser]]) {
        [cell.likeButton setImage:[UIImage imageNamed:@"star-filled"] forState:UIControlStateNormal];

    } else {

        [cell.likeButton setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    }

    [self getPictureFromImagePost:imagePost withCompletion:^(UIImage *image) {

        cell.imagePost.image = image;
        
    }];

    NSString *hashtag = [imagePost objectForKey:@"hashtag"];
    if (hashtag) {

        if ([hashtag hasPrefix:@"#"] || [hashtag isEqualToString:@""] ) {
            cell.hashtag.text = hashtag;
        } else {
            cell.hashtag.text = [NSString stringWithFormat:@"#%@", hashtag];
        }
    } else {
        cell.hashtag.text = @"";
    }
    return cell;
}

#pragma mark - Collection View Cell Delegate 


-(UIImage *)homeCollectionViewCell:(HomeCollectionViewCell *)HomeCollectionViewCell {

    NSIndexPath *indexPath = [self.collectionView indexPathForCell:HomeCollectionViewCell];
    ImagePost *imagePost = self.photos[indexPath.item];

    NSMutableArray *usersWhoLiked = [imagePost objectForKey:@"usersWhoLiked"] ?: [NSMutableArray new];

    if ([usersWhoLiked containsObject:[PFUser currentUser]]) {
        [usersWhoLiked removeObject:[PFUser currentUser]];
        [imagePost setObject:usersWhoLiked forKey:@"usersWhoLiked"];
        [imagePost saveInBackground];

        return [UIImage imageNamed:@"star"];

    } else {

        [usersWhoLiked addObject:[PFUser currentUser]];
        [imagePost setObject:usersWhoLiked forKey:@"usersWhoLiked"];
        [imagePost saveInBackground];

        return [UIImage imageNamed:@"star-filled"];
    }
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    OtherUsersCommentsTVC *tVC = segue.destinationViewController;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)[[sender superview] superview]];
    ImagePost *imagePost = self.photos[indexPath.item];
    tVC.iP = imagePost;

}

@end
