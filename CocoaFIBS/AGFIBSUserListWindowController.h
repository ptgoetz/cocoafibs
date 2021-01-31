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
@class AGFIBSAppController;
@class AGFIBSUserDetailWindowController;

@interface AGFIBSUserListWindowController : NSWindowController {
	IBOutlet NSTableColumn *column;							/*" The user list column "*/
    IBOutlet NSTableView *tableView;						/*" The user list table "*/
	IBOutlet NSMenu *myMenu;								/*" The user list menu. Opened on right click. "*/
	IBOutlet NSPopUpButton *gameChatTypeOfChatPopUpButton;	/*" The game chat type pop up button "*/
	IBOutlet NSMenuItem *sortKeyMenuItem;					/*" NOT USED "*/
	IBOutlet NSTextField *gameLengthTextField;				/*" Field that holds the player's desiered game length "*/
	IBOutlet NSButton *nameSortButton;						/*"  "*/
	IBOutlet NSButton *statusSortButton;					/*"  "*/
	IBOutlet NSButton *experienceSortButton;				/*"  "*/
	IBOutlet NSButton *ratingeSortButton;					/*"  "*/
	IBOutlet NSButton *clientSortButton;					/*"  "*/
	IBOutlet AGFIBSAppController *theAppController;			/*" Reference to the app controller "*/
	IBOutlet NSTextField *userInUserOutTextField;
	IBOutlet NSTextField *totalLogedInUsers;	
	NSMutableArray *userListWindowData;						/*" The datasource for the user list NSTableView "*/
	NSMutableArray *arrayOfCells;							/*" The individual cells that make up the NSTableView "*/
	NSString *selectedName;									/*" The name of the currently selected user "*/
	NSString *sortKey;										/*" The key used to sort the user list "*/
	int selectedRow;										/*" The row number of the currently selected cell "*/
	NSMutableArray *sortDescriptorsArray;
	BOOL sortDirection;
	AGFIBSUserDetailWindowController *theUserDetailWindow;
	IBOutlet NSProgressIndicator *whoLoadingProgressIndicator;
}

/*" Designated Initializer. "*/
- (id)init;

/*" Sent Notifications "*/
-(void)sendNotificationToSendCommandToSocket:(NSString *)stringToSend;

/*" User List "*/
-(void)removeUserFromList:(NSString *)playerToRemove;
-(void)selectRow;

/*" Sorting "*/
- (IBAction)sort:(id)sender;
- (void)sort;

/*" Accessors Methods"*/
- (NSString *)selectedName;
- (void)setSelectedName:(NSString *)aName;
- (NSPopUpButton *)gameChatTypeOfChatPopUpButton;
- (void)setGameChatTypeOfChatPopUpButton:(NSPopUpButton *)newGameChatTypeOfChatPopUpButton;
- (NSMutableArray *)userListWindowData;
- (void)setUserListWindowData:(NSMutableArray *)newUserListWindowData;
- (NSDictionary *)getDataForPlayer:(NSString *)playerName;
- (void)showUserDetailWindowForUser:(NSString *)name;
- (NSProgressIndicator *)whoLoadingProgressIndicator;
- (void)whoListLoadingDone;
-(BOOL)containsAnyFriends;
-(BOOL)handleGagAndBlinds;
-(void)setAttribute:(NSString *)attribute forPlayer:(NSString *)playerName withValue:(NSString *)value; 
-(void)selectRowAfterDataSourceUpdate;
- (void)setCountOfLogedInUsers;
-(void)updateUserDetailWindow:(NSString *)name;
- (void)setUserInUserOutWithMsg:(NSString *)msg;
-(BOOL)containsPlayer:(NSString *)playerName;
- (void)reset;
-(void)setDynamicMenuItems;


/*" Event and Menu Handlers "*/
-(void)mouseDown:(NSEvent *)theEvent;
- (NSMenu *)menuForEvent:(NSEvent *)theEvent;
- (IBAction)menuItem:(id)sender;
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

/*" NSTableView Methods "*/
- (NSTableView *)tableView;
- (void)setTableView:(NSTableView *)newTableView; 
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)awakeFromNib;

@end



