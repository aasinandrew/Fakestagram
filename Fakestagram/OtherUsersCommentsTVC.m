//
//  OtherUsersCommentsTVC.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/11/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "OtherUsersCommentsTVC.h"
#import <Parse/Parse.h>
#import "ImagePost.h"

@interface OtherUsersCommentsTVC ()


@property NSMutableArray *comments;


@end


@implementation OtherUsersCommentsTVC


#pragma mark - VC and Life-cycle 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadComments];
}


- (void)loadComments {
    self.comments = [self.iP objectForKey:@"comments"] ?: [NSMutableArray new];
    [self.tableView reloadData];
}


#pragma mark - Button Method 

-(IBAction)addCommentButtonPressed:(UIBarButtonItem *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add a Comment" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Comment";
    }];
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *commentTextField = [alert textFields].firstObject;
        [self.comments addObject:commentTextField.text];
        [self.iP setObject:self.comments forKey:@"comments"];
        [self.iP saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {

                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.comments.count-1 inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            }
        }];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:addAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherUserCommentsCell" forIndexPath:indexPath];
    cell.textLabel.text = self.comments[indexPath.row];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size: 18]];
    return cell;
}

@end
