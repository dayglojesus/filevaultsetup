//
//  FVSAppDelegate.h
//  FileVault Setup
//
//  Created by Brian Warsing on 2013-03-05.
//  Copyright (c) 2013 Simon Fraser Universty. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FVSSetupWindowController.h"
#import "FVSConstants.h"

@interface FVSAppDelegate : NSObject <NSApplicationDelegate> {
    FVSSetupWindowController *setupController;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *instruct;

+ (BOOL)rootVolumeIsEncrypted;

- (IBAction)showSetupSheet:(id)sender;
- (IBAction)didEndSetupSheet:(id)sender returnCode:(int)result;

- (void)setupDidEndWithError:(NSAlert *)alert;
- (void)setupDidEndWithSuccess:(NSAlert *)alert;
- (void)setupDidEndWithAlreadyEnabled:(NSAlert *)alert;
- (void)setupDidEndWithNotRoot:(NSAlert *)alert;

- (void)restart;
- (IBAction)enable:(id)sender;
- (IBAction)noEnable:(id)sender;

@end
