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

- (void)loadCitiesWithStartIndex:(NSUInteger)startIndex count:(NSUInteger)count inCities:(NSArray *)cities block:(CCitiesArrayBlock)block {
    NSRange range = NSMakeRange(startIndex, count);
    block([cities subarrayWithRange:range], nil);
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
    });
}


@end
