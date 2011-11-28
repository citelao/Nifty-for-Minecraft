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
        pipe = [NSPipe pipe];
        NSArray *args = [NSArray arrayWithObjects:@"-Xms1024M",
                            @"-Xmx1024M",
                            @"-jar",
                            @"minecraft_server.jar",
                            nil];
        
        [server setLaunchPath:@"/usr/bin/java"];
        [server setCurrentDirectoryPath:@"Nifty.app/Contents/Resources/"];
        [server setArguments:args];
        [server setStandardOutput:pipe];
        [server setStandardInput:pipe];
        [server launch];
    }
    
    return self;
}

- (void)handleCommandOutput:(id)sender 
{
    NSLog(@"MOO");
}
    
@end
