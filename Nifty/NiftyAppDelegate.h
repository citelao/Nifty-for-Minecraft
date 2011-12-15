//
//  NiftyAppDelegate.h
//  Nifty
//
//  Created by Ben Stolovitz on 11/27/11.
//  Copyright 2011 Ben Stolovitz.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//	this software and associated documentation files (the "Software"), to deal in
//	the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to do
//	so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

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