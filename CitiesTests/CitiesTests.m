//
//  CitiesTests.m
//  CitiesTests
//
//  Created by Ulaş Sancak on 21/06/2017.
//  Copyright © 2017 Ulaş Sancak. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CCityDataHelper.h"

@interface CitiesTests : XCTestCase

@end

@implementation CitiesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[CCityDataHelper sharedInstance] loadCities:^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPerformanceForIteration {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [[CCityDataHelper sharedInstance] searchCity:@"ist" searchType:CCitySearchTypeIterate withBlock:^(NSArray *cities, NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
        
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        }
    }];
}

- (void)testPerformanceForPredication {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [[CCityDataHelper sharedInstance] searchCity:@"ist" searchType:CCitySearchTypePredicate withBlock:^(NSArray *cities, NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
        
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        }
    }];
}

@end
