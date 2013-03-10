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
@synthesize spinner = _spinner;

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
    CFRelease(shakePath);
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
        [self harlemShake:@"Passwords Do Not Match"];
    } else {
        if ([self passwordMatch:[_password stringValue]
                    forUsername:username]) {
            [self runFileVaultSetupForUser:username
                              withPassword:[_password stringValue]];
        } else {
            // Shake it!
            [self harlemShake:@"Password Incorrect"];
        }
    }
}

- (IBAction)cancel:(NSButton *)sender
{
    [NSApp endSheet:[self window]];
    [[self window] orderOut:sender];
}

- (BOOL)passwordMatch:(NSString *)password forUsername:(NSString *)name
{
    NSDictionary *passwordData = [self passwordDataForUser:name];

    NSData *entropy = [passwordData objectForKey:@"entropy"];
    NSData *salt = [passwordData objectForKey:@"salt"];
    NSNumber *iterations = [passwordData objectForKey:@"iterations"];
    
    uint8_t key[kCCKeySizeMaxRC2] = {0};
    int result = CCKeyDerivationPBKDF(kCCPBKDF2,
                                      [password UTF8String],
                                      [password lengthOfBytesUsingEncoding:
                                       NSUTF8StringEncoding],
                                      [salt bytes],
                                      [salt length],
                                      kCCPRFHmacAlgSHA512,
                                      [iterations intValue],
                                      key,
                                      kCCKeySizeMaxRC2);
    
    if (result == kCCParamError) {
        //you shouldn't get here with the parameters as above
        NSLog(@"Error in key derivation: %d", result);
        return NO;
    }
    
    NSData *newKey = [NSData dataWithBytes:key length:sizeof(key)];
        
    if ([newKey isEqualToData:entropy]) {
        // NSLog(@"Match!");
        return YES;
    }
    
    return NO;
}

- (NSDictionary *)passwordDataForUser:(NSString *)name
{
    NSString *path = @"/Users/bcw/bcw.plist";
    NSDictionary *userData = [NSDictionary dictionaryWithContentsOfFile:path];
    NSData *passwordData = [[userData objectForKey:@"ShadowHashData"]
                            objectAtIndex:0];
    
    NSDictionary *dict = [NSPropertyListSerialization
                          propertyListFromData:passwordData
                          mutabilityOption:NSPropertyListImmutable
                          format:nil
                          errorDescription:nil];
    
    return [dict objectForKey:@"SALTED-SHA512-PBKDF2"];
}

- (void)harlemShake:(NSString *)message
{
    [_message setStringValue:message];
    [_sheet setAnimations:[NSDictionary
                           dictionaryWithObject:[self
                                                 shakeAnimation:[_sheet frame]]
                           forKey:@"frameOrigin"]];
	[[_sheet animator] setFrameOrigin:[_sheet frame].origin];
}

- (void)runFileVaultSetupForUser:(NSString *)name
                    withPassword:(NSString *)passwordString
{
    [_message setStringValue:@"Running..."];
    [_spinner startAnimation:self];
}

@end
