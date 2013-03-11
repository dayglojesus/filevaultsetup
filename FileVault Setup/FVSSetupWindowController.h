//
//  FVSSetupWindowController.h
//  FileVault Setup
//
//  Created by Brian Warsing on 2013-03-05.
//  Copyright (c) 2013 Simon Fraser Universty. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>
#import <CommonCrypto/CommonCrypto.h>
#import "FVSConstants.h"

@interface FVSSetupWindowController : NSWindowController {
    NSString *username;
}

@property (assign) IBOutlet NSTextField *message;
@property (assign) IBOutlet NSWindow *sheet;
@property (weak) IBOutlet NSSecureTextField *password;
@property (weak) IBOutlet NSSecureTextField *passwordVerify;
@property (weak) IBOutlet NSProgressIndicator *spinner;

- (IBAction)setup:(NSButton *)sender;
- (IBAction)cancel:(NSButton *)sender;

- (void)harlemShake:(NSString *)message;
- (NSDictionary *)passwordDataForUser:(NSString *)name;
- (BOOL)passwordMatch:(NSString *)password forUsername:(NSString *)name;
- (void)runFileVaultSetupForUser:(NSString *)name
                    withPassword:(NSString *)passwordString;


@end
