//
//  HydraKillerLauncherUITestsLaunchTests.m
//  HydraKillerLauncherUITests
//
//  Created by James Cuzella on 5/20/26.
//  Copyright (C) © 🄯  2026 LyraPhase. All rights reserved.
//  Copyright (C) © 🄯  2026 James Cuzella. All rights reserved.
//
/*
  This program is free software: you can redistribute it and/or modify it under
  the terms of the GNU Affero General Public License as published by the Free
  Software Foundation, either version 3 of the License, or (at your option) any
  later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
  details.

  You should have received a copy of the GNU Affero General Public License along
  with this program. If not, see <https://www.gnu.org/licenses/>.
*/

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
