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
@synthesize setup = _setup;
@synthesize cancel = _cancel;

- (id)init
{
    self = [super initWithWindowNibName:@"FVSSetupWindowController"];
    
    username = [[NSUserDefaults standardUserDefaults] objectForKey:FVSUsername];
    
    int result = seteuid(0);
    if (!result == 0) {
        NSLog(@"Could not set UID, error: %i", result);
//        exit(result);
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

- (IBAction)setupAction:(NSButton *)sender
{
    if ([self passwordMatch:[_password stringValue] forUsername:username]) {
        [self runFileVaultSetupForUser:username
                          withPassword:[_password stringValue]];
    } else {
        // Shake it!
        [self harlemShake:@"Password Incorrect"];
    }
}

- (IBAction)cancelAction:(NSButton *)sender
{
    [NSApp endSheet:[self window] returnCode:-1];
}

- (BOOL)passwordMatch:(NSString *)password forUsername:(NSString *)name
{
    BOOL match = NO;
	ODSessionRef session = NULL;
	ODNodeRef node = NULL;
	ODRecordRef	rec = NULL;
    
    session = ODSessionCreate(NULL, NULL, NULL);
    node = ODNodeCreateWithNodeType(NULL,
                                    session,
                                    kODNodeTypeAuthentication,
                                    NULL);
    if (node) {
        rec = ODNodeCopyRecord(node,
                               kODRecordTypeUsers,
                               (__bridge CFStringRef)(name),
                               NULL,
                               NULL);
    }
    if (rec) {
        match = ODRecordVerifyPassword(rec,
                                       (__bridge CFStringRef)(password),
                                       NULL);
    }
    
    return match;
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
    // UI Setup
    [_setup setEnabled:NO];
    [_cancel setEnabled:NO];
    [_message setStringValue:@"Running..."];
    [_spinner startAnimation:self];

    // Setup Task args
    NSMutableArray *task_args = [NSMutableArray arrayWithObjects:@"enable",
                                 @"-outputplist", @"-inputplist", nil];
    if ([[NSFileManager defaultManager]
         fileExistsAtPath:@"/Library/Keychains/FileVaultMaster.keychain"]) {
        [task_args insertObject:@"-keychain" atIndex:1];
    }
    
    // Property List Out
    NSString *outputFile = @"/private/var/root/fdesetup_output.plist";
    [[NSFileManager defaultManager] createFileAtPath:outputFile
                                            contents:nil
                                          attributes:nil];
    NSFileHandle *outHandle = [NSFileHandle
                               fileHandleForWritingAtPath:outputFile];
    
    // The Property List for Input
    NSDictionary *input = @{ @"Username" : name, @"Password" : passwordString };
    
    // Task Setup
    NSTask *theTask = [[NSTask alloc] init];
    [theTask setLaunchPath:@"/usr/bin/fdesetup"];
    [theTask setArguments:task_args];
    [theTask setStandardOutput:outHandle];
    
    NSPipe *errorPipe = [NSPipe pipe];
    [theTask setStandardError:errorPipe];
    
    NSPipe *inputPipe = [NSPipe pipe];
    [theTask setStandardInput:inputPipe];
    NSFileHandle *writeHandle = [inputPipe fileHandleForWriting];
    
    // Task Run
    [theTask launch];
    
    // Task Input
    NSData *data = [NSPropertyListSerialization
                    dataFromPropertyList:input
                    format:NSPropertyListBinaryFormat_v1_0
                    errorDescription:nil];
    
    [writeHandle writeData:data];
    [writeHandle closeFile];
    
    // Task Error
    NSString *error = [[NSString alloc]
                       initWithData:[[errorPipe fileHandleForReading]
                                     readDataToEndOfFile]
                       encoding:NSUTF8StringEncoding];
    
    // if the last char or error is a newline, remove it
    if ([error characterAtIndex:[error length] -1] == NSNewlineCharacter) {
        error = [error substringToIndex:[error length] -1];
    }
    
    // Clean up
    [theTask waitUntilExit];
    
    // Close
    int result = [theTask terminationStatus];

    [[NSUserDefaults standardUserDefaults]
        setObject:error
           forKey:FVSLastErrorMessage];
    
    [NSApp endSheet:[self window] returnCode:result];
}

- (void)dealloc
{
    int result = seteuid([[[NSUserDefaults standardUserDefaults]
              objectForKey:FVSUid] intValue]);

    if (!result == 0) {
        NSLog(@"Could not set UID, error: %i", result);
        exit(result);
    }
}

@end
