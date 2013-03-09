//
//  FVSSetupWindowController.m
//  FileVault Setup
//
//  Created by Brian Warsing on 2013-03-05.
//  Copyright (c) 2013 Simon Fraser Universty. All rights reserved.
//

#import "FVSSetupWindowController.h"

@implementation FVSSetupWindowController

@synthesize password = _password;
@synthesize passwordVerify = _passwordVerify;

- (id)init
{
    self = [super initWithWindowNibName:@"FVSSetupWindowController"];
    username = NSUserName();
    if ([username isEqualToString:@"root"]) {
        username = [[NSUserDefaults standardUserDefaults]
                    objectForKey:@"user"];
    }
    return self;
}

//- (id)initWithWindow:(NSWindow *)window
//{
//    self = [super initWithWindow:window];
//    if (self) {
//        // Initialization code here.
//    }
//    
//    return self;
//}

- (void)windowDidLoad
{
    [super windowDidLoad];
}


- (NSString *)username
{
    return username;
}

- (void)setUsername:(NSString *)name
{
    username = name;
}

- (IBAction)setup:(NSButton *)sender
{
    if (![[_password stringValue]
          isEqualToString:[_passwordVerify stringValue]]) {
        // Notify!
    } else {
        if ([self passwordMatch:[_password stringValue]
                    forUsername:username]) {
            [self runFileVaultSetup];
        } else {
            // Notify
        }
    }
}

- (IBAction)cancel:(NSButton *)sender
{
    [NSApp endSheet:[self window]];
    [[self window] orderOut:sender];
}

- (BOOL)passwordMatch:(NSString *)password forUsername:(NSString *)username
{
    BOOL result = NO;
    
    return result;
}

- (void)runFileVaultSetup
{
    
}

@end
