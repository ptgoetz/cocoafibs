/*
CocoaFIBS - A Mac OS X CLient for the FIBS Backgammon Server
Copyright (C) 2005  Adam Gerson

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/


#import "AGFIBSTerminalWindowController.h"


@implementation AGFIBSTerminalWindowController
- (id)init
{
   //localPool = [[NSAutoreleasePool alloc] init];
	self = [super initWithWindowNibName:@"TerminalWindow"];
	isDragging = NO;
	commandHistory = [[NSMutableArray alloc] initWithCapacity:1];
	historyPoint = 0;
    return self;
}

- (void)windowDidLoad
/*" Nib file is loaded "*/
{
	[[self window] setFrameAutosaveName:@"TerminalWindow"];	
}

- (IBAction)addToSavedCommands:(id)sender
{
	if (![[terminalInputTextField stringValue] isEqualToString:@""]) {
		[savedTerminalCommandsPopUpButton addItemWithTitle:[terminalInputTextField stringValue]];
		NSMutableArray *terminalWindowSavedCommands = [NSMutableArray arrayWithCapacity:1];
		[terminalWindowSavedCommands addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"terminalWindowSavedCommands"]];
		[terminalWindowSavedCommands addObject:[terminalInputTextField stringValue]];
		[[NSUserDefaults standardUserDefaults] setObject:terminalWindowSavedCommands forKey:@"terminalWindowSavedCommands"];
		[terminalInputTextField setStringValue:@""];
	}
}

- (IBAction)removeFromSavedCommands:(id)sender
{
	//if (![[terminalInputTextField stringValue] isEqualToString:@""]) {
		//[savedTerminalCommandsPopUpButton removeItemWithTitle:[savedTerminalCommandsPopUpButton titleOfSelectedItem]];
		
		NSMutableArray *terminalWindowSavedCommands = [NSMutableArray arrayWithCapacity:1];
		[terminalWindowSavedCommands addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"terminalWindowSavedCommands"]];
		[terminalWindowSavedCommands removeObject:[savedTerminalCommandsPopUpButton titleOfSelectedItem]];
		[[NSUserDefaults standardUserDefaults] setObject:terminalWindowSavedCommands forKey:@"terminalWindowSavedCommands"];
	//}
}

- (void)displayInTerminal:(NSMutableString *)aMessage
/*" Displays all console commands returned by the server "*/
{

//localPool = [[NSAutoreleasePool alloc] init];
	//[[terminalDisplayTextView textStorage] setFont:[NSFont fontWithName:@"Monaco" size:10]];
	//[[terminalDisplayTextView textStorage] setForegroundColor:[NSColor redColor]];
	NSMutableString *consoleString = [NSMutableString string];
	[consoleString appendFormat:@"%@ \n", aMessage];

   NSRange r = NSMakeRange([[terminalDisplayTextView string] length], 0);
   [terminalDisplayTextView replaceCharactersInRange:r withString:[consoleString substringFromIndex:0]];
	if (NSMaxY([terminalDisplayTextView bounds]) == NSMaxY([terminalDisplayTextView visibleRect])) {
		[terminalDisplayTextView scrollRangeToVisible:NSMakeRange([[terminalDisplayTextView string] length], [[terminalDisplayTextView string] length])];
	}
	
	
	
	//[[terminalDisplayScrollView contentView] scrollToPoint: NSMakePoint(0,([[terminalDisplayScrollView contentView] documentRect].size.height)-10)];
   // [terminalDisplayScrollView reflectScrolledClipView: [terminalDisplayScrollView contentView]];
	//[terminalDisplayTextView setNeedsDisplay:YES];

}

- (IBAction)sendCommandToTerminal:(id)sender
{
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	NSMutableString *stringToSend = nil;
	if ([sender tag] == 0) {
		[[stringToSend initWithCapacity:[[sender stringValue] length]] setString:[sender stringValue]] ;
//		stringToSend = [[NSMutableString initWithCapacity:[[sender stringValue] length] setString:[sender stringValue]] ;
		[sender setStringValue:@""];
	}
	else if ([sender tag] == 1) {
		[[stringToSend initWithCapacity:[[sender titleOfSelectedItem] length]] setString:[sender titleOfSelectedItem]] ;
		
	}
	[commandHistory addObject:stringToSend];
	historyPoint = [commandHistory count];
	[nc postNotificationName:@"AGFIBSSendCommandToSocket" object:stringToSend];
	
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
	if ((command == @selector(moveDown:))) {
		if (historyPoint < [commandHistory count]-1) {
			historyPoint++;
			[control setStringValue:[commandHistory objectAtIndex:historyPoint]];
		}
		else if (historyPoint == [commandHistory count]-1) {
			historyPoint++;
			[control setStringValue:@""];
		}
		
		return YES;
	}
	if ((command == @selector(moveUp:))) {
		if (historyPoint > 0) {
			historyPoint--;
		}
		[control setStringValue:[commandHistory objectAtIndex:historyPoint]];
		return YES;
	}
	return NO;
}


- (BOOL)isDragging {
    return isDragging;
}

- (void)setIsDragging:(BOOL)newIsDragging {
    if (isDragging != newIsDragging) {
        isDragging = newIsDragging;
    }
}


@end
