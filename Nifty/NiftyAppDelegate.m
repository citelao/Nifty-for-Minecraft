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
@synthesize commandOutput;
@synthesize commandOutputController;

- (id)init {
    self = [super init];
    
    [[NSApplication sharedApplication] setDelegate:self];
	
	commandHist = [[NSMutableArray alloc] init];
	
	//debug
    serverType = @"bukkit.jar";
	serverLoc = @"Nifty.app/Contents/Resources/";
	
    if (!self) {
		return false;
	}
	
	// usr/bin/java -Xms1024M -Xmx1024M -jar bukkit.jar nogui
	server = [[NSTask alloc] init];
	NSPipe *stdiPipe = [[NSPipe alloc] init];
	NSPipe *stdoPipe = [[NSPipe alloc] init];
	stdi = [stdiPipe fileHandleForWriting];
	stdo = [stdoPipe fileHandleForReading];
	
	NSArray *args = [NSArray arrayWithObjects: @"-Xms1024M",
					 @"-Xmx1024M",
					 @"-jar",
					 serverType,
					 @"nogui",
					 nil];

	[server setLaunchPath:@"/usr/bin/java"];
	[server setCurrentDirectoryPath:serverLoc];
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
    
    return self;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	if (!stdi) {
		return;
	}
	
	[self handleCommandInputWithInput:@"stop"];
}

- (void)handleCommandOutput:(NSNotification *)aNotification {
	if ([server isRunning] == NO) {
		stdi = nil;
		NSLog(@"Server stopped.");
		return;
	}
	
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
		
		//Forgive the multiple checks of mutableDatum length;
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
		
		//Check for empty string, again.
		if ([finalDatum length] == 0) {
			return;
		}
		
		//Determine line type (input or action)
		NSString *actor;
		NSString *command;
		NSString *type;
		NSString *time;
		
		[[[debugCommandOutput textStorage] mutableString] appendString:finalDatum];
		[[[debugCommandOutput textStorage] mutableString] appendString:@"\r\n"];
		[debugCommandOutput scrollRangeToVisible: NSMakeRange ([[debugCommandOutput string] length], 0)];
		
		//Determine whether this is an action (TRUE) or input (FALSE)
		if ([commandHist lastObject] == NULL || [finalDatum rangeOfString:[commandHist lastObject]].location == NSNotFound) { 
			NSArray *capturesArray;
			capturesArray = [finalDatum arrayOfCaptureComponentsMatchedByRegex:@"^((?:[0-9]{2}:){2}[0-9]{2})(?: |\\x1b)*(\\[[A-Z]+])(?: |\\x1b)*(\\[[A-Za-z]+])?(?: |\\x1b)*([^\\[\\r\\n]+)"];
			if( [capturesArray count] == 0 || capturesArray == nil ) {
				return;
			}
			
			NSLog(@"%@", [capturesArray objectAtIndex:0]);
			NSLog(@"%@", finalDatum);
			
			actor = [[NSString alloc] initWithString:[[capturesArray objectAtIndex:0] objectAtIndex:3]];
			command = [[NSString alloc] initWithString:[[capturesArray objectAtIndex:0] objectAtIndex:4]];
			type = [[NSString alloc] initWithString:[[capturesArray objectAtIndex:0] objectAtIndex:2]];
			time = [[NSString alloc] initWithString:[[capturesArray objectAtIndex:0] objectAtIndex:1]];
		} else {
			actor = [[NSString alloc] initWithString:@""];
			command = [[NSString alloc] initWithString:finalDatum];
			type = [[NSString alloc] initWithString:@""];
			time = [[NSString alloc] initWithString:@""];       
		}
		
		//Create row
		if( !actor || !command || !type || !time ) {
			return;
		}
		
		NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
		[row setObject:actor forKey:@"actor"];
		[row setObject:command forKey:@"command"];
		[row setObject:type forKey:@"type"];
		[row setObject:time forKey:@"time"];
		
		//Push row to table
		[commandOutputController addObject:row];
		[commandOutput reloadData];
		[commandOutput scrollRowToVisible:[commandOutput numberOfRows] - 1];
		
		//Cleanup!
		[actor release];
		[command release];
		[type release];
		[time release];
		[row release];
	} //end for
}

- (IBAction)handleCommandInput:(id)sender {
    [self handleCommandInputWithInput:[sender stringValue]];
	[commandHist addObject:[sender stringValue]];
	[sender setStringValue:@""];
}


- (void)handleCommandInputWithInput:(NSString *)data {
    NSLog(@"Sending '%@'", data);
		
	[commandHist addObject:data];
	
    [stdi writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    [stdi writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
