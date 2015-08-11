//
//  HomeViewController.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/10/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    PFUser *user = [PFUser currentUser];

    PFQuery *query = [PFUser query];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (!error) {


            PFUser *testUser = objects.firstObject;

            PFRelation *relation = [user relationForKey:@"following"];
            [relation addObject:testUser];

            PFRelation *relation2 = [testUser relationForKey:@"following"];
            [relation2 addObject:user];
            [testUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){

            }];

            [user saveInBackground];
        }

    }];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
