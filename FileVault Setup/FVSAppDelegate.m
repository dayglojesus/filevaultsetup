//
//  FVSAppDelegate.m
//  FileVault Setup
//
//  Created by Brian Warsing on 2013-03-05.
//  Copyright (c) 2013 Simon Fraser Universty. All rights reserved.
//

#import "FVSAppDelegate.h"
#include <SystemConfiguration/SystemConfiguration.h>
#include <IOKit/IOKitLib.h>
#include <DiskArbitration/DASession.h>

NSString * const FVSDoNotAskForSetup = @"FVSDoNotAskForSetup";
NSString * const FVSForceSetup = @"FVSForceSetup";
NSString * const FVSUsername = @"FVSUsername";
NSString * const FVSUid = @"FVSUid";
NSString * const FVSLastErrorMessage = @"FVSLastErrorMessage";
NSString * const FVSStatus = @"FVSStatus";

@implementation FVSAppDelegate

+ (void)initialize
{
    // Grab the username and the uid of the Console user
    uid_t uid;
    NSString *username =
        CFBridgingRelease(SCDynamicStoreCopyConsoleUser(NULL, &uid, NULL));
    
    // UID Switcheroo
    // If the app is run using a loginhook, it will have UID 0, but we want
    // to use the NSUserDefaults for the Console user. Setting the Effective
    // UID for the process allows us to run the app as the user.
    int result = seteuid(uid);
    
    if (!result == 0) {
        NSLog(@"Could not set UID, error: %i", result);
        exit(result);
    }
    
    // Register defaults
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    [defaultValues setObject:[NSNumber numberWithBool:NO]
                      forKey:FVSDoNotAskForSetup];
    [defaultValues setObject:[NSNumber numberWithBool:NO]
                      forKey:FVSForceSetup];
    [defaultValues setObject:username
                      forKey:FVSUsername];
    [defaultValues setObject:[NSNumber numberWithInt:uid]
                      forKey:FVSUid];
    [defaultValues setObject:@""
                      forKey:FVSLastErrorMessage];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    
    // Establish the startup mode
    // Are we root? If so, hide the menu bar.
    // Is this a forced setup? If so, register the default.
    // If the user has opted out, simply exit.
    if ([username length]) {
        [NSMenu setMenuBarVisible:NO];
        if (![[[NSUserDefaults standardUserDefaults]
              valueForKeyPath:FVSForceSetup] boolValue]) {
            if ([[[NSUserDefaults standardUserDefaults]
                 valueForKeyPath:FVSDoNotAskForSetup] boolValue]) {
                exit(0);
            }
        }
    }
}

// Returns the encryption state of the root volume
- (BOOL) rootVolumeIsEncrypted
{
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                                 CFSTR("/"),
                                                 kCFURLPOSIXPathStyle,
                                                 true);
    
    DASessionRef session = DASessionCreate(kCFAllocatorDefault);
    DADiskRef disk = DADiskCreateFromVolumePath(kCFAllocatorDefault,
                                                session,
                                                url);
    
    io_service_t diskService = DADiskCopyIOMedia(disk);
    CFTypeRef isEncrypted = IORegistryEntryCreateCFProperty(diskService,
                                                CFSTR("CoreStorage Encrypted"),
                                                kCFAllocatorDefault,
                                                0);
    
    BOOL state = NO;
    if (isEncrypted) {
        CFRelease(isEncrypted);
        state = YES;
    }
    
    CFRelease(disk);
    CFRelease(url);
    CFRelease(session);
    IOObjectRelease(diskService);
    
    return state;
}

- (IBAction)showSetupSheet:(id)sender
{
    if (!setupController) {
        setupController = [[FVSSetupWindowController alloc] init];
    }
    
    [NSApp beginSheet: [setupController window]
       modalForWindow: _window
        modalDelegate: self
       didEndSelector: @selector(didEndSetupSheet:returnCode:)
          contextInfo: NULL];
}

- (IBAction)didEndSetupSheet:(id)sender returnCode:(int)result
{
    [NSApp endSheet:[setupController window]];
    [[setupController window] orderOut:sender];
    setupController = nil;
    
    // Error
    NSString *error = [[NSUserDefaults standardUserDefaults]
                       valueForKeyPath:FVSLastErrorMessage];
    
    // Basic Alert
    NSAlert *alert = [[NSAlert alloc] init];
    SEL theSelector = @selector(setupDidEndWithError:);
    
    // What kind of alert?
    if (result == -1) {
        // Cancelled
        NSLog(@"User canceled operation");
    } else if (result == 0) {
        // Success
        theSelector = @selector(setupDidEndWithSuccess:);
        [alert setMessageText:@"Restart Required"];
        [alert setInformativeText:@"Click OK to restart and complete the setup."];
    } else {
        // Failure
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"FileVault Setup Error"];
        [alert setInformativeText:
            [error stringByAppendingString:[NSString stringWithFormat:@" [%d]",
                                         result]]];
    }
    
    // Only alert on error or success, not on cancel
    if (result > -1) {
        NSLog(@"%@ [%d]", error, result);
        [alert beginSheetModalForWindow:_window
                          modalDelegate:self
                         didEndSelector:theSelector
                            contextInfo:nil];
    }
    
}

- (void)setupDidEndWithError:(NSAlert *)alert
{
    NSLog(@"Setup encountered an error.");
}

- (void)setupDidEndWithSuccess:(NSAlert *)alert
{
    NSLog(@"Setup complete. Restarting...");
}

- (void)setupDidEndWithAlreadyEnabled:(NSAlert *)alert
{
    NSLog(@"FileVault is already enabled.");
    [_window close];
}

- (void)setupDidEndWithNotRoot:(NSAlert *)alert
{
    NSLog(@"You must be an administrator to enable FileVault.");
}

- (void)setupDidEndWithNetworkUser:(NSAlert *)alert
{
    NSLog(@"Network cannot enable FileVault on their first login.");
    [_window close];
}

- (IBAction)enable:(id)sender
{
    // Is FileVault enabled?
    BOOL fvstate = [self rootVolumeIsEncrypted];
    
    if (fvstate == YES) {
        // ALERT
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Already Enabled"];
        [alert setInformativeText:@"FileVault has already been enabled."];
        [alert beginSheetModalForWindow:_window
                          modalDelegate:self
                         didEndSelector:@selector(setupDidEndWithAlreadyEnabled:)
                            contextInfo:nil];
    }
    
    // Are we running as root?
    uid_t realuid = getuid();

    if (!realuid == 0) {
        BOOL doNotAskForSetup = [[[NSUserDefaults standardUserDefaults]
                              objectForKey:FVSDoNotAskForSetup] boolValue];
        NSString *info = @"FileVault will be enabled at your next login.";
        // ALERT
        if (doNotAskForSetup == YES) {
            info = @"Remove the checkmark to enable FileVault at next login";
        }
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Requires Logout"];
        [alert setInformativeText:info];
        [alert beginSheetModalForWindow:_window
                          modalDelegate:self
                         didEndSelector:@selector(setupDidEndWithNotRoot:)
                            contextInfo:nil];
    }
    
    // Ensure a cached account for the Console user is available
    // Network accounts present some interesting edge cases...
    NSString *username = [[NSUserDefaults standardUserDefaults]
                            objectForKey:FVSUsername];
    NSString *path = @"/private/var/db/dslocal/nodes/Default/users/";
    NSString *file = [[path stringByAppendingString:username]
                      stringByAppendingString:@".plist"];
    
    // UID Switcheroo
    seteuid(0);
        
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
        NSLog(@"No such file: %@", file);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Network Account"];
        [alert setInformativeText:@"Network cannot enable FileVault on their first login. Try again at next login."];
        [alert beginSheetModalForWindow:_window
                          modalDelegate:self
                         didEndSelector:@selector(setupDidEndWithNetworkUser:)
                            contextInfo:nil];
    }
    
    // UID Switcheroo
    seteuid([[[NSUserDefaults standardUserDefaults]
              objectForKey:FVSUid] intValue]);

    // If all these tests pass...
    [self showSetupSheet:nil];
}

- (IBAction)noEnable:(id)sender
{
    [_window close];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:
    (NSApplication *)theApplication
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    BOOL forcedSetup = [[[NSUserDefaults standardUserDefaults]
                        valueForKeyPath:FVSForceSetup] boolValue];
    
    if (forcedSetup) {
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
