//
//  NiftyAppDelegate.h
//  Nifty
//
//  Created by Ben Stolovitz on 11/27/11.
//  Copyright 2011 Ben Stolovitz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NiftyAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    
    IBOutlet NSArrayController *commandOutputController;
    IBOutlet NSTableView *commandOutput;
    IBOutlet NSTextView *debugCommandOutput;
    
	NSString *serverType;
	NSString *serverLoc;
	
    NSTask *server;
    NSFileHandle *stdi;
    NSFileHandle *stdo;
	
	NSMutableArray *commandHist;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSArrayController *commandOutputController;
@property (assign) IBOutlet NSTableView *commandOutput;


- (void)applicationWillTerminate:(NSNotification *)aNotification;

- (void)handleCommandOutput:(NSNotification *)aNotification;
- (NSString *)stripRawOutput:(NSString *)rawDatum;
- (NSArray *)stripByRegex:(NSString *)finalDatum;

- (IBAction)handleCommandInput:(id)sender;
- (void)handleCommandInputWithInput:(NSString *)data;

@end