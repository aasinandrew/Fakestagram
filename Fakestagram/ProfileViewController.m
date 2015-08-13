//
//  ProfileViewController.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/10/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "ProfileViewController.h"
#import "YourCommentsTableViewController.h"
#import <Parse/Parse.h>
#import "ImagePost.h"


@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *profileCollectionView;
@property NSMutableArray *photos;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self loadPosts];
}

-(void)loadPosts {
    PFUser *user = [PFUser currentUser];
    self.title = user.username;

    PFQuery *query = [PFQuery queryWithClassName:@"ImagePost"];
    [query whereKey:@"poster" equalTo:user];
    [query orderByDescending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        self.photos = [[NSMutableArray alloc] initWithArray:objects];

        [self.profileCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }];
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


#pragma mark - collectionView Delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YourProfileCell" forIndexPath:indexPath];

    cell.delegate = self;

    ImagePost *imagePost = self.photos[indexPath.item];

    [self getPictureFromImagePost:imagePost withCompletion:^(UIImage *image) {
        cell.imagePost.image = image;
    }];

    return cell;
}


#pragma mark - CollectionView Cell Delegate 


-(void)deleteButtonPressedOnHomeCellCollectionViewCell:(HomeCollectionViewCell *)homeCollectionViewCell {

    NSIndexPath *indexPath = [self.profileCollectionView indexPathForCell:homeCollectionViewCell];

    ImagePost *imagePost = self.photos[indexPath.item];
   // PFUser *user = [PFUser currentUser];

    [imagePost deleteInBackground];


    [self.photos removeObjectAtIndex:indexPath.item];
    [self.profileCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];



}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"yourProfileToYourComments"]) {
        YourCommentsTableViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.profileCollectionView indexPathForCell:(UICollectionViewCell *)[[sender superview]superview]];
        ImagePost *imagePost = self.photos[indexPath.row];
        vc.imagePost = imagePost;
    }
}


@end






