//
//  ViewController.m
//  Cities
//
//  Created by Ulaş Sancak on 21/06/2017.
//  Copyright © 2017 Ulaş Sancak. All rights reserved.
//

#import "CitiesViewController.h"
#import "CCityDataHelper.h"
#import "CitySearchResultsViewController.h"
#import "CityDetailViewController.h"

static NSString *CityCellIdentifier = @"CityCell";

@interface CitiesViewController () <UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) CitySearchResultsViewController *resultsViewController;

@property (nonatomic, assign) BOOL searchControllerWasActive;
@property (nonatomic, assign) BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation CitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _resultsViewController = [[CitySearchResultsViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = self;
    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    _resultsViewController.tableView.delegate = self;
    _searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    _searchController.searchBar.delegate = self; // so we can monitor text changes + others

    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    [self loadCities];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_searchControllerWasActive) {
        _searchController.active = _searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (_searchControllerSearchFieldWasFirstResponder) {
            [_searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

- (void)loadCities {
    [[CCityDataHelper sharedInstance] loadCities:^(NSError *error) {
        [self.tableView reloadData];
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    
    [[CCityDataHelper sharedInstance] searchCity:searchText searchType:CCitySearchTypePredicate withBlock:^(NSArray *cities, NSError *error) {
        // hand over the filtered results to our search results table
        CitySearchResultsViewController *resultsController = (CitySearchResultsViewController *)_searchController.searchResultsController;
        resultsController.citySearchResults = cities;
        [resultsController.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [CCityDataHelper sharedInstance].cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CityCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *cityDictionary = [CCityDataHelper sharedInstance].cities[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", cityDictionary[@"name"], cityDictionary[@"country"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cityDictionary = (tableView == self.tableView) ?
    [CCityDataHelper sharedInstance].cities[indexPath.row] : _resultsViewController.citySearchResults[indexPath.row];
    
    CityDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CityDetailViewController"];
    detailViewController.cityDictionary = cityDictionary;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
