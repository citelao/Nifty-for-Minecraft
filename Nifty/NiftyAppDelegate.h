//
//  NiftyAppDelegate.h
//  Nifty
//
//  Created by Stolovitz on 11/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NiftyAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    
    IBOutlet NSTableView *commandOutput;
    IBOutlet NSTextView *debugCommandOutput;
    NSTask *server;
    NSFileHandle *stdi;
    NSFileHandle *stdo;
}

@property (assign) IBOutlet NSWindow *window;

- (void)applicationWillTerminate:(NSNotification *)aNotification;

- (void)handleCommandOutput:(NSNotification *)aNotification;
- (IBAction)handleCommandInput:(id)sender;
- (void)handleCommandInput:(id)sender withInput:(NSString *)data;

@end
