//
//  AssetWrapperTests.m
//  AVPlayerCache
//
//  Created by Dmitry on 25.08.15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "AVURLAssetCacheWrapper.h"
#import "AVURLAsset+URLSchemeModifier.h"
#import "Constants.h"

@interface AssetWrapperTests : XCTestCase

@end

@implementation AssetWrapperTests

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

- (void)testNewAVURLAsset {
    NSURL *url = [NSURL URLWithString:mp4SourceURL];
    AVURLAsset *asset = [AVURLAsset cachedURLAssetWithURL:url options:nil];
    XCTAssertNotNil(asset, @"Asset must not be nil");
    XCTAssertEqualObjects([asset class], [AVURLAssetCacheWrapper class], @"Assert must be wrapped into caching wrapper");
    NSString *scheme = asset.URL.scheme;
    scheme = [scheme stringByReplacingOccurrencesOfString:url.scheme withString:@""];
    XCTAssertEqualObjects(scheme, @"cached", @"URL scheme of wrapped object must start with \"cached\" prefix");
}

@end