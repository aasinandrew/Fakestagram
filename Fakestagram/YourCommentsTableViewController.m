//
//  YourCommentsTableViewController.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/11/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "YourCommentsTableViewController.h"
#import "ImagePost.h"

@interface YourCommentsTableViewController ()
@property NSMutableArray *comments;

@end

@implementation YourCommentsTableViewController


#pragma mark - VC and Life-cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadComments];
}


- (void)loadComments {
    self.comments = [self.imagePost objectForKey:@"comments"] ?: [NSMutableArray new];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YouCommentsCell" forIndexPath:indexPath];
    cell.textLabel.text = self.comments[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.comments removeObjectAtIndex:indexPath.row];
        [self.imagePost setObject:self.comments forKey:@"comments"];
        [self.imagePost saveInBackground];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
