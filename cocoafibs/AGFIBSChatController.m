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
//


#import "AGFIBSChatController.h"
#import "URLTextView.h"
#import "URLMutableAttributedString.h"
#include "AGFIBSAppController.h"
#include "AGFIBSSocketStream.h"

@implementation AGFIBSChatController
/*"
An instance of this controller class acts as the bridge between the socket and the chat NSTabView in the game window. The methods of this class handle handle the actions of the user for sending in-game, public, and console chat and messages to the server. When a chat or console message is received by the server the methods of this class handle the formatting and display of the chat text.
"*/

- (IBAction)gameChatSendButton:(id)sender
/*" Send the contents of the TextField to the server for in-game chat. Appends chat text to the the type of chat as selected from the gameChatTypeOfChatPopUpButton. "*/
{
	NSMutableString *gameChatString = [NSMutableString string];
	if ([[gameChatTypeOfChatPopUpButton titleOfSelectedItem] isEqualToString:@"Tell"]) {
		[gameChatString appendFormat:@"%@ %@ %@\n", [gameChatTypeOfChatPopUpButton titleOfSelectedItem], [privateChatSendTellToWhomTextField stringValue], [gameChatTextToSendTextField stringValue]];
	}
	else {
		[gameChatString appendFormat:@"%@ %@\n", [gameChatTypeOfChatPopUpButton titleOfSelectedItem], [gameChatTextToSendTextField stringValue]];
	}
	
	[[theAppController theAGFIBSSocket] sendMessage:gameChatString];
	[gameChatTextToSendTextField setStringValue:@""];
}

- (IBAction)publicChatSendButton:(id)sender
/*" Send the contents of the TextField to the server for public chat "*/
{
	NSMutableString *shoutString = [NSMutableString string];
	[shoutString appendFormat:@"shout %@\n", [publicChatTextToSendTextField stringValue]];
	[[theAppController theAGFIBSSocket] sendMessage:shoutString];
	[publicChatTextToSendTextField setStringValue:@""];
}



- (IBAction)changeTypeOfChat:(id)sender
/*"  "*/
{
	
	if ([[gameChatTypeOfChatPopUpButton titleOfSelectedItem] isEqualToString:@"Tell"] && [privateChatSendTellToWhomTextField isHidden]) {
		[privateChatSendTellToWhomTextField setHidden:NO];
		[gameChatTextToSendTextField setFrameSize:NSMakeSize(([gameChatTextToSendTextField frame].size.width-126),22)];
		[gameChatTextToSendTextField setFrameOrigin:NSMakePoint(254,20)];
	}
	else if (!([[gameChatTypeOfChatPopUpButton titleOfSelectedItem] isEqualToString:@"Tell"]) && ![privateChatSendTellToWhomTextField isHidden]) {
		[privateChatSendTellToWhomTextField setHidden:YES];
		[gameChatTextToSendTextField setFrameSize:NSMakeSize(([gameChatTextToSendTextField frame].size.width+126),22)];
		[gameChatTextToSendTextField setFrameOrigin:NSMakePoint(128,20)];
	}
	[publicChatBox setNeedsDisplay:YES];

}


- (void)clipKibitzes:(NSString *)aMessage
/*" Parse and display a Kibitze chat in the game-chat TextView. Scroll the TextView to the bottom"*/
{
	
	NSArray *tokkenizer = [aMessage componentsSeparatedByString:@" "];
	NSString *userName = [tokkenizer objectAtIndex:1];
	NSMutableString *whatUserSaid = [NSMutableString string];
	
	int i;
	for (i = 2; i < [tokkenizer count]-1; i++) {
		[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
		[whatUserSaid appendString:@" "];
	}
	
	[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
	
	NSMutableAttributedString *shoutString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@] %@ \n",userName,whatUserSaid]];
				
	[shoutString	addAttribute:NSForegroundColorAttributeName
					value:[NSColor redColor]
					range:NSMakeRange(0,[userName length]+2)];
	
	[shoutString	addAttribute:NSFontAttributeName
					value:[NSFont boldSystemFontOfSize:12]
					range:NSMakeRange(0,[userName length]+2)];
	
	[shoutString detectURLs:[NSColor blueColor]];
	[[gameChatMainTextView textStorage] appendAttributedString:shoutString];

	
	[gameChatMainTextView scrollRangeToVisible:NSMakeRange([[gameChatMainTextView string] length], [[gameChatMainTextView string] length])];
}

- (void)clipYouKibitz:(NSString *)aMessage
/*" Parse and display a Kibitze chat from the player in the game-chat TextView. Scroll the TextView to the bottom"*/
{
	NSArray *tokkenizer = [aMessage componentsSeparatedByString:@" "];
	NSString *userName = @"You";
	NSMutableString *whatUserSaid = [NSMutableString string];
	
	int i;
	for (i = 1; i < [tokkenizer count]-1; i++) {
		[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
		[whatUserSaid appendString:@" "];
	}
	
	[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
	
	NSMutableAttributedString *shoutString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@] %@ \n",userName,whatUserSaid]];
				
	[shoutString	addAttribute:NSForegroundColorAttributeName
				value:[NSColor blueColor]
				range:NSMakeRange(0,[userName length]+2)];
	
	[shoutString	addAttribute:NSFontAttributeName
				value:[NSFont boldSystemFontOfSize:12]
				range:NSMakeRange(0,[userName length]+2)];
	
	[shoutString detectURLs:[NSColor blueColor]];
	[[gameChatMainTextView textStorage] appendAttributedString:shoutString];
	
	[gameChatMainTextView scrollRangeToVisible:NSMakeRange([[gameChatMainTextView string] length], [[gameChatMainTextView string] length])];
}

- (void)clipSay:(NSString *)aMessage
/*" Parse and display a "say" chat in the game-chat TextView. Scroll the TextView to the bottom"*/
{
	
	NSArray *tokkenizer = [aMessage componentsSeparatedByString:@" "];
	NSString *userName = [tokkenizer objectAtIndex:1];
	NSMutableString *whatUserSaid = [NSMutableString string];
	
	int i;
	for (i = 2; i < [tokkenizer count]-1; i++) {
		[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
		[whatUserSaid appendString:@" "];
	}
	
	[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
	
	NSMutableAttributedString *shoutString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@ says] %@ \n",userName,whatUserSaid]];
				
	[shoutString	addAttribute:NSForegroundColorAttributeName
				value:[NSColor redColor]
				range:NSMakeRange(0,[userName length]+7)];
	
	[shoutString	addAttribute:NSFontAttributeName
				value:[NSFont boldSystemFontOfSize:12]
				range:NSMakeRange(0,[userName length]+7)];
	
	[shoutString detectURLs:[NSColor blueColor]];
	[[gameChatMainTextView textStorage] appendAttributedString:shoutString];
	
	[gameChatMainTextView scrollRangeToVisible:NSMakeRange([[gameChatMainTextView string] length], [[gameChatMainTextView string] length])];

	

	
	NSString *tellUsernameString = [NSString stringWithFormat:@"tell %@",userName];
	[privateChatSendTellToWhomTextField setStringValue:userName];
	
	
	NSMenuItem *tempItem = [[[theAppController userListWindow] gameChatTypeOfChatPopUpButton] itemWithTitle:tellUsernameString];
	
	if (tempItem == nil) {
		[[[theAppController userListWindow] gameChatTypeOfChatPopUpButton] addItemWithTitle:tellUsernameString];
		[[[theAppController userListWindow] gameChatTypeOfChatPopUpButton] selectItemAtIndex:([[[theAppController userListWindow] gameChatTypeOfChatPopUpButton] numberOfItems]-1)];
	}
	[self changeTypeOfChat:nil];
	
}

- (NSTextField *)privateChatSendTellToWhomTextField {
    return [[privateChatSendTellToWhomTextField retain] autorelease];
}



- (NSTextField *)gameChatTextToSendTextField {
    return [[gameChatTextToSendTextField retain] autorelease];
}

- (void)clipYouSay:(NSString *)aMessage
/*" Parse and display a "say" chat from the player in the game-chat TextView. Scroll the TextView to the bottom"*/
{
	NSArray *tokkenizer = [aMessage componentsSeparatedByString:@" "];
	NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *saidTo = [tokkenizer objectAtIndex:1];
	NSMutableString *whatUserSaid = [NSMutableString string];
	
	int i;
	for (i = 2; i < [tokkenizer count]-1; i++) {
		[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
		[whatUserSaid appendString:@" "];
	}
	
	[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
	
	NSMutableAttributedString *shoutString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@-%@] %@ \n",userName,saidTo,whatUserSaid]];
				
	[shoutString	addAttribute:NSForegroundColorAttributeName
				value:[NSColor blueColor]
				range:NSMakeRange(0,[userName length]+[saidTo length]+3)];
	
	[shoutString	addAttribute:NSFontAttributeName
				value:[NSFont boldSystemFontOfSize:12]
				range:NSMakeRange(0,[userName length]+2)];
	
	[shoutString detectURLs:[NSColor blueColor]];
	[[gameChatMainTextView textStorage] appendAttributedString:shoutString];
	
	[gameChatMainTextView scrollRangeToVisible:NSMakeRange([[gameChatMainTextView string] length], [[gameChatMainTextView string] length])];
}

- (void)clipShouts:(NSString *)aMessage
/*" Parse and display a "shout" chat in the public chat TextView. Scroll the TextView to the bottom"*/
{
	
	NSArray *tokkenizer = [aMessage componentsSeparatedByString:@" "];
	NSString *userName = [tokkenizer objectAtIndex:1];
	NSMutableString *whatUserSaid = [NSMutableString string];
	
	int i;
	for (i = 2; i < [tokkenizer count]-1; i++) {
		[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
		[whatUserSaid appendString:@" "];
	}
	
	[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
	
	NSMutableAttributedString *shoutString = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@] %@ \n",userName,whatUserSaid]] autorelease];
				
	[shoutString	addAttribute:NSForegroundColorAttributeName
				value:[NSColor redColor]
				range:NSMakeRange(0,[userName length]+2)];
	
	[shoutString	addAttribute:NSFontAttributeName
				value:[NSFont boldSystemFontOfSize:12]
				range:NSMakeRange(0,[userName length]+2)];
	
	[shoutString detectURLs:[NSColor blueColor]];
	[[publicChatMainTextView textStorage] appendAttributedString:shoutString];

	if (NSMaxY([publicChatMainTextView bounds]) == NSMaxY([publicChatMainTextView visibleRect])) {
		[publicChatMainTextView scrollRangeToVisible:NSMakeRange([[publicChatMainTextView string] length], [[publicChatMainTextView string] length])];
	}
}

- (void)clipYouShout:(NSString *)aMessage
/*" Parse and display a "shout" chat in the public chat TextView. Scroll the TextView to the bottom"*/
{
	NSArray *tokkenizer = [aMessage componentsSeparatedByString:@" "];
	NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSMutableString *whatUserSaid = [NSMutableString string];
	
	int i;
	for (i = 1; i < [tokkenizer count]-1; i++) {
		[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
		[whatUserSaid appendString:@" "];
	}
	
	[whatUserSaid appendString:[tokkenizer objectAtIndex:i]];
	
	NSMutableAttributedString *shoutString = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@] %@ \n",userName,whatUserSaid]]autorelease];
				
	[shoutString	addAttribute:NSForegroundColorAttributeName
				value:[NSColor blueColor]
				range:NSMakeRange(0,[userName length]+2)];
	
	[shoutString	addAttribute:NSFontAttributeName
				value:[NSFont boldSystemFontOfSize:12]
				range:NSMakeRange(0,[userName length]+2)];
	
	[shoutString detectURLs:[NSColor blueColor]];
	[[publicChatMainTextView textStorage] appendAttributedString:shoutString];
	
	
	if (NSMaxY([publicChatMainTextView bounds]) == NSMaxY([publicChatMainTextView visibleRect])) {
		[publicChatMainTextView scrollRangeToVisible:NSMakeRange([[publicChatMainTextView string] length], [[publicChatMainTextView string] length])];
	}
}


- (void)reset
/*" "*/
{
	[gameChatTextToSendTextField setStringValue:@""];
	[publicChatTextToSendTextField setStringValue:@""];	
	[[gameChatMainTextView textStorage] deleteCharactersInRange:NSMakeRange(0, [[gameChatMainTextView string] length])];
	[[publicChatMainTextView textStorage] deleteCharactersInRange:NSMakeRange(0, [[publicChatMainTextView string] length])];
}

- (NSWindow *)publicChatWindow {
    return [[publicChatWindow retain] autorelease];
}

- (AGFIBSAppController *)theAppController 
/*" Returns the AGFIBSAppController "*/
{
    return [[theAppController retain] autorelease];
}

- (void)setTheAppController:(AGFIBSAppController *)newTheAppController 
/*" Sets the AGFIBSAppController "*/
{
    if (theAppController != newTheAppController) {
        [theAppController release];
        theAppController = [newTheAppController retain];
    }
}

- (NSPopUpButton *)gameChatTypeOfChatPopUpButton {
    return [[gameChatTypeOfChatPopUpButton retain] autorelease];
}

- (void)setGameChatTypeOfChatPopUpButton:(NSPopUpButton *)newGameChatTypeOfChatPopUpButton {
    if (gameChatTypeOfChatPopUpButton != newGameChatTypeOfChatPopUpButton) {
        [gameChatTypeOfChatPopUpButton release];
        gameChatTypeOfChatPopUpButton = [newGameChatTypeOfChatPopUpButton retain];
    }
}


- (void)windowDidLoad
/*" Nib file is loaded "*/
{
	[[self publicChatWindow] setFrameAutosaveName:@"publicChatWindow"];	
}



@end
