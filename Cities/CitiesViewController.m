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

@property (strong, nonatomic) CCityDataHelper *dataHelper;
@property (strong, nonatomic) NSMutableArray *cities;
@property (assign, nonatomic) CCityDataStatus dataStatus;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) CitySearchResultsViewController *resultsViewController;

@property (nonatomic, assign) BOOL searchControllerWasActive;
@property (nonatomic, assign) BOOL searchControllerSearchFieldWasFirstResponder;

@property (assign, nonatomic) NSUInteger currentIndex;
@property (assign, nonatomic) NSUInteger pageCount;

@end

@implementation CitiesViewController

- (NSMutableArray *)cities {
    if (!_cities) {
        _cities = [NSMutableArray array];
    }
    return _cities;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataHelper = [CCityDataHelper new];
    _pageCount = 50;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlHandler) forControlEvents:UIControlEventValueChanged];
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

- (void)refreshControlHandler {
    [self loadCities];
}

//Listing and paging cities
- (void)loadCities {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _dataStatus = CCityDataStatusLoading;
    [_dataHelper loadCitiesWithStartIndex:_currentIndex count:_pageCount block:^(NSArray *cities, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
        if (!error) {
            if (cities.count > 0) {
                _dataStatus = CCityDataStatusIdle;
                _currentIndex += _pageCount;
                [self insertNewCities:cities forTableView:self.tableView];
            }
            else {
                _dataStatus = CCityDataStatusCompleted;
            }
        }
        else {
            _dataStatus = CCityDataStatusError;
        }
    }];
}

//Searching city and paging
- (void)searchCity:(NSString *)searchText {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [_dataHelper searchCity:searchText searchType:CCitySearchTypePredicate withBlock:^(NSArray *cities, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (!error) {
            [_dataHelper loadCitiesWithStartIndex:_resultsViewController.currentIndex count:_resultsViewController.pageCount inCities:cities block:^(NSArray *newCities, NSError *error) {
                if (_resultsViewController.currentIndex == 0) {
                    if (newCities.count > _resultsViewController.pageCount) {
                        _resultsViewController.dataStatus = CCityDataStatusIdle;
                    }
                    else {
                        _resultsViewController.dataStatus = CCityDataStatusCompleted;
                    }
                    _resultsViewController.citySearchResults = [newCities mutableCopy];
                    [_resultsViewController.tableView reloadData];
                }
                else if (newCities.count > 0) {
                    if (newCities.count > _resultsViewController.pageCount) {
                        _resultsViewController.dataStatus = CCityDataStatusIdle;
                        _resultsViewController.currentIndex += _resultsViewController.pageCount;
                    }
                    else {
                        _resultsViewController.dataStatus = CCityDataStatusCompleted;
                    }
                    [self insertNewCities:newCities forTableView:_resultsViewController.tableView];
                }
                else {
                    _resultsViewController.dataStatus = CCityDataStatusCompleted;
                }
            }];
        }
        else {
            _dataStatus = CCityDataStatusError;
        }
    }];
}

//Inserting new data while paging
- (void)insertNewCities:(NSArray *)newCities forTableView:(UITableView *)tableView{
    if (tableView == self.tableView) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSUInteger i = self.cities.count; i < self.cities.count + newCities.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexPath];
        }
        [self.cities addObjectsFromArray:newCities];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        });
    }
    else {
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSUInteger i = _resultsViewController.citySearchResults.count; i < _resultsViewController.citySearchResults.count + newCities.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexPath];
        }
        [_resultsViewController.citySearchResults addObjectsFromArray:newCities];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (searchText.length > 0) {
        _resultsViewController.currentIndex = 0;
       [self searchCity:searchText];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CityCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *cityDictionary = self.cities[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", cityDictionary[@"name"], cityDictionary[@"country"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    Deciding should load more or not
    NSInteger loadIndex;
    CCityDataStatus dataStatus;
    if (tableView == self.tableView) {
        dataStatus = _dataStatus;
        loadIndex = self.cities.count - 10;
    }
    else {
        dataStatus = _resultsViewController.dataStatus;
        loadIndex = _resultsViewController.citySearchResults.count - 10;
    }
    if (loadIndex < 1) {
        return;
    }
    if (indexPath.row == loadIndex) {
        switch (dataStatus) {
            case CCityDataStatusIdle:
                if (tableView == self.tableView) {
                    [self loadCities];
                }
                else {
                    [self searchCity:_searchController.searchBar.text];
                }
                break;
            case CCityDataStatusLoading:
                
                break;
            case CCityDataStatusCompleted:
                
                break;
            case CCityDataStatusError:
                if (tableView == self.tableView) {
                    [self loadCities];
                }
                else {
                    [self searchCity:_searchController.searchBar.text];
                }
                break;
            default:
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    Navigation
    NSDictionary *cityDictionary = (tableView == self.tableView) ?
    self.cities[indexPath.row] : _resultsViewController.citySearchResults[indexPath.row];
    
    CityDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CityDetailViewController"];
    detailViewController.cityDictionary = cityDictionary;
    
    [tableView deselectRowAtIndexPath:tableView.indexPathForSelectedRow animated:YES];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
