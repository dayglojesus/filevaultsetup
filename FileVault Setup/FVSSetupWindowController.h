//
//  FVSSetupWindowController.h
//  FileVault Setup
//
//  Created by Brian Warsing on 2013-03-05.

/*
 * Copyright (c) 2013 Simon Fraser Universty. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
#import <OpenDirectory/OpenDirectory.h>
#import "FVSConstants.h"

@interface FVSSetupWindowController : NSWindowController {
    NSString *username;
}

@property (assign) IBOutlet NSWindow *sheet;
@property (weak) IBOutlet NSTextField *message;
@property (weak) IBOutlet NSSecureTextField *password;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet NSButton *setup;
@property (weak) IBOutlet NSButton *cancel;

- (IBAction)setupAction:(NSButton *)sender;
- (IBAction)cancelAction:(NSButton *)sender;

- (void)harlemShake:(NSString *)message;
- (BOOL)passwordMatch:(NSString *)password forUsername:(NSString *)name;
- (void)runFileVaultSetupForUser:(NSString *)name
                    withPassword:(NSString *)passwordString;


@end
