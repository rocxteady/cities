//
//  CitySearchResultsViewController.m
//  Cities
//
//  Created by Ulaş Sancak on 22/06/2017.
//  Copyright © 2017 Ulaş Sancak. All rights reserved.
//

#import "CitySearchResultsViewController.h"

static NSString *CellIdentifier = @"CityResultCell";

@interface CitySearchResultsViewController ()

@end

@implementation CitySearchResultsViewController

- (NSMutableArray *)citySearchResults {
    if (!_citySearchResults) {
        _citySearchResults = [NSMutableArray array];
    }
    return _citySearchResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageCount = 100;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.citySearchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *cityDictionary = self.citySearchResults[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", cityDictionary[@"name"], cityDictionary[@"country"]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
