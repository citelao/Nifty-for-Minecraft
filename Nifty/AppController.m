//
//  AppController.m
//  Nifty
//
//  Created by Stolovitz on 11/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

@implementation AppController

- (id)init
{
    self = [super init];
    if (self) {
        server = [[NSTask alloc] init];
        NSPipe *stdiPipe = [[NSPipe alloc] init];
        stdi = [stdiPipe fileHandleForWriting];
        NSPipe *stdoPipe = [[NSPipe alloc] init];
        stdo = [stdoPipe fileHandleForReading];
        NSArray *args = [NSArray arrayWithObjects: @"-Xms1024M",
                         @"-Xmx1024M",
                         @"-jar",
                         @"minecraft_server.jar",
                         @"nogui",
                         nil];
        
        [server setLaunchPath:@"/usr/bin/java"];
        [server setCurrentDirectoryPath:@"Nifty.app/Contents/Resources/"];
        [server setArguments:args];
        [server setStandardOutput:stdoPipe];
        [server setStandardInput:stdiPipe];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleCommandOutput:) 
                                                     name: NSFileHandleReadCompletionNotification 
                                                   object: stdo];
        [stdo readInBackgroundAndNotify];
        [server launch];
        
        
    }
    
    return self;
}

- (void)handleCommandOutput: (NSNotification *)aNotification
{
    NSLog(@"Notification: %@", aNotification);
    
}

- (IBAction)handleCommandInput: (id)sender
{
    [self handleCommandInput:sender 
                   withInput:[sender stringValue]];
}

- (void)handleCommandInput: (id)sender withInput: (NSString *)data 
{
    NSLog(@"Sending '%@'", data);
    [stdi writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    [stdi writeData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
