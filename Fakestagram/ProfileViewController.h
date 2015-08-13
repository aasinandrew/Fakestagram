//
//  ProfileViewController.h
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/10/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCollectionViewCell.h"

@interface ProfileViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, HomeCollectionViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end
