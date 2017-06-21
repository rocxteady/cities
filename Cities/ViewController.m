//
//  ViewController.m
//  Cities
//
//  Created by Ulaş Sancak on 21/06/2017.
//  Copyright © 2017 Ulaş Sancak. All rights reserved.
//

#import "ViewController.h"
#import "CCityDataHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[CCityDataHelper sharedInstance] loadCities:^(NSError *error) {
        NSDate *date = [NSDate date];
        [[CCityDataHelper sharedInstance] searchCity:@"Ista" withBlock:^(NSArray *cities, NSError *error) {
            NSLog(@"%f", [[NSDate date] timeIntervalSinceDate:date]);
            NSLog(@"%@", cities);
        }];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
