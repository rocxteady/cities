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

- (void)refreshControlHandler {
    [self loadCities];
}

- (void)loadCities {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _dataStatus = CCityDataStatusLoading;
    [[CCityDataHelper sharedInstance] loadCitiesWithStartIndex:_currentIndex count:_pageCount block:^(NSArray *cities, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
        if (!error) {
            if (cities.count > 0) {
                _dataStatus = CCityDataStatusIdle;
                _currentIndex += _pageCount;
                [self insertNewCities:cities];
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

- (void)insertNewCities:(NSArray *)newCities {
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSUInteger i = self.cities.count; i < self.cities.count + newCities.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    [self.cities addObjectsFromArray:newCities];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[CCityDataHelper sharedInstance] searchCity:searchText searchType:CCitySearchTypeIterate withBlock:^(NSArray *cities, NSError *error) {
        // hand over the filtered results to our search results table
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        CitySearchResultsViewController *resultsController = (CitySearchResultsViewController *)_searchController.searchResultsController;
        resultsController.citySearchResults = cities;
        [resultsController.tableView reloadData];
    }];
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
    if (indexPath.row == self.cities.count - 10) {
        switch (_dataStatus) {
            case CCityDataStatusIdle:
                [self loadCities];
                break;
            case CCityDataStatusLoading:
                
                break;
            case CCityDataStatusCompleted:
                
                break;
            case CCityDataStatusError:
                [self loadCities];
                break;
            default:
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cityDictionary = (tableView == self.tableView) ?
    self.cities[indexPath.row] : _resultsViewController.citySearchResults[indexPath.row];
    
    CityDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CityDetailViewController"];
    detailViewController.cityDictionary = cityDictionary;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
