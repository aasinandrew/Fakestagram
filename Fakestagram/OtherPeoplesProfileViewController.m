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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set Navbar title to User Name
}


- (IBAction)followButtonPressed:(UIButton *)sender {
}


- (IBAction)favoriteButtonPressed:(UIButton *)sender {

    //change this to custom
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

@end
