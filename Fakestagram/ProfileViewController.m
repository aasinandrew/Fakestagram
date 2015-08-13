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
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self loadPosts];
    [self loadProfileImage];
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

-(void)loadProfileImage {

    PFUser *currentUser = [PFUser currentUser];
    if ([currentUser objectForKey:@"profilePhoto"]) {

        PFFile *photoFile = [currentUser objectForKey:@"profilePhoto"];
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

            if (error == nil) {
                UIImage *image = [UIImage imageWithData:data];
                self.profileImage.image = image;
            }
        }];
        
    } else {

        self.profileImage.image = [UIImage imageNamed:@"seahorse.png"];
        
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


#pragma mark - CollectionView Cell Delegate 


-(void)homeCollectionViewCellMoreButtonPressed:(HomeCollectionViewCell *)homeCollectionViewCell {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"More" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSIndexPath *indexPath = [self.profileCollectionView indexPathForCell:homeCollectionViewCell];
        
        ImagePost *imagePost = self.photos[indexPath.item];
        // PFUser *user = [PFUser currentUser];
        
        [imagePost deleteInBackground];
        
        
        [self.photos removeObjectAtIndex:indexPath.item];
        [self.profileCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }];
    
   
   // UIAlertAction *detail = [[UIAlertAction actionWithTitle:@"" style:<#(UIAlertActionStyle)#> handler:<#^(UIAlertAction *action)handler#>];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alertController addAction:delete];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
   



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

- (IBAction)editButtonPressed:(UIButton *)sender {

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

    UIImage *croppedImage = [self imageByCroppingImage:image];
    PFUser *currentUser = [PFUser currentUser];

    NSData *photoData = UIImageJPEGRepresentation(croppedImage, 1.0);

    PFFile *tempFile = [PFFile fileWithData:photoData];

    [currentUser setObject:tempFile forKey:@"profilePhoto"];
    [tempFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {

            [self dismissViewControllerAnimated:YES completion:nil];
            self.profileImage.image = croppedImage;

            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){

                if (succeeded) {

                }
            }];
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

@end






