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



#import <Cocoa/Cocoa.h>
@class AGFIBSUserListWindowController;
@class AGFIBSPrefController;
@class AGFIBSGameController;
@class AGFIBSSocketStream;
@class AGFIBSChatController;
@class AGFIBSLoginWindowController;
@class AGFIBSToolbarController;
@class AGFIBSTerminalWindowController;

@interface AGFIBSAppController : NSObject
{
    IBOutlet AGFIBSTerminalWindowController *terminalWindow;			/*"  "*/
	IBOutlet AGFIBSUserListWindowController *userListWindow;			/*" The controller class for the user list window "*/
	IBOutlet AGFIBSPrefController *thePrefWindow;						/*" The controller class for the preference list window "*/
	IBOutlet AGFIBSGameController *theGameController;					/*" The controller class for the game window "*/
	IBOutlet AGFIBSChatController *theChatController;					/*" The controller class for the chat window"*/
	IBOutlet AGFIBSLoginWindowController *theLoginWindowController;		/*" The controller class for the login window "*/
	IBOutlet AGFIBSToolbarController *theToolbarController;				/*" The controller class for the game window's toolbar "*/
	IBOutlet NSPopUpButton *sortKeyPopUpButton;							/*" PopUpButtonm for sorting the user list "*/
	AGFIBSSocketStream *theAGFIBSSocket;								/*" The main communications socket "*/
	BOOL loginDone;	
	BOOL notifiedOfFriendsAndGagAndBlind;														/*" Is the login process compleate? "*/
	BOOL readyToPlayStatus;												/*" Has the user set their status as ready to play? "*/
	IBOutlet NSWindow *loginWindow;										/*" The Login Window "*/
	NSString *loginString;												/*" The login string containing the syntax login MyClient_v0.1 1008 name mypassword "*/
	//NSMutableString *whileDraggingBuffer;
	NSMutableArray *whileDraggingBufferGlobal;
	BOOL whileDraggingBufferNeedsEmpty;
	IBOutlet NSPopUpButton *gameChatTypeOfChatPopUpButton;
	IBOutlet NSMenuItem *connectMenuItem;
	IBOutlet NSMenuItem *disconnectMenuItem;
	IBOutlet NSMenuItem *prefMenuItem;
	int FIBSPreLoginCheckForErrorCount;
	int firstBoardOfNewGame;
	
}

/*" Designated Initializer "*/
- (id)init;
- (void)handleFIBSResponseEvent:(int)cookie message:(NSString *)aMessage;

/*" Accessor Methods  "*/
- (AGFIBSLoginWindowController *)theLoginWindowController;
- (AGFIBSChatController *)theChatController;
- (AGFIBSUserListWindowController *)userListWindow;
- (AGFIBSToolbarController *)theToolbarController;
- (AGFIBSGameController *)theGameController;
- (AGFIBSSocketStream *)theAGFIBSSocket;
- (BOOL)readyToPlayStatus;
- (void)setReadyToPlayStatus:(BOOL)newReadyToPlayStatus;
- (void)setTheAGFIBSSocket:(AGFIBSSocketStream *)newTheAGFIBSSocket;
- (NSString *)loginString;
- (void)setLoginString:(NSString *)newLoginString;
- (NSMenuItem *)connectMenuItem;
- (NSMenuItem *)disconnectMenuItem;
- (AGFIBSSocketStream *)theAGFIBSSocket;
- (void)playSoundFileLocal:(NSString *)fileName;
- (void)setAsFriend:(NSString *)name;
- (void)removeAsFriend:(NSString *)name;


/*" Application Controller Notification Methods "*/
- (void)sendCommandToSocket:(NSNotification *)notification;
- (void)connect;
- (void)playSoundFile:(NSNotification *)notification;
- (void)prefsHaveChanged:(NSNotification *)notification;
- (void)loginFailed;
- (void)setAsGagAndBlind:(NSString *)name;
- (void)removeAsGagAndBlind:(NSString *)name;

/*" Application Controller Methods "*/
- (void)clipWhoEnd;
- (void)setDefaultPrefs;
- (IBAction)showUserListWindow:(id)sender;
- (IBAction)showPrefWindow:(id)sender;
- (void)showGameWindow;
//- (IBAction)changeSortKey:(id)sender;
- (void)checkForNewVersion;
- (IBAction)showTerminalWindow:(id)sender;
- (IBAction)sendBugReport:(id)sender;
- (IBAction)showUserListWindow:(id)sender;
- (IBAction)connectMenuItemSelected:(id)sender;
- (IBAction)disconnectMenuItemSelected:(id)sender;
- (IBAction)printBoard:(id)sender;
- (IBAction)makeADonation:(id)sender;
- (IBAction)rollFromMenu:(id)sender;
- (IBAction)doubleFromMenu:(id)sender;
- (void)showPublicChatWindow;
- (BOOL)isFriend:(NSString *)name;
- (BOOL)isGagAndBlind:(NSString *)name;
- (void)reset;

/*" Clean Up "*/
- (void)dealloc;
@end
