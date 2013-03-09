//
//  FVSSetupWindowController.m
//  FileVault Setup
//
//  Created by Brian Warsing on 2013-03-05.
//  Copyright (c) 2013 Simon Fraser Universty. All rights reserved.
//

#import "FVSSetupWindowController.h"

@implementation FVSSetupWindowController

static int numberOfShakes = 4;
static float durationOfShake = 0.4f;
static float vigourOfShake = 0.02f;

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

- (CAKeyframeAnimation *)shakeAnimation:(NSRect)frame
{
    CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animation];
	
    CGMutablePathRef shakePath = CGPathCreateMutable();
    CGPathMoveToPoint(shakePath, NULL, NSMinX(frame), NSMinY(frame));
	int index;
	for (index = 0; index < numberOfShakes; ++index)
	{
		CGPathAddLineToPoint(shakePath,
                             NULL,
                             NSMinX(frame) - frame.size.width * vigourOfShake,
                             NSMinY(frame));
		CGPathAddLineToPoint(shakePath,
                             NULL,
                             NSMinX(frame) + frame.size.width * vigourOfShake,
                             NSMinY(frame));
	}
    CGPathCloseSubpath(shakePath);
    shakeAnimation.path = shakePath;
    shakeAnimation.duration = durationOfShake;
    return shakeAnimation;
}

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
        [self shakeIt:@"Passwords Do Not Match"];
    } else {
        if ([self passwordMatch:[_password stringValue]
                    forUsername:username]) {
            [self runFileVaultSetup];
        } else {
            // Shake it!
            [self shakeIt:@"Password Incorrect"];
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

- (void)shakeIt:(NSString *)message
{
    [_message setStringValue:message];
    [_sheet setAnimations:[NSDictionary
                           dictionaryWithObject:[self
                                                 shakeAnimation:[_sheet frame]]
                           forKey:@"frameOrigin"]];
	[[_sheet animator] setFrameOrigin:[_sheet frame].origin];
}

- (void)runFileVaultSetup
{
    
}

@end
