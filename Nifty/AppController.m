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
        NSArray *args = [NSArray arrayWithObjects:@"-Xms1024M",
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
        [server launch];
    }
    
    return self;
}

- (void)handleCommandOutput:(id)sender 
{
    NSLog(@"MOO");
}

-(IBAction)handleCommandInput:(id)sender
{
    NSLog(@"Sending '%@'", [commandInput stringValue]);
    [stdi writeData:[[commandInput stringValue] dataUsingEncoding:NSUTF8StringEncoding]];
    [stdi writeData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}
    
@end
