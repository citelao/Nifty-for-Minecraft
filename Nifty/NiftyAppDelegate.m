//
//  NiftyAppDelegate.m
//  Nifty
//
//  Created by Ben Stolovitz on 11/27/11.
//  Copyright 2011 Ben Stolovitz. All rights reserved.
//

#import "NiftyAppDelegate.h"
#import "RegexKitLite.h"

@implementation NiftyAppDelegate

@synthesize window;

- (id)init {
    self = [super init];
    
    [[NSApplication sharedApplication] setDelegate:self];
	
	commandHist = [[NSMutableArray alloc] init];
	lastCommand = [[NSString alloc] init];
    
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
	if (stdi) {
		[self handleCommandInputWithInput:@"stop"];
	}
}

- (void)handleCommandOutput:(NSNotification *)aNotification {
	if ([server isRunning] == YES) {
        //Prepare data string
		NSFileHandle *handleNotif = [aNotification object];
		NSData *data = [handleNotif availableData];
		NSString *unparsedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[handleNotif waitForDataInBackgroundAndNotify];
        
        //Split by line
        NSArray *dataLines = [unparsedData componentsSeparatedByString: @"\n"];
		[unparsedData release];
        
        for (id object in dataLines) {
			NSMutableString *mutableDatum = [NSMutableString stringWithString:object];
			
			//Have to constantly make sure the string is not nil or it throws errors.
			
			//Check for ending ">"
			if ( [mutableDatum length] > 0 ) {
				if ( [[mutableDatum substringFromIndex: [mutableDatum length] - 1 ] isEqualToString: @">"] ) {
					[mutableDatum setString: [mutableDatum substringToIndex:[mutableDatum length] - 1]];
				}
			}
			
			//Check for beginning ">"
			if ( [mutableDatum length] > 0 ) {
				if( [[mutableDatum substringToIndex: 1 ] isEqualToString: @">"] ) {
					[mutableDatum setString: [mutableDatum substringFromIndex:1]];
				}
			}
			
			//Check for [35m (terminal bold text)
			[mutableDatum replaceOccurrencesOfString:@"[35m" 
										  withString:@"" 
											 options:NSCaseInsensitiveSearch 
											   range:(NSRange){0, [mutableDatum length]}];
			
			//Check for [0m (terminal normal text)
			[mutableDatum replaceOccurrencesOfString:@"[0m" 
										  withString:@"" 
											 options:NSCaseInsensitiveSearch 
											   range:(NSRange){0, [mutableDatum length]}];
			
			//Finally check for whitespace. Can't work around the duplicate string :(
			NSString *finalDatum = [mutableDatum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			
			//Determine line type (input or action)
			if ([finalDatum length] > 0) {
				if ([finalDatum rangeOfString:lastCommand].location == NSNotFound) { 
					NSLog(@"Action");
				} else {
					NSLog(@"Input");
				}
			}
			
			if ([finalDatum length] > 0) {
				[[[debugCommandOutput textStorage] mutableString] appendString:finalDatum];
				[[[debugCommandOutput textStorage] mutableString] appendString:@"\r\n"];
				[debugCommandOutput scrollRangeToVisible: NSMakeRange ([[debugCommandOutput string] length], 0)];
			}
        }
	} else {
		stdi = nil;
		NSLog(@"Server stopped.");
	}
	
}

- (IBAction)handleCommandInput:(id)sender {
    [self handleCommandInputWithInput:[sender stringValue]];
	[commandHist addObject:[sender stringValue]];
	[sender setStringValue:@""];
}

- (void)handleCommandInputWithInput:(NSString *)data {
    NSLog(@"Sending '%@'", data);
	
	[lastCommand release];
	lastCommand = data;
	
    [stdi writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    [stdi writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
