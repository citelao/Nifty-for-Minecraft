//
//  NiftyAppDelegate.m
//  Nifty
//
//  Created by Stolovitz on 11/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NiftyAppDelegate.h"

@implementation NiftyAppDelegate

@synthesize window;

- (id)init
{
    self = [super init];
    
    [[NSApplication sharedApplication] setDelegate:self];
    
    if (self) {
        // usr/bin/java -Xms1024M -Xmx1024M -jar bukkit.jar nogui
        
        server = [[NSTask alloc] init];
        NSPipe *stdiPipe = [[NSPipe alloc] init];
        NSPipe *stdoPipe = [[NSPipe alloc] init];
        stdi = [stdiPipe fileHandleForWriting];
        stdo = [stdoPipe fileHandleForReading];
        NSString *serverType = @"bukkit.jar";
        NSArray *args = [NSArray arrayWithObjects: @"-Xms1024M",
                         @"-Xmx1024M",
                         @"-jar",
                         serverType,
                         @"nogui",
                         nil];
        
        [server setLaunchPath:@"/usr/bin/java"];
        [server setCurrentDirectoryPath:@"Nifty.app/Contents/Resources/"];
        [server setArguments:args];
        [server setStandardOutput:stdoPipe];
        [server setStandardError:stdoPipe];
        [server setStandardInput:stdiPipe];
		
		[stdo waitForDataInBackgroundAndNotify];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleCommandOutput:) 
													 name:NSFileHandleDataAvailableNotification 
                                                   object:stdo];
        [server launch];
    }
    
    return self;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [self handleCommandInput:@"" withInput:@"stop"];
}

- (void)handleCommandOutput:(NSNotification *)aNotification
{
	if([server isRunning] == YES) {
        //Prepare data string
		NSFileHandle *handleNotif = [aNotification object];
		NSData *data = [handleNotif availableData];
		NSString *unparsedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[handleNotif waitForDataInBackgroundAndNotify];
        
        //Split by line
        NSMutableArray *dataLines = [[unparsedData componentsSeparatedByString: @"\n"] mutableCopy];
        
        for (id object in dataLines) {
            if(![object isEqualToString: @""]) {                
                [[[debugCommandOutput textStorage] mutableString] appendString:object];
                [debugCommandOutput scrollRangeToVisible: NSMakeRange ([[debugCommandOutput string] length], 0)];
            }
        }
	} else {
		NSLog(@"Server stopped.");
	}
	
}

- (IBAction)handleCommandInput:(id)sender
{
    [self handleCommandInput:sender 
                   withInput:[sender stringValue]];
	[sender setStringValue:@""];
}

- (void)handleCommandInput:(id)sender withInput:(NSString *)data 
{
    NSLog(@"Sending '%@'", data);
    [stdi writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    [stdi writeData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
