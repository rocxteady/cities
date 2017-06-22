//
//  CDataProvider.m
//  Cities
//
//  Created by Ulaş Sancak on 21/06/2017.
//  Copyright © 2017 Ulaş Sancak. All rights reserved.
//

#import "CCityDataHelper.h"

@implementation CCityDataHelper

+ (instancetype)sharedInstance {
    static CCityDataHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;

}

- (void)loadCities:(CCitiesLoadBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *citiesPath = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"json"];
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

- (void)searchCityWithPredicate:(NSString *)searchText withBlock:(CCitiesArrayBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name BEGINSWITH[cd] %@", searchText];
        NSArray *results = [_cities filteredArrayUsingPredicate:predicate];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(results, nil);
        });
    });
}

- (void)searchCityWithIteration:(NSString *)searchText withBlock:(CCitiesArrayBlock)block {
    NSString *lowercaseText = [searchText lowercaseString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *results = [NSMutableArray array];
        for (NSDictionary *cityDictionary in _cities) {
            if ([[cityDictionary[@"name"] lowercaseString] hasPrefix:lowercaseText]) {
                [results addObject:cityDictionary];
            }
        }
        NSArray *copiedResults = [results copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(copiedResults, nil);
        });
    });
}


@end
