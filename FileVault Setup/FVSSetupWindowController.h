//
//  FVSSetupWindowController.h
//  FileVault Setup
//
//  Created by Brian Warsing on 2013-03-05.
//  Copyright (c) 2013 Simon Fraser Universty. All rights reserved.
//

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
