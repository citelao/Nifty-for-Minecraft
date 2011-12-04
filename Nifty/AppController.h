//
//  AppController.h
//  Nifty
//
//  Created by Stolovitz on 11/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppController : NSObject {
    IBOutlet NSTableView *commandOutput;
<<<<<<< HEAD
    IBOutlet NSTextField *commandInput;
=======
>>>>>>> parent of 7779355... Transfered old Nifty site. Prepare for upload.
    IBOutlet NSTextView *debugCommandOutput;
    NSTask *server;
    NSFileHandle *stdi;
    NSFileHandle *stdo;
}

<<<<<<< HEAD
- (void)handleCommandOutput: (NSNotification *)aNotification;
- (IBAction)handleCommandInput: (id)sender;
- (void)handleCommandInput: (id)sender withInput: (NSString *)data;
=======
- (void)handleCommandOutput:(NSNotification *)aNotification;
- (IBAction)handleCommandInput:(id)sender;
- (void)handleCommandInput:(id)sender withInput:(NSString *)data;
>>>>>>> parent of 7779355... Transfered old Nifty site. Prepare for upload.

@end
