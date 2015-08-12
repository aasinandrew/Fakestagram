//
//  OtherPeoplesProfileViewController.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/11/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "OtherPeoplesProfileViewController.h"
#import "HomeCollectionViewCell.h"

@interface OtherPeoplesProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>


@end

@implementation OtherPeoplesProfileViewController

#pragma mark - VC and life-cycle 


- (void)viewDidLoad {
    [super viewDidLoad];
    // Set Navbar title to User Name
}



#pragma mark - Button methods 

- (IBAction)followButtonPressed:(UIButton *)sender {
}


- (IBAction)favoriteButtonPressed:(UIButton *)sender {

    //change this to custom
}

#pragma mark - Collection View Delegate Methods 


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

@end
