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
			
@class AGFIBSGameView;
@class AGFIBSGameModel;
@class AGFIBSAppController;
@class AGFIBSUserListWindowController;

@interface AGFIBSGameController : NSWindowController
{
    IBOutlet AGFIBSGameView *theAGFIBSGameView;					/*" Reference to the game view this controlls "*/
	IBOutlet NSDrawer *userListDrawer;							/*" The drawe attached to this window "*/
	IBOutlet AGFIBSAppController *theAppController;				/*" Reference to the app controller "*/
	IBOutlet AGFIBSUserListWindowController *userListWindow;	/*" Reference to the user list window controller "*/
	IBOutlet NSTextField *playerScore;							/*" The field that displays the player's score "*/
	IBOutlet NSTextField *opponentScore;						/*" The field that displays the opponent's score "*/
	IBOutlet NSTextField *playerName;							/*" The field that displays the player's name "*/
	IBOutlet NSTextField *opponentName;							/*" The field that displays the opponent's name "*/
	IBOutlet NSTextField *pipCountDifField;						/*"  "*/
	IBOutlet NSTextField *matchLengthField;						/*"  "*/
	IBOutlet NSTextField *desieredMatchLengthTextField;					/*" Field that holds the player's desiered match length "*/
	IBOutlet NSTextField *systemMsgText;						/*" The field that displays the systems messages from the server "*/
	IBOutlet NSStepper *matchLengthStepper;						/*"  "*/
	IBOutlet NSComboBox *matchLengthComboBox;
	int playerPipCount;											/*" The player's pip count "*/
	int opponentPipCount;										/*" The opponent's pip count "*/
	IBOutlet NSButton *togglePrivateChatButton;
	IBOutlet NSBox *privateChatBox;
}

/*" Designated Initializer "*/
- (id)init;


/*" Accessor methods  "*/
- (AGFIBSAppController *)theAppController; 
- (void)setTheAppController:(AGFIBSAppController *)newTheAppController; 
//- (AGFIBSGameModel *)theAGFIBSGameModel; 
//- (void)setTheAGFIBSGameModel:(AGFIBSGameModel *)newTheAGFIBSGameModel;
- (AGFIBSGameView *)theAGFIBSGameView;
//- (void)setTheAGFIBSGameView:(AGFIBSGameView *)newTheAGFIBSGameView;
- (NSString *)opponentNameValue;
- (void)reset;


/*" NSWindowController methods "*/
//- (void)windowDidLoad;
- (void)awakeFromNib;

/*" Game window methods "*/
- (void)updateTheGameView;
- (void)setGameWindowTitleConnected:(BOOL)connected;
- (void)displaySystemMsg:(NSString *)aMessage withTime:(BOOL)timeLimit;
- (void)clearSystemMsg;
- (void)setPipCounts:(NSString *)aMessage;
- (IBAction)togglePrivateChatViewable:(id)sender;
- (IBAction)toggleUserListDrawer:(id)sender;
- (IBAction)undoMoveAsRefreshBoard:(id)sender;
- (void)displayModelForUserChoiceWithMessageText:(NSString *)messageText button1Title:(NSString *)button1Title button2Title:(NSString *)button2Title iconImage:(NSImage *)iconImage didEndSelector:(SEL)didEndSelector;
//- (void)askedToDoubleAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)newMatchRequest:(NSString *)aMessage;
- (void)resumeMatchRequest:(NSString *)aMessage;
- (AGFIBSGameView *)theAGFIBSGameView;
- (IBAction)matchLengthStepperClicked:(id)sender;
- (IBAction)undoMove:(id)sender;
- (IBAction)redoMove:(id)sender;
- (IBAction)clickedOnPlayerUsername:(id)sender;
- (IBAction)clickedOnOpponentUsername:(id)sender; 
- (IBAction)openUserListDrawer;

@end
