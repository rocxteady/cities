//
//  CitySearchResultsViewController.h
//  Cities
//
//  Created by Ulaş Sancak on 22/06/2017.
//  Copyright © 2017 Ulaş Sancak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCityDataHelper.h"

@interface CitySearchResultsViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *citySearchResults;
@property (assign, nonatomic) CCityDataStatus dataStatus;
@property (assign, nonatomic) NSUInteger currentIndex;
@property (assign, nonatomic) NSUInteger pageCount;

@end
