//
//  CDataProvider.m
//  Cities
//
//  Created by Ulaş Sancak on 21/06/2017.
//  Copyright © 2017 Ulaş Sancak. All rights reserved.
//

#import "CCityDataHelper.h"

@interface CCityDataHelper ()

@property (strong, nonatomic) dispatch_queue_t searchQueue;
@property (assign, nonatomic, getter=isSearching) BOOL searching;
@property (assign, nonatomic, getter=isSearchQueueCancellationActive) BOOL searchQueueCancellationActive;

@end

@implementation CCityDataHelper

- (dispatch_queue_t)searchQueue {
    if (_searchQueue == NULL) {
        _searchQueue = dispatch_queue_create("com.ulassancak.cities.search", DISPATCH_QUEUE_SERIAL);
    }
    return _searchQueue;
}

//Suspending searching thread
- (void)stopSearchQueue {
    _searchQueueCancellationActive = YES;
    dispatch_suspend(_searchQueue);
}

//Loading cities with paging for UITableView
- (void)loadCitiesWithStartIndex:(NSUInteger)startIndex count:(NSUInteger)count block:(CCitiesArrayBlock)block {
    NSRange range = NSMakeRange(startIndex, count);
    if (_cities.count == 0) {
        [self loadCities:^(NSError *error) {
            if (error) {
                block(nil, error);
                return;
            }
            block([_cities subarrayWithRange:range], nil);
        }];
    }
    else {
        block([_cities subarrayWithRange:range], nil);
    }
}

//Loading cities with paging for UITableView
- (void)loadCitiesWithStartIndex:(NSUInteger)startIndex count:(NSUInteger)count inCities:(NSArray *)cities block:(CCitiesArrayBlock)block {
    if (startIndex + count > cities.count) {
        count = cities.count - startIndex;
    }
    NSRange range = NSMakeRange(startIndex, count);
    block([cities subarrayWithRange:range], nil);
}

- (void)loadCities:(CCitiesLoadBlock)block {
    [self loadCitiesWithFileName:@"cities" block:block];
}

- (void)loadTestCities:(CCitiesLoadBlock)block {
    [self loadCitiesWithFileName:@"test" block:block];
}

//Loading cities based on file name (test data or not)
- (void)loadCitiesWithFileName:(NSString *)fileName block:(CCitiesLoadBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *citiesPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
        NSData *citiesData = [NSData dataWithContentsOfFile:citiesPath];
        NSError *error = nil;
        NSArray *cities = [NSJSONSerialization JSONObjectWithData:citiesData options:0 error:&error];
        NSSortDescriptor *citySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSSortDescriptor *countrySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"country" ascending:YES];
        _cities = [cities sortedArrayUsingDescriptors:@[citySortDescriptor, countrySortDescriptor]];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(error);
        });
    });
}


- (void)searchCity:(NSString *)searchText searchType:(CCitySearchType)searchType withBlock:(CCitiesArrayBlock)block {
    switch (searchType) {
        case CCitySearchTypePredicate:
            [self searchCityWithPredicate:searchText withBlock:block];
            break;
        case CCitySearchTypeIterate:
            [self searchCityWithIteration:searchText withBlock:block];
            break;
        default:
            break;
    }
}

//Searching with NSPredicate
- (void)searchCityWithPredicate:(NSString *)searchText withBlock:(CCitiesArrayBlock)block {
//    Suspend searching thread if a searching is not finished yet
    if (self.isSearching && !_searchQueueCancellationActive) {
        [self stopSearchQueue];
    }
    else if (_searchQueueCancellationActive) {
        _searchQueueCancellationActive = NO;
        _searching = YES;
    }
    dispatch_async(self.searchQueue, ^{
        if (!self.isSearchQueueCancellationActive) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name BEGINSWITH[cd] %@", searchText];
            NSArray *results = [_cities filteredArrayUsingPredicate:predicate];
            _searching = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                block(results, nil);
            });

        }
    });
}

//Searching with direct iteration
- (void)searchCityWithIteration:(NSString *)searchText withBlock:(CCitiesArrayBlock)block {
    //    Suspend searching thread if a searching is not finished yet
    if (self.isSearching && !_searchQueueCancellationActive) {
        [self stopSearchQueue];
    }
    else if (_searchQueueCancellationActive) {
        _searchQueueCancellationActive = NO;
        _searching = YES;
    }
    dispatch_async(self.searchQueue, ^{
        if (!self.isSearchQueueCancellationActive) {
            NSMutableArray *results = [NSMutableArray array];
            for (NSDictionary *cityDictionary in _cities) {
                if ([cityDictionary[@"name"] rangeOfString:searchText options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location == 0) {
                    [results addObject:cityDictionary];
                }
            }
            NSArray *copiedResults = [results copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(copiedResults, nil);
            });
        }
    });
}


@end
