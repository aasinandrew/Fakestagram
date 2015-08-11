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

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    PFUser *user = [PFUser currentUser];
//
//    PFQuery *query = [PFUser query];
//
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//        if (!error) {
//
//
//            PFUser *testUser = objects.firstObject;
//
//            PFRelation *relation = [user relationForKey:@"following"];
//            [relation addObject:testUser];
//
//            PFRelation *relation2 = [testUser relationForKey:@"following"];
//            [relation2 addObject:user];
//            [testUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
//
//            }];
//
//            [user saveInBackground];
//        }
//
//    }];


    PFUser *user = [PFUser currentUser];

    PFRelation *following = [user relationForKey:@"following"];
    PFQuery *query = [following query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        


    }];




    //PFQuery *query = [PFUser queryWith];

    //[query

//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//
//
//
//    }];


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

            [imagePost setValue:[PFUser currentUser] forKey:@"poster"];

            [imagePost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){

                if (succeeded) {
                    //
                }
            }];
        }

    }];

    //save to parse & segue
        [self dismissViewControllerAnimated:YES completion:nil];

}




@end
