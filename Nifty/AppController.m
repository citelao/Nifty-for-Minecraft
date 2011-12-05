//
//  AppController.m
//  Nifty
//
//  Created by Stolovitz on 11/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "RegexKitLite.h"

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
        [server setStandardInput:stdiPipe];
		[server setStandardError:stdoPipe];
		
		[stdo waitForDataInBackgroundAndNotify];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleCommandOutput:) 
													 name:NSFileHandleDataAvailableNotification 
                                                   object:stdo];
        [server launch];
        
        
    }
    
    return self;
}

- (void)handleCommandOutput:(NSNotification *)aNotification
{
	if([server isRunning] == YES) {
        //Prepare data string
		NSFileHandle *handleNotif = [aNotification object];
		NSData *data = [handleNotif availableData];
		NSString *unparsedData = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		[handleNotif waitForDataInBackgroundAndNotify];
        
        //Parse data with stringReplace
        NSString *regEx = @"([>][\n\r]*)([0-9:]*) *([\\[A-Z\\]]*) *([0-9A-Za-z<>. *:!]*)";
        NSString *parsedData = [[unparsedData stringByReplacingOccurrencesOfRegex:regEx withString:@"$4 $2"] stringByReplacingOccurrencesOfString:@"[0m" withString:@""];
//        NSString *parsedData = unparsedData;
        //NSLog(@"Notification: %@",str);
        
		[[[debugCommandOutput textStorage] mutableString] appendString: parsedData];
        [debugCommandOutput scrollRangeToVisible: NSMakeRange ([[debugCommandOutput string] length], 0)];
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
