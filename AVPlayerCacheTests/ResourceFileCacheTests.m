//
//  ResourceFileCacheTests.m
//  AVPlayerCache
//
//  Created by Dmitry on 25.08.15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "Constants.h"
#import "ResourceFileCache.h"

@interface ResourceFileCacheTests : XCTestCase

@end

@implementation ResourceFileCacheTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void) waitForExpectationWithTimeout:(NSTimeInterval) timeout {
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
}

-(void) waitForExpectation {
    [self waitForExpectationWithTimeout:2.0];
}

- (void)testNewWrapper {
    ResourceFileCache *fileCache = [[ResourceFileCache alloc] initForRemotePath:mp4SourceURL];
    XCTAssertNotNil(fileCache, @"File cache must not be nil");
    XCTAssertNotNil(fileCache.remotePath, @"Remote path must not be nil");
    XCTAssertEqualObjects(fileCache.remotePath, mp4SourceURL, @"Init remote path must be the same as in file cache instance");
}

- (void)testWritingAndReading {
    ResourceFileCache *fileCache = [[ResourceFileCache alloc] initForRemotePath:mp4SourceURL];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Data writing test"];
    NSString *dataString = m3u8SourceURL;
    NSUInteger numberOfBytes = [dataString lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
    void *bytes = malloc(numberOfBytes);
    NSUInteger usedLength = 0;
    [dataString getBytes:bytes
               maxLength:numberOfBytes
              usedLength:&usedLength
                encoding:NSUnicodeStringEncoding
                 options:0
                   range:NSMakeRange(0, dataString.length)
          remainingRange:nil];
    NSData *data = [NSData dataWithBytes:bytes length:dataString.length];
    free(bytes);
    [fileCache saveData:data offset:0 completion:^(NSError *error) {
        XCTAssertNil(error, @"Writing went wrong");
        [expectation fulfill];
    }];
    [self waitForExpectation];
    expectation = [self expectationWithDescription:@"Data reading test"];
    [fileCache tryLoadDataWithOffset:0
                              length:dataString.length
                             success:^(NSData *readData) {
                                 XCTAssertNotNil(readData, @"Data must not be nil");
                                 XCTAssertEqual(readData.length, data.length, @"Read data must have the same lenght as written");
                                 XCTAssertEqualObjects(readData, data, @"Written and read data must be equal");
                                 [expectation fulfill];
                             }
                             failure:^(NSError *error) {
                                 XCTAssertNotNil(error, @"Error must containt correct info in case of fail");
                                 [expectation fulfill];
                             }];
    [self waitForExpectation];
}

@end