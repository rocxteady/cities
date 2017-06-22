//
//  CDataProvider.h
//  Cities
//
//  Created by Ulaş Sancak on 21/06/2017.
//  Copyright © 2017 Ulaş Sancak. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CCitiesLoadBlock)(NSError *error);
typedef void(^CCitiesArrayBlock)(NSArray *cities, NSError *error);

typedef NS_ENUM(NSUInteger, CCitySearchType){
    CCitySearchTypePredicate,
    CCitySearchTypeIterate
};

typedef NS_ENUM(NSUInteger, CCityDataStatus){
    CCityDataStatusIdle,
    CCityDataStatusLoading,
    CCityDataStatusCompleted,
    CCityDataStatusError
};

@interface CCityDataHelper : NSObject

@property (strong, nonatomic, readonly) NSArray *cities;

+ (instancetype)sharedInstance;

- (void)loadCities:(CCitiesLoadBlock)block;

- (void)loadCitiesWithStartIndex:(NSUInteger)startIndex count:(NSUInteger)count block:(CCitiesArrayBlock)block;

- (void)loadCitiesWithStartIndex:(NSUInteger)startIndex count:(NSUInteger)count inCities:(NSArray *)cities block:(CCitiesArrayBlock)block;

- (void)searchCity:(NSString *)searchText searchType:(CCitySearchType)searchType withBlock:(CCitiesArrayBlock)block;

@end
