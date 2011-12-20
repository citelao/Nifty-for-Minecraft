//
//  NiftyTextViewDelegate.m
//  Nifty
//
//  Created by Ben Stolovitz on 12/16/11.
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

#import "NiftyTextViewDelegate.h"

@implementation NiftyTextViewDelegate

- (id)init {
    self = [super init];
    if (!self)
		return false;
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(complete:) 
												 name:NSTextDidChangeNotification 
											   object:delegatedField];
	
    return self;
}

- (NSArray *)textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
	return [NSArray arrayWithObjects:@"one", @"two", @"three", nil];
}

- (void)complete:(NSNotification *)aNotification {
	NSLog(@"%@", aNotification);
//	[delegatedField complete:nil];
}

@end