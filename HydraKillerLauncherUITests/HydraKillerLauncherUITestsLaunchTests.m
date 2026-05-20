//
//  HydraKillerLauncherUITestsLaunchTests.m
//  HydraKillerLauncherUITests
//
//  Created by James Cuzella on 5/20/26.
//  Copyright © 2026 LyraPhase. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface HydraKillerLauncherUITestsLaunchTests : XCTestCase

@end

@implementation HydraKillerLauncherUITestsLaunchTests

+ (BOOL)runsForEachTargetApplicationUIConfiguration {
    return YES;
}

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testLaunch {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Insert steps here to perform after app launch but before taking a screenshot,
    // such as logging into a test account or navigating somewhere in the app

    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    attachment.name = @"Launch Screen";
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

@end
