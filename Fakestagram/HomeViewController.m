//
//  HomeViewController.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/10/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import "ImagePost.h"
#import "HomeCollectionViewCell.h"
#import "OtherUsersCommentsTVC.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *feedCollectionView;

@property NSMutableArray *userNames;
@property NSMutableArray *feed;
@property int tracker;

@end

@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.feed = [NSMutableArray new];
    self.userNames = [NSMutableArray new];
    self.tracker = 0;



//    PFUser *user = [PFUser currentUser];
//
//    PFQuery *queryOne = [PFUser query];
//
//    [queryOne findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//        if (!error) {
//
//
//            PFUser *testUser = objects[5];
//
//            PFRelation *relation = [user relationForKey:@"following"];
//            [relation addObject:testUser];
//
//
//            [user saveInBackground];
//        }
//
//    }];

}

-(void)viewWillAppear:(BOOL)animated {
    [self resetFeed];

}

-(void)resetFeed {
    [self.feed removeAllObjects];
    PFUser *user = [PFUser currentUser];

    PFRelation *following = [user relationForKey:@"following"];
    PFQuery *query = [following query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        for (PFUser *followedUser in objects) {

            PFQuery *queryPhoto = [PFQuery queryWithClassName:@"ImagePost"];
            [queryPhoto whereKey:@"poster" equalTo:followedUser];
            [queryPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count != 0) {
                    for (ImagePost *imagePost in objects) {
                        self.tracker++;
                        [self.feed addObject:imagePost];

                        if (self.tracker == objects.count) {
                                [self.feedCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                self.tracker = 0;
                        }
                    }
                }

             }];
        }
    }];

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
- (IBAction)uploadButtonPressed:(UIBarButtonItem *)sender {


        UIAlertController *cameraAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *photoLibrary = [UIAlertAction actionWithTitle:@"Choose a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            UIImagePickerController *imagePicker = [UIImagePickerController new];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];

        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            UIImagePickerController *imagePicker = [UIImagePickerController new];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];

        }];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

        }];

        [cameraAlert addAction:photoLibrary];
        [cameraAlert addAction:camera];
        [cameraAlert addAction:cancel];

        [self presentViewController:cameraAlert animated:YES completion:nil];

    }

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    ImagePost *imagePost = [ImagePost object];

    NSData *photoData = UIImageJPEGRepresentation(image, 1.0);

    //change the photo to square

    PFFile *tempFile = [PFFile fileWithData:photoData];

    imagePost.photoFile = tempFile;

    [tempFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {

            [self dismissViewControllerAnimated:YES completion:nil];
            [self performSegueWithIdentifier:@"UploadPictureToProfile" sender:self];

            [imagePost setObject:[PFUser currentUser] forKey:@"poster"];


            [imagePost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){

                if (succeeded) {
            
                }
            }];
        }

    }];

    //save to parse & segue

}


#pragma mark - Collection View Delegates

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];

    ImagePost *imagePost = self.feed[indexPath.item];
    PFUser *poster = [imagePost objectForKey:@"poster"];

    [cell.userNameLabel setTitle:poster.username forState:UIControlStateNormal];

    [self getPictureFromImagePost:imagePost withCompletion:^(UIImage *image) {
        cell.imagePost.image = image;

    }];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.feed.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
}

#pragma mark - segue 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"homeToCommentsDetail"]) {
        OtherUsersCommentsTVC *tVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.feedCollectionView indexPathForCell:(UICollectionViewCell *)[[sender superview] superview]];
        ImagePost *imagePost = self.feed[indexPath.item];
        tVC.iP = imagePost;
    }
    
}

@end
