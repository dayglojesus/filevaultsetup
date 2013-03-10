//
//  FVSAppDelegate.m
//  FileVault Setup
//
//  Created by Brian Warsing on 2013-03-05.
//  Copyright (c) 2013 Simon Fraser Universty. All rights reserved.
//

#import "FVSAppDelegate.h"

NSString * const FVSDoNotAskForSetup = @"FVSDoNotAskForSetup";
NSString * const FVSForceSetup = @"FVSForceSetup";

@implementation FVSAppDelegate

+ (void)initialize
{
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setObject:[NSNumber numberWithBool:NO]
                      forKey:FVSDoNotAskForSetup];
    [defaultValues setObject:[NSNumber numberWithBool:NO]
                      forKey:FVSForceSetup];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    
    NSString *username = [[NSUserDefaults standardUserDefaults]
                          objectForKey:@"user"];
    
    if ([username length]) {
        [NSMenu setMenuBarVisible:NO];
        if (![[NSUserDefaults standardUserDefaults]
              valueForKeyPath:FVSForceSetup]) {
            if ([[NSUserDefaults standardUserDefaults]
                 valueForKeyPath:FVSDoNotAskForSetup]) {
                exit(0);
            }
        }
    }
}

- (IBAction)showSetupSheet:(id)sender
{
    if (!setupController) {
        setupController = [[FVSSetupWindowController alloc] init];
    }
    [NSApp beginSheet: [setupController window]
       modalForWindow: _window
        modalDelegate: self
       didEndSelector: @selector(didEndSetupSheet:)
          contextInfo: NULL];
}

- (IBAction)didEndSetupSheet:(id)sender
{
    [NSApp endSheet:[setupController window]];
    [[setupController window] orderOut:sender];
    setupController = nil;
}

- (IBAction)enable:(id)sender
{
    [self showSetupSheet:nil];
//    [NSApp endSheet:[self window]];
//    [[self window] orderOut:sender];
}

- (IBAction)noEnable:(id)sender
{
    [_window close];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    if ([[NSUserDefaults standardUserDefaults] valueForKeyPath:FVSForceSetup]) {
        [_instruct setFont:[NSFont
                            fontWithName:@"Lucida Grande Bold" size:13.0]];
        [_instruct setStringValue:@"Policy set by your administrator requires \
that you activate FileVault before you can login to this workstation. Please \
click the enable button to continue."];
    }

    
    // Setup the main window
    [_window makeKeyAndOrderFront:NSApp];
    [_window setCanBecomeVisibleWithoutLogin:YES];
    [_window setLevel:2147483631];
    [_window orderFrontRegardless];
    [_window makeKeyWindow];
    [_window becomeMainWindow];
    [_window center];
}

@end
