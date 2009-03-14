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

//test

#import "AGFIBSAppController.h"
#import "AGFIBSUserListWindowController.h"
#import "AGFIBSGameController.h"
#import "AGFIBSSocketStream.h"
#include "FIBSCookieMonster.h"
#import "AGFIBSToolBarController.h"
#include "AGFIBSGameView.h"
#include "AGFIBSTerminalWindowController.h"
#include "AGFIBSLoginWindowController.h"
#include "AGFIBSChatController.h"
#include "AGFIBSGameModel.h"

@implementation AGFIBSAppController
/*" 
An instance of this controller class acts as a bridge between the other controller classes. It is the class that receives commands that the socket class returns from the server. The AGFIBSAppController decides which controller class and method should handle the command.

DELEGATE OF:
NSDrawer
AGFIBSSocketStream

OBSERVED NOTIFICATIONS:
AGFIBSSendCommandToSocket
AGFIBSSConnect
AGFIBSSPlaySoundFile
AGFIBSSPrefsHaveChanged

"*/

- (id)init 
/*" Designated Initializer "*/
{
	self = [super init];
	[self setDefaultPrefs];
	theAGFIBSSocket = [[AGFIBSSocketStream alloc] init];
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(sendCommandToSocket:) name:@"AGFIBSSendCommandToSocket" object:nil];
	[nc addObserver:self selector:@selector(connect:) name:@"AGFIBSSConnect" object:nil];
	[nc addObserver:self selector:@selector(playSoundFile:) name:@"AGFIBSSPlaySoundFile" object:nil];
	[nc addObserver:self selector:@selector(prefsHaveChanged:) name:@"AGFIBSPrefsHaveChanged" object:nil];
	[nc addObserver:self selector:@selector(displaySystemMsg:) name:@"AGFIBSDisplaySystemMsg" object:nil];
	
	FIBSPreLoginCheckForErrorCount = 0;
	whileDraggingBufferGlobal = [[NSMutableArray alloc] init];
	whileDraggingBufferNeedsEmpty = NO;
	[theAGFIBSSocket setDelegate:self];
	loginDone = NO;
	notifiedOfFriendsAndGagAndBlind = NO;
	[self setReadyToPlayStatus:YES];
	[self checkForNewVersion];
	firstBoardOfNewGame = YES;
	
	

	return self;
}



- (void)dealloc
/*" Clean Up "*/
{    
	[thePrefWindow release];
	[theAGFIBSSocket release];
	[userListWindow release];
    [whileDraggingBufferGlobal dealloc];
	 [super dealloc];
    
    return;
}
- (void)setDefaultPrefs
{
    NSString *chatNewGameDefualtMsg = [NSString stringWithFormat:@"Hello <name>! Greetings from %@",[[NSDate date] descriptionWithCalendarFormat:@"%Z" timeZone:nil locale:nil]];
	NSString *chatWinMatchDefualtMsg = @"Thanks for the match <name>!";
	NSString *chatDeclineInviteDefualtMsg = @"No time now, thanks <name>!";
	
	NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
    [defaultPrefs setObject: @"wood" forKey:@"customBoard"];
	[defaultPrefs setObject: [NSNumber numberWithInt:1] forKey: @"startPosition"];
	[defaultPrefs setObject: [NSNumber numberWithInt:1] forKey: @"soundOnOff"];
	[defaultPrefs setObject: [NSNumber numberWithBool:YES] forKey: @"chatSoundOnOff"];
	[defaultPrefs setObject: @"25" forKey: @"loginTimeoutDelayTime"];
	[defaultPrefs setObject: @"fibs.com" forKey: @"serverAddress"];
	[defaultPrefs setObject: @"4321" forKey: @"serverPort"];
	[defaultPrefs setObject: @"3" forKey: @"matchLength"];
	
	[defaultPrefs setObject: [NSNumber numberWithInt:2] forKey: @"autoMoveClickCountPref"];
	
	[defaultPrefs setObject: [NSNumber numberWithBool:NO] forKey: @"highestDiceFirst"];
	[defaultPrefs setObject: [NSNumber numberWithBool:YES] forKey: @"checkRepBotOnInvite"];
	[defaultPrefs setObject: [NSNumber numberWithBool:YES] forKey: @"highlightTargetPips"];
	[defaultPrefs setObject: [NSNumber numberWithBool:YES] forKey: @"addToKeychain"];
	
	[defaultPrefs setObject: chatNewGameDefualtMsg  forKey: @"chatNewGameDefualtMsg"];
	[defaultPrefs setObject: [NSNumber numberWithBool:YES] forKey:@"chatDisplayNewGameDefualtMsg"];
	
	[defaultPrefs setObject: chatWinMatchDefualtMsg  forKey: @"chatWinMatchDefualtMsg"];
	[defaultPrefs setObject: [NSNumber numberWithBool:YES] forKey:@"chatDisplayWinMatchDefualtMsg"];
	
	[defaultPrefs setObject: chatDeclineInviteDefualtMsg  forKey: @"chatDeclineInviteDefualtMsg"];
	[defaultPrefs setObject: [NSNumber numberWithBool:YES] forKey:@"chatDisplayDeclineInviteDefualtMsg"];
	
	NSData *friendsListAsData = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray arrayWithCapacity:1]];
	[defaultPrefs setObject:friendsListAsData forKey: @"friendsList"];
	
	NSData *gagAndBlindListAsData = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray arrayWithCapacity:1]];
	[defaultPrefs setObject:gagAndBlindListAsData forKey: @"gagAndBlindList"];
	
	
	NSArray *terminalWindowSavedCommands = [NSArray arrayWithObjects:
		@"show saved",
		@"show watchers",
		@"show games",
		@"ratings",
		@"dicetest",
	nil];		

	
	[defaultPrefs setObject:terminalWindowSavedCommands forKey:@"terminalWindowSavedCommands"];
	
	
	
	[defaultPrefs setObject: @"" forKey: @"username"];
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultPrefs];
}
	
- (void)playSoundFile:(NSNotification *)notification
/*" Plays a sound file stored in the main app bundle with an aiff extension. "*/
{
	[self playSoundFileLocal:[notification object]];
}

- (void)prefsHaveChanged:(NSNotification *)notification
/*"  "*/
{
	
		NSString *currentDirectoryPath = [[NSFileManager defaultManager]currentDirectoryPath];
		NSString *prefForBoardImages = [[NSUserDefaults standardUserDefaults] stringForKey:@"customBoard"];
		NSString *pathToBoardImages = [[[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@/", currentDirectoryPath,prefForBoardImages]]autorelease];
		
		NSDictionary *boardAttributes = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@boardAttributes.plist", pathToBoardImages]];
	
	
	
	//[[theGameController theAGFIBSGameView] setHidden:YES];
	
	NSRect aFrame;
    NSWindow *mainWindow = [theGameController window];
	int windowWidthBoardAttribute = [[boardAttributes objectForKey:@"windowWidth"]intValue];
	int windowHeightBoardAttribute = [[boardAttributes objectForKey:@"windowHeight"]intValue];
	NSSize newSize;
	newSize = NSMakeSize(windowWidthBoardAttribute,windowHeightBoardAttribute);
	float newHeight = newSize.height;
    float newWidth = newSize.width;
   
	aFrame = [NSWindow contentRectForFrameRect:[mainWindow frame] styleMask:[mainWindow styleMask]];
    
    aFrame.origin.y += aFrame.size.height;
    aFrame.origin.y -= newHeight;
    aFrame.size.height = newHeight;
    aFrame.size.width = newWidth;
    
	if ([theToolbarController toolbarIsVisible]) {
		aFrame.size.height += 56;
		aFrame.origin.y -= 56;
	}
	
    aFrame = [NSWindow frameRectForContentRect:aFrame styleMask:[mainWindow styleMask]];
    
    [mainWindow setFrame:aFrame display:YES animate:YES];
	[[theGameController theAGFIBSGameView] setUpImagesAndChords];
	[theGameController updateTheGameView];
	//[[theGameController theAGFIBSGameView] setHidden:NO];
	
	NSLog(@"Prefs have changed");
}

- (IBAction)rollFromMenu:(id)sender;
{
	[[theGameController theAGFIBSGameView] rollDice];
}
- (IBAction)doubleFromMenu:(id)sender;
{
	[[theGameController theAGFIBSGameView] tryToDouble];
}

- (IBAction)sendBugReport:(id)sender;
/*"  "*/
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:email@host.com?subject=CocoaFibsBetaReport"]];
}

- (IBAction)makeADonation:(id)sender;
/*"  "*/
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sourceforge.net/projects/cocoafibs/"]];
}


- (void)displaySystemMsg:(NSNotification *)notification
/*"  "*/
{
	[theGameController clearSystemMsg];
	[theGameController displaySystemMsg:[notification object] withTime:NO];
}

- (void)playSoundFileLocal:(NSString *)fileName
/*" Plays a sound file stored in the main app bundle with an aiff extension. "*/
{
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"soundOnOff"] == 1) {
		NSString *soundPath;
		NSSound *thisSound;
		NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
		if (soundPath = [thisBundle pathForResource:fileName ofType:@"aif"]) {
			thisSound = [[[NSSound alloc] initWithContentsOfFile:soundPath byReference:NO] autorelease];
			[thisSound play];
		}
	}
}

- (void)displayMsgInTerminaleWindow:(NSString *)aMessage
{
	if ([[theGameController theAGFIBSGameView] isDragging]) {
		whileDraggingBufferNeedsEmpty = YES;
		[whileDraggingBufferGlobal addObject:aMessage];
	}
	else {
		if (whileDraggingBufferNeedsEmpty) {
			NSEnumerator *enumerator = [whileDraggingBufferGlobal objectEnumerator];
			id aObject;
			while (aObject = [enumerator nextObject]) {
				[terminalWindow displayInTerminal:aObject];
			}
			whileDraggingBufferNeedsEmpty = NO;
		}
		NSMutableString* aString = [NSMutableString stringWithCapacity:[aMessage length]];
		[aString setString:aMessage];  
		[terminalWindow displayInTerminal:aString];
	}
}


- (IBAction)printBoard:(id)sender
{
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    NSPrintOperation *printOp;

	printOp = [NSPrintOperation printOperationWithView:[theGameController theAGFIBSGameView] printInfo:printInfo];
    [printOp setShowPanels:YES];
    [printOp runOperation];
}

- (void)handleFIBSResponseEvent:(int)cookie message:(NSString *)aMessage
/*" Decides what to do based on a command returned from the server "*/
{
	NSString *playerName;
	NSArray *tokkenizer;
	int dontDisplayMsgInTerminal[20] = {FIBS_Empty,CLIP_WHO_END,CLIP_YOU_SAY,CLIP_SAYS,FIBS_Unknown,FIBS_YouRoll,FIBS_PlayerRolls,AGFIBS_PipCount,CLIP_SHOUTS,CLIP_YOU_SHOUT,CLIP_KIBITZES,CLIP_YOU_KIBITZ,CLIP_WHO_INFO,FIBS_Board,FIBS_BAD_Board};
	int i;
	BOOL displayInTerminal = YES;
	
	for (i=0; i <= 20; i++) {
		if (cookie == dontDisplayMsgInTerminal[i]) {
			displayInTerminal = NO;
			break;
		}
	}
	if (displayInTerminal) {
		[self displayMsgInTerminaleWindow:aMessage];
	}
			/*
			path = [@"~/Desktop/CocoaFIBSdebugInfo.txt" stringByExpandingTildeInPath];
			fileContents = [NSString stringWithContentsOfFile:path];
			newFileContents = [NSString stringWithFormat:@" %@ %@ %d %@ ", fileContents, @"\n", cookie, aMessage];
			[newFileContents writeToFile:path atomically:YES];
			*/

	switch(cookie){
	   
	   case FIBS_PreLogin: {
			FIBSPreLoginCheckForErrorCount++;
			if (FIBSPreLoginCheckForErrorCount > 30) {
				//[theLoginWindowController loginFailed];
				//[self loginFailed];
			}
			break;
		}
		case FIBS_MoreboardsFalse: {
			[theAGFIBSSocket sendMessage:@"toggle moreboards"];
			break;
		}
		case CLIP_MOTD_END: {
			[[userListWindow whoLoadingProgressIndicator] startAnimation:nil];
			break;
		}
		case FIBS_MoreboardsTrue: {
			[userListWindow whoListLoadingDone];
			break;
		}
		case FIBS_LoginPrompt: {
			[theAGFIBSSocket sendMessage:loginString];
			break;
		}
		case FIBS_FailedLogin: {
			[theLoginWindowController loginFailed];
			[self loginFailed];
			break;
		}
		case FIBS_YouGag: 
		case FIBS_YouBlind: {
			tokkenizer = [aMessage componentsSeparatedByString:@" "];
			NSMutableString *playerName = [NSMutableString stringWithCapacity:20];
			[playerName appendString:[tokkenizer objectAtIndex:3]];
			[playerName replaceOccurrencesOfString:@"." withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, [playerName length])];
			[self setAsGagAndBlind:playerName];
			NSString *stringToSend = [NSString stringWithFormat:@"who %@", playerName];
			[theAGFIBSSocket sendMessage:stringToSend];
			break;
		}
		case FIBS_YouUngag:
		case FIBS_YouUnblind: {
			tokkenizer = [aMessage componentsSeparatedByString:@" "];
			NSMutableString *playerName = [NSMutableString stringWithCapacity:20];
			[playerName appendString:[tokkenizer objectAtIndex:3]];
			[playerName replaceOccurrencesOfString:@"." withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, [playerName length])];
			[self removeAsGagAndBlind:playerName];
			NSString *stringToSend = [NSString stringWithFormat:@"who %@", playerName];
			[theAGFIBSSocket sendMessage:stringToSend];
			break;
		}
		
		case FIBS_NewMatchRequest: {
			[self playSoundFileLocal:@"invitedToGame"];
			[theGameController newMatchRequest:aMessage];
			break;
		}
		case FIBS_ResumeMatchRequest: {
			[self playSoundFileLocal:@"invitedToGame"];
			[theGameController resumeMatchRequest:aMessage];
			break;
		}
		case AGFIBS_NeedsMoreExp: {
			[theGameController displaySystemMsg:aMessage withTime:YES];
			break;
		}
		case AGFIBS_CantDoubleNow: {
			[theGameController displaySystemMsg:aMessage withTime:YES];
			break;
		}
		case AGFIBS_WantedToResign: {
			[theGameController displaySystemMsg:aMessage withTime:YES];
			break;
		}
		case FIBS_YouWinMatch: {
			[self playSoundFileLocal:@"winMatch"];
		}
		case FIBS_PlayerWinsMatch: {
			NSString *opponentName = [theGameController opponentNameValue];
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			[alert addButtonWithTitle:@"Ok"];
			[alert setMessageText:aMessage];
			[alert beginSheetModalForWindow:[theGameController window] modalDelegate:self didEndSelector:nil contextInfo:nil];
			
			[[theChatController gameChatTypeOfChatPopUpButton] selectItemAtIndex:3];
			[theChatController changeTypeOfChat:nil];
			
			[[theChatController privateChatSendTellToWhomTextField] setStringValue:opponentName];
			
			//Display custom chat win msg
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"chatDisplayWinMatchDefualtMsg"] boolValue]) {
				NSMutableString *dynamicChatWinMatchDefualtMsg = [[NSMutableString alloc] initWithCapacity:1];
				[dynamicChatWinMatchDefualtMsg appendString:[[NSUserDefaults standardUserDefaults] objectForKey:@"chatWinMatchDefualtMsg"]];
				if (!([dynamicChatWinMatchDefualtMsg rangeOfString:@"<name>"].location == NSNotFound)) {
					[dynamicChatWinMatchDefualtMsg replaceCharactersInRange:[dynamicChatWinMatchDefualtMsg rangeOfString:@"<name>"] withString:opponentName];
				}
				[[theChatController gameChatTextToSendTextField] setStringValue:dynamicChatWinMatchDefualtMsg];
			}
			break;
		}
		
		case FIBS_YouAcceptAndWin:
		case FIBS_ResignYouWin:
		case FIBS_WatchGameWins:
		case FIBS_PlayerWinsGame: 
		case FIBS_ResignWins:
		case FIBS_AcceptWins: {
			[theGameController displaySystemMsg:aMessage withTime:YES];
			[[[theGameController theAGFIBSGameView] theAGFIBSGameModel] newGame];
			[[theGameController theAGFIBSGameView] setNeedsDisplay:YES];
			break;
		}
		case FIBS_ResumeMatchAck0:
		case FIBS_ResumeMatchAck5:
		case FIBS_NewMatchAck9:
		case FIBS_NewMatchAck10:
		case FIBS_NewMatchAck2: {
			[[theChatController gameChatTypeOfChatPopUpButton] selectItemAtIndex:0];
			firstBoardOfNewGame = YES;
		}
		case FIBS_StartingNewGame: {
			[self playSoundFileLocal:@"roll0"];
			[theGameController displaySystemMsg:aMessage withTime:YES];
			
			[theChatController changeTypeOfChat:nil];
			[theAGFIBSSocket sendMessage:@"board"];
			break;
		}
		case FIBS_YouAreWatching: {
			firstBoardOfNewGame = NO;
			[theGameController displaySystemMsg:aMessage withTime:YES];
			[[theChatController gameChatTypeOfChatPopUpButton] selectItemAtIndex:0];
			[theChatController changeTypeOfChat:nil];
			[theAGFIBSSocket sendMessage:@"board"];
			break;
		}
		case FIBS_ReadyTrue: {
			[self setReadyToPlayStatus:YES];
			[theToolbarController toggleReadyToolbarItem];
			[theGameController displaySystemMsg:aMessage withTime:YES];
			break;
		}
		case FIBS_ReadyFalse: {
			[self setReadyToPlayStatus:NO];
			[theToolbarController toggleReadyToolbarItem];
			[theGameController displaySystemMsg:aMessage withTime:YES];
			break;
		}
		case FIBS_NotWatching:
		case FIBS_NotWatchingPlaying:
		case FIBS_NotPlaying:
		case FIBS_YouInvited:
		case FIBS_ResignRefused: 
		case FIBS_PlayerAcceptsDouble: 
		case FIBS_YouGiveUp: 
		case FIBS_YouStopWatching:
		case FIBS_PlayerNotPlaying:
		case FIBS_CantInviteSelf:
		case FIBS_NoOne:
		case FIBS_PlayerStartsWatching:
		case FIBS_PlayerStopsWatching: 
		case FIBS_PlayerIsWatching:
		case FIBS_YouDouble:
		case FIBS_DoubleTrue: 
		case FIBS_DoubleFalse: 
		case FIBS_IsAway: 
		case FIBS_AlreadyPlaying: 
		case FIBS_GreedyTrue: 
		case FIBS_GreedyFalse: 
		case AGFIBS_AnyStar: 
		case FIBS_NoSavedMatch: 
		case FIBS_MustMove:
		case FIBS_AutomoveTrue:
		case FIBS_AutomoveFalse: {
			[theGameController displaySystemMsg:aMessage withTime:YES];
			break;
		}
		case FIBS_RollOrDouble: {
			[self playSoundFileLocal:@"rollOrDouble"];
			[theGameController displaySystemMsg:aMessage withTime:YES];
			break;
		}

		case FIBS_PlayerWantsToResign: {
			tokkenizer = [aMessage componentsSeparatedByString:@" "];
			NSString *playerName = [tokkenizer objectAtIndex:0];
			NSString *willWinPoints = [tokkenizer objectAtIndex:7];
			[theGameController displayModelForUserChoiceWithMessageText:[NSString stringWithFormat:@"%@ wants to resign. You will win %@ point(s)", playerName, willWinPoints] button1Title:@"Accept" button2Title:@"Reject" iconImage:[NSImage imageNamed:@"resign"] didEndSelector:@selector(askedToResignAlertDidEndWithReturnCode:)];
			break;
		}
		case FIBS_AcceptRejectDouble: {
			[self playSoundFileLocal:@"double0"];
			tokkenizer = [aMessage componentsSeparatedByString:@" "];
			NSString *playerWhoDoubledName = [tokkenizer objectAtIndex:0];
			[theGameController displayModelForUserChoiceWithMessageText:[NSString stringWithFormat:@"%@ has doubled", playerWhoDoubledName] button1Title:@"Accept" button2Title:@"Reject" iconImage:[NSImage imageNamed:@"double"] didEndSelector:@selector(askedToDoubleAlertDidEndWithReturnCode:)];
			break;
		}
		case FIBS_YouRoll: {
			[theAGFIBSSocket sendMessage:@"board"];
			[self playSoundFileLocal:@"shake1"];
			[self playSoundFileLocal:@"roll0"];
			[theGameController displaySystemMsg:aMessage withTime:YES];
			break;
		}
		case FIBS_PlayerRolls: {
			[theAGFIBSSocket sendMessage:@"board"];
			[self playSoundFileLocal:@"shake1"];
			[self playSoundFileLocal:@"roll0"];
			[theGameController displaySystemMsg:aMessage withTime:YES];
			break;
		}
		case AGFIBS_PipCount: {
			[theGameController setPipCounts:aMessage];
			break;
		}
		case CLIP_YOU_SAY:{
			[theChatController clipYouSay:aMessage];
			break;
		}
		case CLIP_SAYS:{
			[self playSoundFileLocal:@"newChat"];
			[theChatController clipSay:aMessage];
			break;
		}
		case FIBS_Unknown:{
			if (!loginDone) {
				[self clipWhoEnd];
			}
			break;
		}
		case CLIP_WHO_END:{
			if (!loginDone) {
				[self clipWhoEnd];
			}
			if (!notifiedOfFriendsAndGagAndBlind) {
				if ([userListWindow containsAnyFriends]) {
					[self playSoundFileLocal:@"buddySound"];
				}
				[userListWindow handleGagAndBlinds];
				notifiedOfFriendsAndGagAndBlind = YES;
			}
			break;
		}
		case CLIP_SHOUTS:{
			[theChatController clipShouts:aMessage];
			break;
		}
		case FIBS_JoinNextGame:{
			[theAGFIBSSocket sendMessage:@"Join"];
			[theAGFIBSSocket sendMessage:@"Join"];
			break;
		}
		case CLIP_YOU_SHOUT:{
			[theChatController clipYouShout:aMessage];
			AGFIBSGameController *game = [[AGFIBSGameController alloc] init];
			[game showWindow:self];
			break;
		}
		case CLIP_KIBITZES:{
			[self playSoundFileLocal:@"newChat"];
			[theChatController clipKibitzes:aMessage];
			break;
		}
		case CLIP_YOU_KIBITZ:{
			[theChatController clipYouKibitz:aMessage];
			break;
		}
		case CLIP_OWN_INFO:{
			int positionOfStatus = 17;
			NSArray *clipOwnInfoMessage = [aMessage componentsSeparatedByString:@" "];
			NSString *playerStatus = [clipOwnInfoMessage objectAtIndex:positionOfStatus];
			[self setReadyToPlayStatus:[playerStatus intValue]];
			[theToolbarController toggleReadyToolbarItem];
			break;
			}
		case CLIP_WHO_INFO:{
			NSArray *clipWhoInfoKeys = [@"cookie name opponent watching ready away rating experience idle login hostname client email" componentsSeparatedByString:@" "];
			NSArray *clipWhoInfoMessage = [aMessage componentsSeparatedByString:@" "];
			if ([clipWhoInfoMessage count] != [clipWhoInfoKeys count]) {
				break;
			}
			NSMutableDictionary *clipWhoInfoDictionary = [[NSMutableDictionary alloc] initWithObjects:clipWhoInfoMessage forKeys:clipWhoInfoKeys];
			playerName = [clipWhoInfoDictionary objectForKey:@"name"];
			
			//Check for friend and gag and blind
			if ([self isFriend:playerName]) {
				[clipWhoInfoDictionary setObject:@"friend" forKey:@"relationship"];
			}
			else if ([self isGagAndBlind:playerName]) {
				[clipWhoInfoDictionary setObject:@"gagAndBlind" forKey:@"relationship"];
			}
			else {
				[clipWhoInfoDictionary setObject:@"normal" forKey:@"relationship"];
			}
			
			
			//preserve selected status is anything changes
			if ([playerName isEqualToString:[userListWindow selectedName]]) {
				[clipWhoInfoDictionary setObject:@"YES" forKey:@"selected"];
			}
			else {
				[clipWhoInfoDictionary setObject:@"NO" forKey:@"selected"];
			}
			NSString *status = [clipWhoInfoDictionary objectForKey:@"ready"];
			
			//set status for sort and toggle player status in toolbar
			if ([status isEqualToString:@"0"]) {
				[clipWhoInfoDictionary setObject:@"1Not Ready" forKey:@"status"];
				if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] isEqualToString:playerName]) {
					[self setReadyToPlayStatus:NO];
					[theToolbarController toggleReadyToolbarItem];
				}
			}
			else if ([status isEqualToString:@"1"]) {
				[clipWhoInfoDictionary setObject:@"3Ready" forKey:@"status"];
				if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] isEqualToString:playerName]) {
					[self setReadyToPlayStatus:YES];
					[theToolbarController toggleReadyToolbarItem];
				}
			}
			if (![[clipWhoInfoDictionary objectForKey:@"opponent"] isEqualToString:@"-"]) {
				[clipWhoInfoDictionary setObject:@"2Playing" forKey:@"status"];
			}			
			
			//Set Client
			NSString *clientName = [clipWhoInfoDictionary objectForKey:@"client"];
			if ([clientName rangeOfString:@"3DFiBs"].length != 0 || [clientName rangeOfString:@"RealFibs"].length != 0 || [clientName rangeOfString:@"C4FIBS"].length != 0 || [clientName rangeOfString:@"BBGT"].length != 0 || [clientName rangeOfString:@"Win"].length != 0 || [clientName rangeOfString:@"Tkfibs"].length != 0 || [clientName rangeOfString:@"FIBS/W"].length != 0)
				[clipWhoInfoDictionary setObject:@"LogoWindows" forKey:@"clientIcon"];
			else if ([clientName rangeOfString:@"Java"].length != 0 || [clientName rangeOfString:@"java"].length != 0 || [clientName rangeOfString:@"_!"].length != 0)
				[clipWhoInfoDictionary setObject:@"LogoJava" forKey:@"clientIcon"];
			else if ([clientName rangeOfString:@"Mac"].length != 0)
				[clipWhoInfoDictionary setObject:@"LogoAppleClassic" forKey:@"clientIcon"];
			else if ([clientName rangeOfString:@"Cocoa"].length != 0)
				[clipWhoInfoDictionary setObject:@"LogoAppleAqua" forKey:@"clientIcon"];
			else if ([clientName rangeOfString:@"Bot"].length != 0 || [clientName rangeOfString:@"bot"].length != 0 || [playerName rangeOfString:@"Bot"].length != 0)
				[clipWhoInfoDictionary setObject:@"LogoBot" forKey:@"clientIcon"];
			else if ([clientName rangeOfString:@"kbackgammon"].length != 0)
				[clipWhoInfoDictionary setObject:@"LogoLinux" forKey:@"clientIcon"];
			else
				[clipWhoInfoDictionary setObject:@"LogoOther" forKey:@"clientIcon"];
			
			//Convert Experience to NSNumber
		NSNumber *experience = [NSNumber numberWithInt:[[clipWhoInfoDictionary objectForKey:@"experience"] intValue]];
			NSLog(@"%@", [clipWhoInfoDictionary objectForKey:@"experience"]);
		[clipWhoInfoDictionary setObject:experience forKey:@"experience"];
			
			//Clean up the list
			[userListWindow removeUserFromList:playerName];
			[[userListWindow userListWindowData] addObject:clipWhoInfoDictionary];
			[userListWindow sort];
			[userListWindow selectRowAfterDataSourceUpdate];
			[[userListWindow tableView] reloadData];

			[clipWhoInfoDictionary release];
			[userListWindow setCountOfLogedInUsers];
			if ([playerName isEqualToString:[userListWindow selectedName]]) {
				[userListWindow updateUserDetailWindow:playerName]; 
			}

			
			
			break;
		}
		
		
		case CLIP_LOGIN: {
			int positionOfName = 1;
			NSArray *clipLogOutMessage = [aMessage componentsSeparatedByString:@" "];
			playerName = [clipLogOutMessage objectAtIndex:positionOfName];
			
			if (![userListWindow containsPlayer:playerName] && [self isFriend:playerName]) {
				[self playSoundFileLocal:@"buddySound"];
			}
			if (![userListWindow containsPlayer:playerName] && [self isGagAndBlind:playerName]) {
				[theAGFIBSSocket sendMessage:[NSString stringWithFormat:@"gag %@", playerName]];
				[theAGFIBSSocket sendMessage:[NSString stringWithFormat:@"blind %@", playerName]];
			}
			
			[userListWindow setUserInUserOutWithMsg:[NSString stringWithFormat:@"%@ Logs In", playerName]];
			[userListWindow setCountOfLogedInUsers];
			break;
		}
		case CLIP_LOGOUT: {
			int positionOfName = 1;
			NSArray *clipLogOutMessage = [aMessage componentsSeparatedByString:@" "];
			playerName = [clipLogOutMessage objectAtIndex:positionOfName];
			
			[userListWindow removeUserFromList:playerName];
			[userListWindow sort];
			[userListWindow selectRowAfterDataSourceUpdate];
			[[userListWindow tableView] reloadData];
			
			[userListWindow setUserInUserOutWithMsg:[NSString stringWithFormat:@"%@ Logs Out", playerName]];
			[userListWindow setCountOfLogedInUsers];
			break;
		}

		case FIBS_BAD_Board:
		case FIBS_Board:{
			[theAGFIBSSocket sendMessage:@"pip"];
			NSArray *fibsBoardStateKeys2 = [@"board player opponent matchLength playerScore opponentScore playerBar tri1 tri2 tri3 tri4 tri5 tri6 tri7 tri8 tri9 tri10 tri11 tri12 tri13 tri14 tri15 tri16 tri17 tri18 tri19 tri20 tri21 tri22 tri23 tri24 opponentBar turn playerDie1 playerDie2 opponentDie1 opponentDie2 doubleCube playerMayDouble opponentMayDouble wasDoubled color direction home bar playerHomeNum opponentHomeNum playerBarNum opponentBarNum canMove forcedMove didCrawford redoubles" componentsSeparatedByString:@" "];
			NSArray *fibsBoardStateMessage2 = [aMessage componentsSeparatedByString:@":"];
			//NSLog(aMessage);
			NSDictionary *fibsBoardStateDictionary2 = [[NSDictionary alloc] initWithObjects:fibsBoardStateMessage2 forKeys:fibsBoardStateKeys2];
			[[[theGameController theAGFIBSGameView] theAGFIBSGameModel] setFibsBoardStateDictionary:fibsBoardStateDictionary2];
			[[[theGameController theAGFIBSGameView] theAGFIBSGameModel] updateModelFromFIBS_Board];
			[theGameController updateTheGameView];
			
			//Display custom chat welcome msg
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"chatDisplayNewGameDefualtMsg"] boolValue] && firstBoardOfNewGame) {
				NSMutableString *dynamicChatNewGameDefualtMsg = [[NSMutableString alloc] initWithCapacity:1];
				NSString *opponentName = [[[[theGameController theAGFIBSGameView] theAGFIBSGameModel] fibsBoardStateDictionary] objectForKey:@"opponent"];
				[dynamicChatNewGameDefualtMsg appendString:[[NSUserDefaults standardUserDefaults] objectForKey:@"chatNewGameDefualtMsg"]];
				if (!([dynamicChatNewGameDefualtMsg rangeOfString:@"<name>"].location == NSNotFound)) {
					[dynamicChatNewGameDefualtMsg replaceCharactersInRange:[dynamicChatNewGameDefualtMsg rangeOfString:@"<name>"] withString:opponentName];
				}
				[[theChatController gameChatTextToSendTextField] setStringValue:dynamicChatNewGameDefualtMsg];
				firstBoardOfNewGame = NO;
			}


			break;
		}
	}
}

- (void)setAsGagAndBlind:(NSString *)name {
	NSData *gagAndBlindListAsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"gagAndBlindList"];
	NSMutableArray *gagAndBlindList = [NSKeyedUnarchiver unarchiveObjectWithData:gagAndBlindListAsData];
	[gagAndBlindList addObject:name];
	gagAndBlindListAsData = [NSKeyedArchiver archivedDataWithRootObject:gagAndBlindList];
	[[NSUserDefaults standardUserDefaults] setObject:gagAndBlindListAsData forKey:@"gagAndBlindList"];
}

- (void)removeAsGagAndBlind:(NSString *)name {
	NSData *gagAndBlindListAsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"gagAndBlindList"];
	NSMutableArray *gagAndBlindList = [NSKeyedUnarchiver unarchiveObjectWithData:gagAndBlindListAsData];
	[gagAndBlindList removeObject:name];
	gagAndBlindListAsData = [NSKeyedArchiver archivedDataWithRootObject:gagAndBlindList];
	[[NSUserDefaults standardUserDefaults] setObject:gagAndBlindListAsData forKey:@"gagAndBlindList"];
}

- (BOOL)isGagAndBlind:(NSString *)name {
	NSData *gagAndBlindListAsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"gagAndBlindList"];
	NSMutableArray *gagAndBlindList = [NSKeyedUnarchiver unarchiveObjectWithData:gagAndBlindListAsData];
	if ([gagAndBlindList containsObject:name]) {
		return YES;
	}
	else {
		return NO;
	}
}

- (void)setAsFriend:(NSString *)name {
	NSData *friendsListAsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"friendsList"];
	NSMutableArray *friendsList = [NSKeyedUnarchiver unarchiveObjectWithData:friendsListAsData];
	[friendsList addObject:name];
	friendsListAsData = [NSKeyedArchiver archivedDataWithRootObject:friendsList];
	[[NSUserDefaults standardUserDefaults] setObject:friendsListAsData forKey:@"friendsList"];
	[userListWindow setAttribute:@"relationship" forPlayer:name withValue:@"friend"];
}

- (void)removeAsFriend:(NSString *)name {
	NSData *friendsListAsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"friendsList"];
	NSMutableArray *friendsList = [NSKeyedUnarchiver unarchiveObjectWithData:friendsListAsData];
	[friendsList removeObject:name];
	friendsListAsData = [NSKeyedArchiver archivedDataWithRootObject:friendsList];
	[[NSUserDefaults standardUserDefaults] setObject:friendsListAsData forKey:@"friendsList"];
	[userListWindow setAttribute:@"relationship" forPlayer:name withValue:@"normal"];
}


- (BOOL)isFriend:(NSString *)name {
	NSData *friendsListAsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"friendsList"];
	NSMutableArray *friendsList = [NSKeyedUnarchiver unarchiveObjectWithData:friendsListAsData];
	if ([friendsList containsObject:name]) {
		return YES;
	}
	else {
		return NO;
	}
}




	
	

- (BOOL)validateMenuItem:(NSMenuItem*)anItem {
	
	if ([theAGFIBSSocket isConnected]) {
		if ([[anItem title] isEqualToString:@"Connect"]) {
			return NO;
		}
		if ([[anItem title] isEqualToString:@"Disconnect"]) {
			return YES;
		}
		return YES;
	}
	else  /* if (![theAGFIBSSocket isConnected])  */ {
		if ([[anItem title] isEqualToString:@"Connect"]) {
			return YES;
		}
		if ([[anItem title] isEqualToString:@"Disconnect"]) {
			return NO;
		}
		return YES;
	}
}

- (IBAction)connectMenuItemSelected:(id)sender
{
	[[theLoginWindowController loginWindow] makeKeyAndOrderFront:nil];
	[theLoginWindowController reset];
	
}

- (IBAction)disconnectMenuItemSelected:(id)sender
{
	[theAGFIBSSocket disconnect];
	[self reset];
	[theChatController reset];
	[theGameController reset];
	[userListWindow reset];
}

- (void)reset
{
	loginDone = NO;
	notifiedOfFriendsAndGagAndBlind = NO;
	[self connectMenuItemSelected:nil];
	FIBSPreLoginCheckForErrorCount = 0;
}

- (void)loginFailed
{
	[[[theGameController theAGFIBSGameView] parentWindow] close];
	[self reset];
}

- (NSMenuItem *)connectMenuItem {
    return [[connectMenuItem retain] autorelease];
}


- (NSMenuItem *)disconnectMenuItem {
    return [[disconnectMenuItem retain] autorelease];
}



- (void)checkForNewVersion
{
	
	NSString *currVersionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
	//NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:@"http://sourceforge.net/projects/cocoafibs/versionlist.xml"]];
	//NSString *latestVersionNumber = [productVersionDict valueForKey:@"cocoaFIBSBeta"];
	NSString *latestVersionNumber = currVersionNumber; //until we get updates going again. 
	if([latestVersionNumber isEqualTo: currVersionNumber])
	{
		// tell user software is up to date
		/*
		NSRunAlertPanel(NSLocalizedString(@"Your Software is up-to-date",
		@"Title of alert when a the user's software is up to date."),
		NSLocalizedString(@"You have the most recent version of Product One.",
		@"Alert text when the user's software is up to date."),
		NSLocalizedString(@"OK", @"OK"), nil, nil);
		*/
	}
	else
	{
		// tell user to download a new version
		int button = NSRunAlertPanel(@"A New Version is Available", [NSString stringWithFormat:@"A new version of CocoaFIBS is available (version %@). Would you like to download the new version now?", latestVersionNumber], @"Download", @"Not Now", nil);
		if(NSOKButton == button)
		{
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sourceforge.net/projects/cocoafibs/"]];
		}
	}

}









- (AGFIBSLoginWindowController *)theLoginWindowController 
/*" Returns the AGFIBSLoginWindowController "*/
{
    return [[theLoginWindowController retain] autorelease];
}

- (AGFIBSChatController *)theChatController 
/*" Returns the AGFIBSChatController "*/
{
    return [[theChatController retain] autorelease];
}

- (AGFIBSUserListWindowController *)userListWindow 
/*" Returns the AGFIBSUserListWindowController "*/
{
    return [[userListWindow retain] autorelease];
}

- (BOOL)readyToPlayStatus 
/*" Returns YES if the player has set them selves as ready, otherwise returns NO"*/
{
    return readyToPlayStatus;
}

- (void)setReadyToPlayStatus:(BOOL)newReadyToPlayStatus 
/*" Sets the readyToPlayStatus as YES or NO "*/
{
    if (readyToPlayStatus != newReadyToPlayStatus) {
        readyToPlayStatus = newReadyToPlayStatus;
    }
}

- (AGFIBSToolbarController *)theToolbarController 
/*" Returns the AGFIBSToolbarController "*/
{
    return [[theToolbarController retain] autorelease];
}

- (AGFIBSGameController *)theGameController 
/*" Returns the AGFIBSGameController "*/
{
    return [[theGameController retain] autorelease];
}

- (void)sendCommandToSocket:(NSNotification *)notification
/*" Notification method that tells the socket to sent a string to the server "*/
{
	NSString *stringToSend = [notification object];
	[theAGFIBSSocket sendMessage:stringToSend];
}

- (void)connect
/*" Notification method that tells the socket to conect to the server "*/
{
	[theAGFIBSSocket connect];
}

- (void)clipWhoEnd
/*" Called after the server compleates the login process and returns the incial bulk list of connected users  "*/
{
	if (!loginDone) {
		[theLoginWindowController loginDone];
		[loginWindow close];
		[theGameController setGameWindowTitleConnected:YES];
		[[[theGameController theAGFIBSGameView] parentWindow] makeKeyAndOrderFront:nil];
		[self showGameWindow];
		[theGameController openUserListDrawer];
		loginDone = YES;
		[theAGFIBSSocket sendMessage:@"set boardstyle 3"];
		[theAGFIBSSocket sendMessage:@"who"];
		[theAGFIBSSocket sendMessage:@"who ready"];
		[theAGFIBSSocket sendMessage:@"who away"];
		[theAGFIBSSocket sendMessage:@"who playing"];
		[theAGFIBSSocket sendMessage:@"toggle moreboards"];
		
		//[theAGFIBSSocket sendMessage:[NSString stringWithFormat:@"who %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"username"]]];
		
	}
}

- (IBAction)showUserListWindow:(id)sender
/*" NSDrawer delegate method to toggle the visibility of the user list drawer "*/
{
	[userListWindow showWindow:self];
}

- (IBAction)showPrefWindow:(id)sender
/*" Loads the pref controller NIB file "*/
{
	if (!thePrefWindow) {
		thePrefWindow = [[AGFIBSPrefController alloc] init];
	}
	[thePrefWindow showWindow:self];
}

- (IBAction)showTerminalWindow:(id)sender
/*" Loads the terminal controller NIB file "*/
{
	if (!terminalWindow) {
		terminalWindow = [[AGFIBSTerminalWindowController alloc] init];
	}
	[terminalWindow showWindow:self];
}

- (void)showPublicChatWindow
/*" "*/
{
	[[theChatController publicChatWindow] makeKeyAndOrderFront:nil];
}

- (void)showGameWindow
/*" Show the game window after login is done "*/
{
	[theGameController showWindow:self];
}

- (AGFIBSSocketStream *)theAGFIBSSocket 
/*" Return the AGFIBSSocketStream "*/
{
    return [[theAGFIBSSocket retain] autorelease];
}

- (void)setTheAGFIBSSocket:(AGFIBSSocketStream *)newTheAGFIBSSocket 
/*" Sets the AGFIBSSocketStream "*/
{
    if (theAGFIBSSocket != newTheAGFIBSSocket) {
        [theAGFIBSSocket release];
        theAGFIBSSocket = [newTheAGFIBSSocket retain];
    }
}

- (NSString *)loginString 
/*" Return the login string "*/
{
    return [[loginString retain] autorelease];
}

- (void)setLoginString:(NSString *)newLoginString 
/*" Return the login string "*/
{
    if (loginString != newLoginString) {
        [loginString release];
        loginString = [newLoginString retain];
    }
}

/*
- (IBAction)changeSortKey:(id)sender
//" The user has changed the value of the sort NSPopUpButton. Update the sortKey in the userListWindow instance. "
{
	if ([[sortKeyPopUpButton titleOfSelectedItem] isEqualToString:@"Username"]) {
		[userListWindow setSortKey:@"name"];
	}
	else if ([[sortKeyPopUpButton titleOfSelectedItem] isEqualToString:@"Status"]) {
		[userListWindow setSortKey:@"status"];
	}
	else if ([[sortKeyPopUpButton titleOfSelectedItem] isEqualToString:@"Rating"]) {
		[userListWindow setSortKey:@"rating"];
	}
	else if ([[sortKeyPopUpButton titleOfSelectedItem] isEqualToString:@"Experience"]) {
		[userListWindow setSortKey:@"experience"];
	}
	else if ([[sortKeyPopUpButton titleOfSelectedItem] isEqualToString:@"Client"]) {
		[userListWindow setSortKey:@"clientIcon"];
	}
	
}
*/

@end
