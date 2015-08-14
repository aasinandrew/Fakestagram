//
//  HomeCollectionViewCell.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/11/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "HomeCollectionViewCell.h"

@implementation HomeCollectionViewCell

- (IBAction)starButtonPressed:(UIButton *)sender {

    UIImage *image = [self.delegate homeCollectionViewCell:self];
    [sender setImage:image forState:UIControlStateNormal];
}

-(IBAction)moreButtonPressed:(UIButton *)sender {
    [self.delegate homeCollectionViewCellMoreButtonPressed:self];
}

@end
