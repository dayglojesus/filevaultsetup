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

- (IBAction)showSetupSheet:(id)sender;
- (IBAction)didEndSetupSheet:(id)sender;

- (IBAction)enable:(id)sender;
- (IBAction)noEnable:(id)sender;

@end
