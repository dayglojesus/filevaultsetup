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
        if (![self forceSetup]) {
            if ([self doNotAskAgain]) {
                exit(0);
            }
        }
    }
}

+ (BOOL)doNotAskAgain
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:FVSDoNotAskForSetup];
}

+ (void)setDoNotAskAgain:(BOOL)askAgain
{
    [[NSUserDefaults standardUserDefaults] setBool:askAgain
                                            forKey:FVSDoNotAskForSetup];
}

+ (BOOL)forceSetup
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:FVSForceSetup];
}

+ (void)setForceSetup:(BOOL)setup;
{
    [[NSUserDefaults standardUserDefaults] setBool:setup
                                            forKey:FVSForceSetup];
}

- (IBAction)showSetupSheet:(id)sender
{
    if (!setupController) {
        setupController = [[FVSSetupWindowController alloc] init];
    }
    NSLog(@"showing %@", setupController);
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
}

- (IBAction)enable:(id)sender
{
    [self showSetupSheet:nil];
//    [NSApp endSheet:[self window]];
//    [[self window] orderOut:sender];
}

- (IBAction)noEnable:(id)sender
{
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

@end
