//
//  SearchViewController.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/10/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "SearchViewController.h"
#import <Parse/Parse.h>
#import "OtherPeoplesProfileViewController.h"

@interface SearchViewController () <UISearchResultsUpdating, UISearchBarDelegate>


@property UISearchController *searchController;
@property (nonatomic) NSArray *filteredResults;
@property NSMutableArray *users;
@property BOOL searchIsHappening; 


@end


@implementation SearchViewController


#pragma mark - VC and Life-cycle 

- (void)viewDidLoad {
    
    [super viewDidLoad];
//     [self addObserver:self forKeyPath:@"users" options:NSKeyValueObservingOptionNew context:NULL];
    [self searchControllerSetUp];
//   [self loadUsers];

    
}

-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
     [self loadUsers];
    //[self addObserver:self forKeyPath:@"users" options:NSKeyValueObservingOptionNew context:NULL];



}
//
//
//-(void)viewDidDisappear:(BOOL)animated {
//
//    [super viewDidDisappear:animated];
//    [self removeObserver:self forKeyPath:@"users"];
//
//}

//-(void)dealloc {
//
//    [self removeObserver:self forKeyPath:@"users"];
//}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"users"]) {
        [self.tableView reloadData];
    }
}

-(void)loadUsers {
    
    self.users = [NSMutableArray new];
    
    PFQuery *query = [PFUser query];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        int tracker = 0;
        for (PFUser *user in objects) {
            tracker++;
            if (user != [PFUser currentUser]) {

                [self.users addObject:user];

            }

            if (tracker == objects.count) {
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

            }

        }
    }];
    
}


#pragma mark - Search Bar 

-(void)searchControllerSetUp {

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;

    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];

    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;

    [self.tableView setNeedsLayout];
}


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.active) {
        self.searchIsHappening = YES;
    }

    NSString *searchString = [self.searchController.searchBar text];

    [self updateFilteredContentForFriendsName:searchString];
}


-(void)updateFilteredContentForFriendsName:(NSString *)searchString {

    self.filteredResults = [self.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username contains[c] %@", searchString]];
}


- (void)setFilteredResults:(NSArray *)filteredResults {

    _filteredResults = filteredResults;
    [self.tableView reloadData];
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchIsHappening = NO;

}


#pragma mark - TableView Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (!self.searchIsHappening) {
        return self.users.count;
    } else {
        return self.filteredResults.count;
    }

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];

    if (!self.searchIsHappening) {
        PFUser *user = self.users[indexPath.row];
        cell.textLabel.text = user.username;
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size: 18]];
    } else {
        PFUser *userFiltered = self.filteredResults[indexPath.row];
        cell.textLabel.text = userFiltered.username;
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size: 18]];
    }

    return cell;
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender  {

    OtherPeoplesProfileViewController *vc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

    if (self.searchIsHappening) {
        vc.user = self.filteredResults[indexPath.row];
    }else {
        vc.user = self.users[indexPath.row];
    }
}


@end
