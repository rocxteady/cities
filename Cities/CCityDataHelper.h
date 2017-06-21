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

@interface CCityDataHelper : NSObject

@property (strong, nonatomic, readonly) NSArray *cities;

+ (instancetype)sharedInstance;

- (void)loadCities:(CCitiesLoadBlock)block;

- (void)searchCity:(NSString *)searchText withBlock:(CCitiesArrayBlock)block;

@end
