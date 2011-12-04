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
    IBOutlet NSTextView *debugCommandOutput;
    NSTask *server;
    NSFileHandle *stdi;
    NSFileHandle *stdo;
}

- (void)handleCommandOutput:(NSNotification *)aNotification;
- (IBAction)handleCommandInput:(id)sender;
- (void)handleCommandInput:(id)sender withInput:(NSString *)data;

@end
