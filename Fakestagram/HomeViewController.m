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
#import "OtherUsersCommentsTVC.h"
#import "OtherPeoplesProfileViewController.h"

@interface HomeViewController ()


@property (weak, nonatomic) IBOutlet UICollectionView *feedCollectionView;

@property NSArray *feedSorted;
@property NSMutableArray *feed;
@property int tracker;


@end


@implementation HomeViewController

#pragma mark - VC and life-cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewSetUp];

}


-(void)viewWillAppear:(BOOL)animated {
    [self resetFeed];

}

-(void)viewSetUp {
    
    self.feed = [NSMutableArray new];
    self.tracker = 0;
}


-(void)resetFeed {
    [self.feed removeAllObjects];
    PFUser *user = [PFUser currentUser];

    PFRelation *following = [user relationForKey:@"following"];
    PFQuery *query = [following query];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        
        //Do something if objects.count == 0?
        
        for (PFUser *followedUser in objects) {

            PFQuery *queryPhoto = [PFQuery queryWithClassName:@"ImagePost"];
            [queryPhoto whereKey:@"poster" equalTo:followedUser];
            [queryPhoto includeKey:@"poster"];
            [queryPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count != 0) {
                    for (ImagePost *imagePost in objects) {
                        self.tracker++;
                        [self.feed addObject:imagePost];

                        if (self.tracker == objects.count) {
                            
                            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
            
                            
                            NSArray *sortArray = [self.feed sortedArrayUsingDescriptors:@[sortDescriptor]];
                            self.feedSorted = [NSArray arrayWithArray:sortArray];
                            
                            
                            [self.feedCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                            self.tracker = 0;
                        }
                    }
                }

             }];
        }
    }];

}

#pragma mark - Button method

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


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    UIImage *croppedImage = [self imageByCroppingImage:image];
    ImagePost *imagePost = [ImagePost object];
    
    NSData *photoData = UIImageJPEGRepresentation(croppedImage, 1.0);

    PFFile *tempFile = [PFFile fileWithData:photoData];
    
    imagePost.photoFile = tempFile;
    
    [tempFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            
            [self dismissViewControllerAnimated:YES completion:nil];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add a Hashtag" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Hashtag";
            }];

            UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

                UITextField *hashtagTextField = [alert textFields].firstObject;
                NSString *hashtagText = [hashtagTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
                [imagePost setObject:hashtagText forKey:@"hashtag"];

                [self performSegueWithIdentifier:@"UploadPictureToProfile" sender:self];

                [imagePost setObject:[PFUser currentUser] forKey:@"poster"];


                [imagePost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){

                    if (succeeded) {

                    }
                }];
            }];

            [alert addAction:addAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    
}


- (UIImage *)imageByCroppingImage:(UIImage *)image {

    double refWidth = CGImageGetWidth(image.CGImage);
    double refHeight = CGImageGetHeight(image.CGImage);

    CGSize centerSquareSize;

    if (refWidth > refHeight) {
        centerSquareSize.width = refHeight;
        centerSquareSize.height = refHeight;
    } else if (refWidth < refHeight) {
        centerSquareSize.width = refWidth;
        centerSquareSize.height = refWidth;

    } else {
        return image;
    }

    double x = (refWidth - centerSquareSize.width) / 2.0;
    double y = (refHeight - centerSquareSize.height) / 2.0;

    CGRect cropRect = CGRectMake(x, y, centerSquareSize.height, centerSquareSize.width);

    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);

    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);

    return cropped;
}


#pragma mark - HomeCollectionViewCell Delegate

-(UIImage *)homeCollectionViewCell:(HomeCollectionViewCell *)HomeCollectionViewCell {

    NSIndexPath *indexPath = [self.feedCollectionView indexPathForCell:HomeCollectionViewCell];
    ImagePost *imagePost = self.feedSorted[indexPath.item];

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


#pragma mark - CollectionView Delegates

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
    cell.delegate = self;

    ImagePost *imagePost = self.feedSorted[indexPath.item];
    PFUser *poster = [imagePost objectForKey:@"poster"];

    NSMutableArray * usersWhoLiked = [imagePost objectForKey:@"usersWhoLiked"] ?: [NSMutableArray new];

    if ([usersWhoLiked containsObject:[PFUser currentUser]]) {
        [cell.likeButton setImage:[UIImage imageNamed:@"star-filled"] forState:UIControlStateNormal];

    } else {

        [cell.likeButton setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    }

    [cell.userNameLabel setTitle:poster.username forState:UIControlStateNormal];

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


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.feedSorted.count;
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
}

#pragma mark - segue 

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"homeToCommentsDetail"]) {
        OtherUsersCommentsTVC *tVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.feedCollectionView indexPathForCell:(UICollectionViewCell *)[[sender superview] superview]];
        ImagePost *imagePost = self.feedSorted[indexPath.item];
        tVC.iP = imagePost;
    } else if ([segue.identifier isEqualToString:@"homeToOPPVC"]) {

        OtherPeoplesProfileViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.feedCollectionView indexPathForCell:(UICollectionViewCell *)[[sender superview] superview]];
        ImagePost *imagePost = self.feedSorted[indexPath.item];

        vc.user = [imagePost objectForKey:@"poster"];


    }
    
}

@end
