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


#import "AGFIBSToolbarController.h"
#import "AGFIBSAppController.h"
#include "AGFIBSLoginWindowController.h"
#include "AGFIBSSocketStream.h"
#include "AGFIBSGameController.h"

@implementation AGFIBSToolbarController
/*" 
An instance of this controller class acts as the controller for the iconic toolbar at the top of the game window. Its methods create and populate the toolbar, handle actions from the toolbar buttons, handle customizing of the toolbar, and respond to NSApplication delegate methods and notifications.

DELEGATE OF:
NSApplications

OBSERVED NOTIFICATIONS:
applicationDidFinishLaunching
applicationWillTerminate
applicationDidBecomeActive
applicationDidResignActive

"*/
- (BOOL)toolbarIsVisible
{
	return [toolbar isVisible];
}

- (void)awakeFromNib 
/*"Responding to being loaded from a nib file. This method creates and populates the toolbar and its items "*/
{

	//[[theAppController theLoginWindowController] setUsernameAndPasswordFields];
		
    items=[[NSMutableDictionary alloc] init];
	
	//**************Toggle Ready**************
	NSToolbarItem *item=[[NSToolbarItem alloc] initWithItemIdentifier:@"toggleStatus"];
	[item setPaletteLabel:@"Change Status"]; // name for the "Customize Toolbar" sheet
	if ([theAppController readyToPlayStatus]) {
		[item setLabel:@"Ready"];
		[item setImage:[NSImage imageNamed:@"toolbarStatusReady"]];
		[theAppController setReadyToPlayStatus:YES];
	}
	else if (![theAppController readyToPlayStatus]) {
		[item setLabel:@"Not Ready"];
		[theAppController setReadyToPlayStatus:NO];
		[item setImage:[NSImage imageNamed:@"toolbarStatusNotReady"]];
	}
	[item setToolTip:[NSString stringWithFormat:@"Change your ready to play status"]]; // tooltip
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(sendToggleReady)];
	[items setObject:item forKey:@"toggleStatus"]; // add to toolbar list
	[item release];
	
	//**************Toggle Drawer**************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"Players"];
	[item setPaletteLabel:@"Players"];
	[item setLabel:@"Players"];
	[item setImage:[NSImage imageNamed:@"toggleDrawer"]];
	[item setToolTip:[NSString stringWithFormat:@"Show or hide the list of players"]];
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(toggleUserListDrawer)];
	[items setObject:item forKey:@"Players"];
	[item release];
	//****************************
	
	//**************Toggle Double**************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"Double"];
	[item setPaletteLabel:@"Toggle Double"];
	[item setLabel:@"Toggle Double"];
	[item setImage:[NSImage imageNamed:@"toolbarDouble"]];
	[item setToolTip:[NSString stringWithFormat:@"Do you want to be asked to double?"]];
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(sendToggleDouble)];
	[items setObject:item forKey:@"Double"];
	[item release];
	//****************************
	
	//**************Toggle greedy**************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"Greedy"];
	[item setPaletteLabel:@"Toggle Greedy"];
	[item setLabel:@"Toggle Greedy"];
	[item setImage:[NSImage imageNamed:@"toolbarAutoOff"]];
	[item setToolTip:[NSString stringWithFormat:@"Use greedy bareoffs"]];
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(sendToggleGreedy)];
	[items setObject:item forKey:@"Greedy"];
	[item release];
	//****************************
	
	//**************Resign**************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"Resign"];
	[item setPaletteLabel:@"Resign"];
	[item setLabel:@"Resign"];
	[item setImage:[NSImage imageNamed:@"toolbarResign"]];
	[item setToolTip:[NSString stringWithFormat:@"Resign Game"]];
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(resign)];
	[items setObject:item forKey:@"Resign"];
	[item release];
	//****************************
	
	//************** Refresh **************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"Refresh"];
	[item setPaletteLabel:@"Refresh"];
	[item setLabel:@"Refresh"];
	[item setImage:[NSImage imageNamed:@"toolbarRefresh"]];
	[item setToolTip:[NSString stringWithFormat:@"Refresh"]];
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(refreshBoard)];
	[items setObject:item forKey:@"Refresh"];
	[item release];
	//****************************
	
	//************** Terminal **************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"Terminal"];
	[item setPaletteLabel:@"Show Terminal"];
	[item setLabel:@"Terminal"];
	[item setImage:[NSImage imageNamed:@"terminal"]];
	[item setToolTip:[NSString stringWithFormat:@"Show Terminal"]];
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(showTerminalWindow)];
	[items setObject:item forKey:@"Terminal"];
	[item release];
	//****************************
	
	//************** bug **************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"Bug"];
	[item setPaletteLabel:@"Bug"];
	[item setLabel:@"Report Bug"];
	[item setImage:[NSImage imageNamed:@"terminal"]];
	[item setToolTip:[NSString stringWithFormat:@"Bug"]];
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(markBug)];
	[items setObject:item forKey:@"Bug"];
	[item release];
	//****************************
	
	//************** public chat **************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"publicChat"];
	[item setPaletteLabel:@"Public Chat"];
	[item setLabel:@"Public Chat"];
	[item setImage:[NSImage imageNamed:@"toolbarPublicChat"]];
	[item setToolTip:[NSString stringWithFormat:@"Show Public Chat"]];
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(showPublicChatWindow)];
	[items setObject:item forKey:@"publicChat"];
	[item release];
	//****************************
	
	//************** undo move **************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"undoMove"];
	[item setPaletteLabel:@"Undo Move"];
	[item setLabel:@"Undo Move"];
	[item setImage:[NSImage imageNamed:@"toolbarUndo"]];
	[item setToolTip:[NSString stringWithFormat:@"Undo Move"]];
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(undoMove)];
	[items setObject:item forKey:@"undoMove"];
	[item release];
	//****************************
	
	//************** auto move **************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"autoMove"];
	[item setPaletteLabel:@"Auto Move"];
	[item setLabel:@"Auto Move"];
	[item setImage:[NSImage imageNamed:@"toolbarAutoMove"]];
	[item setToolTip:[NSString stringWithFormat:@"Toggle Auto Move"]];
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(autoMove)];
	[items setObject:item forKey:@"autoMove"];
	[item release];
	//****************************
	
	//************** away **************
	item=[[NSToolbarItem alloc] initWithItemIdentifier:@"away"];
	[item setPaletteLabel:@"Away Status"]; // name for the "Customize Toolbar" sheet
	if (isAway) {
		[item setLabel:@"Away"];
		[item setImage:[NSImage imageNamed:@"toolbarAway"]];
		isAway = YES;
	}
	else {
		[item setLabel:@"Not Away"];
		isAway = NO;
		[item setImage:[NSImage imageNamed:@"toolbarNotAway"]];
	}
	[item setToolTip:[NSString stringWithFormat:@"Change your away status"]]; // tooltip
	[item setTarget:self]; // what should happen when it's clicked
	[item setAction:@selector(toggleAway)];
	[items setObject:item forKey:@"away"]; // add to toolbar list
	[item release];
	//****************************



	
    toolbar=[[NSToolbar alloc] initWithIdentifier:@"AGFIBSToolBar"]; // identifier has to be unique per window type
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    
    [window setToolbar:toolbar];
    
	
    [window makeKeyAndOrderFront:nil];
	[[[theAppController theLoginWindowController] loginWindow] makeKeyAndOrderFront:nil];
}



- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag 
/*" Returns a toolbar item of the kind identified by itemIdentifier for toolbar. "*/
{
    return [items objectForKey:itemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar 
/*" Returns an array of toolbar item identifiers for toolbar, specifying the contents and the order of the items in the default toolbar configuration. "*/
{
   //return [[items allKeys] subarrayWithRange:NSMakeRange(0,6)];
   return [NSArray arrayWithObjects: @"toggleStatus", NSToolbarSeparatorItemIdentifier,@"Double",@"Greedy",@"Resign",@"Refresh",@"Terminal",@"publicChat",@"Players",nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar 
/*" Returns an array of toolbar item identifiers for toolbar, specifying the contents and the order of the items in the configuration palette. "*/
{
	NSMutableArray *temp = [NSMutableArray arrayWithCapacity:([items count]+7)];
	[temp addObjectsFromArray:[NSArray arrayWithObjects: NSToolbarCustomizeToolbarItemIdentifier,NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier, NSToolbarSeparatorItemIdentifier,nil]];
	[temp addObjectsFromArray:[items allKeys]];
return temp;
}

- (int)count 
/*" Returns the number of items in the toolbar. "*/
{
    return [items count];
}

- (IBAction)customize:(id)sender 
/*" Opens the customization palette as a sheet. "*/
{
    [toolbar runCustomizationPalette:sender];
}

- (IBAction)showhide:(id)sender 
/*" OToggles the visability of the toolbar "*/
{
    [toolbar setVisible:![toolbar isVisible]];
}

- (void)undoMove 
/*" Toggles the visability of the user list drawer "*/
{
	[[theAppController theGameController] undoMove:nil];
}

- (void)toggleUserListDrawer 
/*" Toggles the visability of the user list drawer "*/
{
	[[theAppController theGameController] toggleUserListDrawer:nil];
}

- (void)sendToggleReady 
/*" Sends a change of ready status to the server "*/
{
	[[theAppController theAGFIBSSocket] sendMessage:@"toggle ready"];
}

- (void)autoMove 
/*"  "*/
{
	[[theAppController theAGFIBSSocket] sendMessage:@"toggle automove"];
}


- (void)toggleAway 
/*" "*/
{
	NSToolbarItem *item= [items objectForKey:@"away"];
	if (isAway) {
		isAway = NO;
		[[theAppController theAGFIBSSocket] sendMessage:@"back"];
		[item setLabel:@"Not Away"];
		[item setImage:[NSImage imageNamed:@"toolbarNotAway"]];
	}
	else {
		isAway = YES;
		[[theAppController theAGFIBSSocket] sendMessage:@"away I am away"];
		[item setLabel:@"Away"];
		[item setImage:[NSImage imageNamed:@"toolbarAway"]];
	}
}

- (void)sendToggleGreedy 
/*" Sends a change of greedy status to the server "*/
{
	[[theAppController theAGFIBSSocket] sendMessage:@"toggle greedy"];
}

- (void)sendToggleDouble 
/*" Sends a change of double status to the server "*/
{
	[[theAppController theAGFIBSSocket] sendMessage:@"toggle double"];
}

- (void)showTerminalWindow 
/*"  "*/
{
	[theAppController showTerminalWindow:nil];
}

- (void)showPublicChatWindow
/*"  "*/
{
	[theAppController showPublicChatWindow];
}

- (void)refreshBoard 
/*" Gets a new board from the server. "*/
{
	[[theAppController theAGFIBSSocket] sendMessage:@"board"];
	[[theAppController theGameController] clearSystemMsg];
	[[theAppController theGameController] updateTheGameView];
}

- (void)resign 
/*" Calls resignWithHow:(NSString *)how "*/
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[[alert window] setAlphaValue:0.9];
	[alert addButtonWithTitle:@"Normal"];
	[alert addButtonWithTitle:@"Gammon"];
	[alert addButtonWithTitle:@"Backgammon"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Would you like to resign?"];
	[alert setIcon:[NSImage imageNamed:@"toolbarResign"]];
	[alert setInformativeText:@""];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(resignAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];  
}
- (void)resignGammon 
/*" Calls resignWithHow:(NSString *)how "*/
{
	[self resignWithHow:@"g"];
}
- (void)resignBackgammon 
/*" Calls resignWithHow:(NSString *)how "*/
{
	[self resignWithHow:@"b"];
}

- (void)resignWithHow:(NSString *)how
/* OF: this function has been missing, don't know yet what it should do */
{
}

- (void)resignAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
/*" Sends a resign command to the server. Takes n = normal, g = gammon, b = backgammon as a perameter. "*/
{
	NSString *howToResign = @"n";
	
	if (returnCode == NSAlertFirstButtonReturn) {
		howToResign = @"n";
	}
	else if (returnCode == NSAlertSecondButtonReturn) {
		howToResign = @"g";
	}
	else if (returnCode == NSAlertThirdButtonReturn) {
		howToResign = @"b";
	}
	else if (returnCode == NSAlertThirdButtonReturn+1) {
		return;
	}

	NSString *stringToSend = [NSString stringWithFormat:@"resign %@", howToResign];
	[[theAppController theAGFIBSSocket] sendMessage:stringToSend];
}

- (void)toggleReadyToolbarItem 
/*" Toggle the toolbar icon for ready status "*/
{
	NSToolbarItem *item= [items objectForKey:@"toggleStatus"];
	if ([theAppController readyToPlayStatus]) {
		[item setLabel:@"Ready"];
		[item setImage:[NSImage imageNamed:@"toolbarStatusReady"]];
	}
	else if (![theAppController readyToPlayStatus]) {
		[item setLabel:@"Not Ready"];
		[item setImage:[NSImage imageNamed:@"toolbarStatusNotReady"]];
	}
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
/*" Posted at the end of the NSApplication finishLaunching method to indicate that the application has completed launching and is ready to run. "*/
{
	NSDate *today = [NSDate date];
	NSLog([today description]);
	NSDate *expiresOnDate = [NSDate dateWithString:@"3018-10-01 16:08:13 -0400"]; //1000 years should do it
	NSLog([[today laterDate:expiresOnDate] description]);
	int choice;
	if ([[today laterDate:expiresOnDate] isEqual:today]) {
		choice = NSRunAlertPanel(@"Beta has expired", @"The beta copy of this software has expired", @"Quit", @"", nil);
		if (choice) {
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sourceforge.net/projects/cocoafibs/"]];
			[NSApp terminate:self];
		}
	}
	if (![self isSystemGreaterThen10_3]) {
		choice = NSRunAlertPanel(@"You are running an older version of MacOS", @"CocoaFIBS only runs on Mac OS 10.3 and above", @"Quit", @"", nil);
		if (choice)
			[NSApp terminate:self];
	}
}

-(BOOL)isSystemGreaterThen10_3
{
  long systemVersion;
  Gestalt( gestaltSystemVersion, &systemVersion );
  return (systemVersion >= 0x1030);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
/*" Posted by the NSApplication terminate: method to indicate that the application will terminate. "*/
{
	NSLog(@"applicationWillTerminate!!!!!!!!!");
	[[theAppController theAGFIBSSocket] sendMessage:@"exit1"];
	[[theAppController theAGFIBSSocket] disconnect];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
/*" Sent by the default notification center immediately after the application becomes active. "*/
{
	NSLog(@"active!!!!!!!!!");
}

- (void)applicationDidResignActive:(NSNotification *)aNotification
/*" Sent by the default notification center immediately after the application is deactivated "*/
{
	NSLog(@"resign!!!!!!!!!");
}

- (void)dealloc 
/*" Clean Up "*/
{
    [toolbar release];
    [items release];
	[super dealloc];
}
@end
