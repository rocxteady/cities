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

@property (strong, nonatomic) CCityDataHelper *dataHelperForBigData;
@property (strong, nonatomic) CCityDataHelper *dataHelperForTestData;

@end

@implementation CitiesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self setContinueAfterFailure:NO];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    _dataHelperForBigData = [CCityDataHelper new];
    _dataHelperForTestData = [CCityDataHelper new];
    [_dataHelperForBigData loadCities:^(NSError *error) {
        if (error) {
            XCTFail(@"Test failed with error: %@", error.localizedDescription);
        }
        else {
            [_dataHelperForTestData loadTestCities:^(NSError *error) {
                if (error) {
                    XCTFail(@"Test failed with error: %@", error.localizedDescription);
                }
                dispatch_semaphore_signal(semaphore);
            }];
        }
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSuccessSearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search testing works!"];
    
    NSString *testCity = @"istanbul";
    [_dataHelperForTestData searchCity:testCity searchType:CCitySearchTypeIterate withBlock:^(NSArray *cities, NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        else{
            NSDictionary *cityDictionary = cities.firstObject;
            XCTAssertTrue([cityDictionary[@"name"] rangeOfString:testCity options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location == 0,
                          @"Strings are not equal %@ %@", testCity, cityDictionary[@"name"]);

            [expectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

- (void)testFailSearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Search testing works!"];
    
    NSString *testCity = @"dfgdghg";
    [_dataHelperForTestData searchCity:testCity searchType:CCitySearchTypeIterate withBlock:^(NSArray *cities, NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        else{
            NSDictionary *cityDictionary = cities.firstObject;
            XCTAssertNil(cityDictionary, @"City data must be nil!");
            [expectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

- (void)testPerformanceForIteration {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        [_dataHelperForBigData searchCity:@"ist" searchType:CCitySearchTypeIterate withBlock:^(NSArray *cities, NSError *error) {
            if (error) {
                XCTFail(@"Test failed with error: %@", error.localizedDescription);
            }
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
        
        [_dataHelperForBigData searchCity:@"ist" searchType:CCitySearchTypePredicate withBlock:^(NSArray *cities, NSError *error) {
            if (error) {
                XCTFail(@"Test failed with error: %@", error.localizedDescription);
            }
            dispatch_semaphore_signal(semaphore);
        }];
        
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        }
    }];
}

@end
