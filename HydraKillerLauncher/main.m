//
//  main.m
//  HydraKillerLauncher
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

#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *helperBundleIdentifier = @"com.lyraphase.HydraKillerLauncher.truncatesyndication";
        NSString *plistName = @"com.lyraphase.truncatesyndication.plist";

        // 1. Runtime Check: If running on macOS 13 (Ventura) or newer
        if (@available(macOS 13.0, *)) {
            SMAppService *agentService = [SMAppService agentServiceWithPlistName:plistName];

            if (agentService.status == SMAppServiceStatusNotRegistered) {
                NSError *error = nil;
                BOOL success = [agentService registerAndReturnError:&error];
                if (success) {
                    NSLog(@"[HydraKiller] Modern LaunchAgent registered.");
                } else {
                    NSLog(@"[HydraKiller] Modern registration failed: %@", error.localizedDescription);
                }
            }
        }
        // 2. Fallback Check: If running on macOS 12 (Monterey) or older
        else {
            NSLog(@"[HydraKiller] Running on macOS 12 or older. Falling back to SMLoginItemSetEnabled.");

            // SMLoginItemSetEnabled takes a Boolean to enable/disable the helper
            // Note: This requires the helper to reside in Contents/Library/LoginItems
            BOOL success = SMLoginItemSetEnabled((__bridge CFStringRef)helperBundleIdentifier, YES);

            if (success) {
                NSLog(@"[HydraKiller] Legacy LoginItem helper enabled successfully.");
            } else {
                NSLog(@"[HydraKiller] Legacy LoginItem registration failed.");
            }
        }
    }
    return NSApplicationMain(argc, argv);
}
