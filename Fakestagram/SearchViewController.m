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
#import "ImagePost.h"
#import "HashtagDetailViewController.h"

@interface SearchViewController () <UISearchResultsUpdating, UISearchBarDelegate>


@property UISearchController *searchController;
@property (nonatomic) NSArray *filteredResults;
@property NSMutableArray *users;
@property BOOL searchIsHappening;
@property NSArray *allHashtags;
@property (nonatomic) NSArray *filteredHashtags;
@property BOOL isSearchingHashtag;


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
    [self loadHashtags];
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
-(void)loadHashtags {


    PFQuery *query = [PFQuery queryWithClassName:@"Hashtag"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        self.allHashtags = objects;
    }];

    self.isSearchingHashtag = NO;
}

#pragma mark - Search Bar 

-(void)searchControllerSetUp {

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.scopeButtonTitles = @[@"Users", @"Hashtag"];
    [self.searchController.searchBar setTintColor:[UIColor colorWithRed:223.0/255.0 green:82.0/255.0 blue:85.0/255.0 alpha:1.0]];
 

    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;

 

    [self.tableView setNeedsLayout];
}


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.active) {
        self.searchIsHappening = YES;
    } else {
        self.searchIsHappening = NO;
    }



    NSString *searchString = [self.searchController.searchBar text];

    [self updateFilteredContentForFriendsName:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
}


-(void)updateFilteredContentForFriendsName:(NSString *)searchString scope:(NSInteger)scope {

    if (scope == 0) {
        self.filteredResults = [self.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username contains[c] %@", searchString]];
        self.isSearchingHashtag = NO;
    } else {
        self.filteredHashtags = [self.allHashtags filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"hashtag contains[c] %@", searchString]];
        self.isSearchingHashtag = YES;
    }

}


- (void)setFilteredResults:(NSArray *)filteredResults {

    _filteredResults = filteredResults;
    [self.tableView reloadData];
}

-(void)setFilteredHashtags:(NSArray *)filteredHashtags {
    _filteredHashtags = filteredHashtags;
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchIsHappening = NO;

}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}



-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //we can now click on the cell!!
}

#pragma mark - TableView Delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (!self.searchIsHappening) {
        return self.users.count;
    } else if (self.searchIsHappening && !self.isSearchingHashtag){
        return self.filteredResults.count;
    } else {
        return self.filteredHashtags.count;
    }

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];

    if (!self.searchIsHappening) {
        PFUser *user = self.users[indexPath.row];
        cell.textLabel.text = user.username;
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size: 18]];
    } else if (self.searchIsHappening && !self.isSearchingHashtag) {
        PFUser *userFiltered = self.filteredResults[indexPath.row];
        cell.textLabel.text = userFiltered.username;
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size: 18]];
    } else {
        //ImagePost *post = self.filteredImagePosts[indexPath.row];
        PFObject *hashtagObject = self.filteredHashtags[indexPath.row];
        NSString *hashtag = [hashtagObject objectForKey:@"hashtag"];
        if ([hashtag hasPrefix:@"#"] || [hashtag isEqualToString:@""] ) {
                cell.textLabel.text = hashtag;
        } else {
                cell.textLabel.text = [NSString stringWithFormat:@"#%@", hashtag];
        }

        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size: 18]];
    }

    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    CGRect searchBarFrame = self.searchController.searchBar.frame;
    [self.tableView scrollRectToVisible:searchBarFrame animated:NO];
    return NSNotFound;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearchingHashtag && self.searchIsHappening) {
        [self performSegueWithIdentifier:@"searchToHashtagVC" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    } else {
        [self performSegueWithIdentifier:@"searchToOPPVC" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender  {
    if ([segue.identifier isEqualToString: @"searchToOPPVC"]) {
        OtherPeoplesProfileViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        if (self.searchIsHappening) {
            vc.user = self.filteredResults[indexPath.row];
        }else {
            vc.user = self.users[indexPath.row];
        }
    } else {
        HashtagDetailViewController *vc2 = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        //ImagePost *imagePost = self.filteredImagePosts[indexPath.row];
        PFObject *hashtag = self.filteredHashtags[indexPath.row];
        vc2.hashtag = [hashtag objectForKey:@"hashtag"];

    }

}


@end
