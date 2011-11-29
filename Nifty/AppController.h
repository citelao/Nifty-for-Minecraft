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
    IBOutlet NSTextField *commandInput;
    IBOutlet NSTextView *debugCommandOutput;
    NSTask *server;
    NSFileHandle *stdi;
    NSFileHandle *stdo;
}

-(void)handleCommandOutput:(id)sender;
-(IBAction)handleCommandInput:(id)sender;

@end
