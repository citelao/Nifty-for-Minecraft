//
//  NiftyAppDelegate.m
//  Nifty
//
//  Created by Ben Stolovitz on 11/27/11.
//  Copyright 2011 Ben Stolovitz.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//	this software and associated documentation files (the "Software"), to deal in
//	the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to do
//	so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

#import "NiftyAppDelegate.h"
#import "RegexKitLite.h"

@implementation NiftyAppDelegate

@synthesize window;
@synthesize commandOutput;
@synthesize commandOutputController;

- (id)init {
    self = [super init];
    [[NSApplication sharedApplication] setDelegate:self];
	
	if (!self)
		return false;
	
	commandHist = [[NSMutableArray alloc] init];
	
	// Dev convinience: these will be modified in preferences later.
    serverType = @"bukkit.jar";
	serverLoc = @"Nifty.app/Contents/Resources/";
	
	// usr/bin/java -Xms1024M -Xmx1024M -jar bukkit.jar nogui
	server = [[NSTask alloc] init];
	[server setLaunchPath:@"/usr/bin/java"];
	[server setCurrentDirectoryPath:serverLoc];
	
	NSArray *args = [NSArray arrayWithObjects: 
					 @"-Xms1024M",
					 @"-Xmx1024M",
					 @"-jar",
					 serverType,
					 @"nogui",
					 nil];
	[server setArguments:args];
	[args release];
	
	NSPipe *stdiPipe = [[NSPipe alloc] init];
	NSPipe *stdoPipe = [[NSPipe alloc] init];
	stdi = [stdiPipe fileHandleForWriting];
	stdo = [stdoPipe fileHandleForReading];
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
	if (!stdi)
		return;
	
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
	NSString *unparsedData = [[NSString alloc] initWithData:[handleNotif availableData] encoding:NSUTF8StringEncoding];
	[handleNotif waitForDataInBackgroundAndNotify];
	
	//Split by line
	NSArray *dataLines = [unparsedData componentsSeparatedByString: @"\n"];
	[unparsedData release];
	
	//TODO should I release handleNotif?
	
	for (id object in dataLines) {
		NSString *finalDatum = [self stripRawOutput:object];
		
		if( finalDatum == nil || [finalDatum length] == 0)
			return;
		
		NSString *actor;
		NSString *command;
		NSString *type;
		NSString *time;
		NSColor *color;
		NSNumber *bold;
		
		NSLog(@"%@", [commandHist lastObject]);
		
		//Determine whether this is an action (TRUE) or input (FALSE)
		if ([commandHist lastObject] == NULL || ![finalDatum isEqualToString: [commandHist lastObject]]) {
			NSArray *capturesArray = [self stripByRegex:finalDatum];
			
			if( [capturesArray count] == 0 || capturesArray == nil )
				return;
			
			NSArray *outputArray = [capturesArray objectAtIndex:0];
			
			actor =		[[NSString alloc] initWithString:[outputArray objectAtIndex:4]];
			command =	[[NSString alloc] initWithString:[outputArray objectAtIndex:5]];
			type =		[[NSString alloc] initWithString:[outputArray objectAtIndex:3]];
			time =		[[NSString alloc] initWithString:[outputArray objectAtIndex:2]];
			bold =		[NSNumber numberWithBool: NO];
			
			//Choose a row color:
			if( [type isEqualToString:@"INFO"] ) {
				color = [NSColor colorWithDeviceHue:1.0 
										 saturation:1.0 
										 brightness:0 
											  alpha:1.0]; //black
			} else {
				color = [NSColor colorWithDeviceHue:1.0 
										 saturation:1.0 
										 brightness:1.0 
											  alpha:1.0]; //red
			}
		} else {
			actor =		[[NSString alloc] initWithString:@""];
			command =	[[NSString alloc] initWithString:finalDatum];
			type =		[[NSString alloc] initWithString:@""];
			time =		[[NSString alloc] initWithString:@""];
			bold =		[NSNumber numberWithBool: TRUE];
			color =		[NSColor colorWithDeviceHue:1.0 
										 saturation:1.0 
										 brightness:0 
											  alpha:1.0]; //black
		}
		
		/*
		 
		//Debug
		[[[debugCommandOutput textStorage] mutableString] appendString:finalDatum];
		[[[debugCommandOutput textStorage] mutableString] appendString:@"\r\n"];
		[debugCommandOutput scrollRangeToVisible: NSMakeRange ([[debugCommandOutput string] length], 0)];
		 
		 */

		//Create row
		if( !actor || !command || !type || !time || !color || !bold )
			return;
		
		NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
		[row setObject:actor forKey:@"actor"];
		[row setObject:command forKey:@"command"];
		[row setObject:type forKey:@"type"];
		[row setObject:time forKey:@"time"];
		[row setObject:color forKey:@"color"];
		[row setObject:bold forKey:@"bold"];
		
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

- (NSString *)stripRawOutput:(NSString *)rawDatum {
	NSMutableString *mutableDatum = [NSMutableString stringWithString:rawDatum];
	
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
	
	return finalDatum;
}

- (NSArray *)stripByRegex:(NSString *)finalDatum {
	/****
	 * This is the craziest regex ever:
	 * ^(([0-9]{2}:[0-9]{2}):[0-9]{2})(?: |\x1b)*((?:\[)[A-Z]+(?:]))(?: |\x1b)*(?:(?:\[|<|(?=[A-Za-z0-9_]+:))([A-Za-z0-9_]+)(?:]|>|:))?(?: |\x1b)*([^\r\n]+)
	 * So I'll walk through it:
	 ****
	 
	 ^(([0-9]{2}:[0-9]{2}):[0-9]{2})
	 Time string, recognizes 88:88:88 *and* 88:88
	 `^` matches the beginning of the string, so it doesn't get confused by `88:88:88 [INFO] <acolite246> I keep getting this weird error: 88:88:88 [WARNING] Ohnoes`
	 
	 (?: |\x1b)*
	 This is my space string; Bukkit likes throwing in ESC chars, aka `^[` or, in regex, `\x1b`
	 `(?:` make sure not to capture these as groups
	 
	 ((?:\[)[A-Z]+(?:]))
	 Matches cmd type [INFO] or [WARNING] or [NOHOPELEFT]
	 Removes brackets
	 
	 (?: |\x1b)*
	 Space string
	 
	 (?:(?:\\[|<|(?=[A-Za-z0-9_]+:))([A-Za-z0-9_]+)(?:]|>|:))?
	 This matches (if it exists) the speaker, in the format
	 [Speaker]
	 Speaker:
	 <speaker>
	 and trims the extra.
	 
	 `(?:\\[|<|(?=[A-Za-z0-9_]+:))` matches `[`, `<` or a word followed by a `:`; it does not capture the group
	 `([A-Za-z0-9_]+)` valid name chars
	 `(?:]|>|:))` matches `]`, `>`, or `:`; does not capture the group.
	 
	 (?: |\x1b)*
	 Space string
	 
	 ([^\r\n]+)
	 Match every other character except line breaks.
	 
	 
	 ****
	 * This regex took a *long* time. I'm proud of it.
	 * This regex is effectively 99% of this program, so be good to it
	 *
	 * I hope new versions of Bukkit don't break it :)
	 ****/
	
	NSArray *capturesArray = [finalDatum arrayOfCaptureComponentsMatchedByRegex:@"^(([0-9]{2}:[0-9]{2}):[0-9]{2})(?: |\\x1b)*(?:(?:\\[)([A-Z]+)(?:]))(?: |\\x1b)*(?:(?:\\[|<|(?=[A-Za-z0-9_]+:))([A-Za-z0-9_]+)(?:]|>|:))?(?: |\\x1b)*([^\\r\\n]+)"];
	
	return capturesArray;
}

- (IBAction)handleCommandInput:(id)sender {
	if( [sender stringValue] == nil || [[sender stringValue] length] == 0 )
		return;
	
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