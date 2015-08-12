//
//  SearchViewController.m
//  Fakestagram
//
//  Created by Sean's Macboo Pro on 8/10/15.
//  Copyright (c) 2015 Andrew Nguyen. All rights reserved.
//

#import "SearchViewController.h"
#import <Parse/Parse.h>

@interface SearchViewController () <UISearchResultsUpdating, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property UISearchController *searchController;
@property (nonatomic) NSArray *filteredResults;
@property NSMutableArray *users;
@property BOOL searchIsHappening; 

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self searchControllerSetUp];
    self.users = [NSMutableArray new];
    [self loadUsers];

}

-(void)loadUsers {
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        for (PFUser *user in objects) {
            [self.users addObject:user];
            [self.searchTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

        }
    }];
}

#pragma mark - Search Bar 

-(void)searchControllerSetUp {

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;

    self.searchTableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];

    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
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
    [self.searchTableView reloadData];
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


@end
