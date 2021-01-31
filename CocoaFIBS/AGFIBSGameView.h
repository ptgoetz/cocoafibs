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

@class AGFIBSGameModel;
@class AGFIBSTriangle;

@interface AGFIBSGameView : NSView
{
	AGFIBSGameModel *theAGFIBSGameModel;	/*" Reference to the game model this view will display "*/
	BOOL isDragging;						/*" Is the user currently dragging a chip? "*/
	NSPoint mouseLocationWhileDragging;		/*" Current X,Y of mouse while the user is draggng a chip "*/
	AGFIBSTriangle *draggedFromTriangle;	/*" The triangle where the user last dragged a chip from "*/
	int draggedChipOwnedBy;					/*" The owner of the triangle where the user last dragged a chip from "*/
	int topRowY;							/*" The Y chordanate for the top row of triangles "*/
	int topRowHomeY;						/*" The Y chordanate for the top row home "*/
	int bottomRowY;							/*" The Y chordanate for the bottom row of triangles "*/
	NSRect chipSizeRect;					/*" The size of a chip "*/
	NSRect chipRect;						/*" A rect to represent the chip "*/
	NSImage *chipImages[5];					/*" An array of chip images "*/
	int xChordsForTriangles[24];			/*" The X chordanates for all triangles "*/
	int yChordsForTriangles[24];			/*" The Y chordanates for all triangles "*/
	int xChordsForBar;						/*" The X chordanate for the both player's bars. Shared by both players. "*/
	int yChordsForPlayerBar;				/*" The Y chordanate for the player's bar. "*/
	int yChordsForOpponentBar;				/*" The Y chordanate for the opponent's bar. "*/
	int xChordsForHome;						/*" The X chordanate for both homes. "*/
	int xChordsForCube;
	int xChordsForDiceOnSide;
	NSPoint chordsForCube;					/*" The X,Y chordanates for the cube. "*/
	NSPoint chordsForPlayerDiceLeft;		/*" The X,Y chordanates for the dice. "*/
	NSPoint chordsForPlayerDiceRight;		/*" The X,Y chordanates for the dice. "*/
	NSPoint chordsForOpponentDiceLeft;		/*" The X,Y chordanates for the dice. "*/
	NSPoint chordsForOpponentDiceRight;		/*" The X,Y chordanates for the dice. "*/
	NSPoint chordsForPlayerRollDice;		/*" The X,Y chordanates for the dice. "*/
	NSImage *playerDiceImages[7];			/*" Array of images for the diferent dice "*/
	NSImage *opponentDiceImages[7];			/*" Array of images for the diferent dice "*/
	int distanceToUseUpDice;				/*" The total distance traveled in a multi-die move. Use up x number of dice based on this number. "*/
	NSWindow *parentWindow;					/*" Reference to the window that hold this view. "*/
	BOOL firstTimeDiceRoll;
	NSRect oldRedrawRect;
	int startDirectionLeftRightPref;
	int yChordsForLeftOpponentDieInHome;
	int yChordsForRightOpponentDieInHome;
	int yChordsForLeftPlayerDieInHome;
	int yChordsForRightPlayerDieInHome;
	BOOL mouseIsDown;
	NSPoint mouseLocationWhileDown;
	NSString *pathToBoardImages;
	NSImage *rollOrDoubleImage;
	NSImage *cubeImage;
	NSString *imageType;
	NSImage *backgroundImage;
	NSImage *pip1to12Image;
	NSImage *pip24to13Image;
	NSImage *pip12to1Image;
	NSImage *pip13to24Image;
	NSImage *cubeImages[65];
	int chipSize;
	int chipHeightInHome;
	NSDictionary *boardAttributes;
	int xChordsForTopPipNumbers;
	int yChordsForTopPipNumbers;
	int xChordsForBottomPipNumbers;
	int yChordsForBottomPipNumbers;
	NSData *undoData;
	NSMutableArray *undoDataStack;
	NSMutableArray *redoDataStack;
	BOOL firstDragMovement;
}

/*" Designated Initializer. "*/
- (id)initWithFrame:(NSRect)frameRect;

- (void)setUpImagesAndChords;

/*" Overridden Draw Methods "*/
- (void)drawRect:(NSRect)arect;

/*" Custom Draw Methods "*/
- (void)drawBackground;
- (void)drawModel;
	
/*" Game View Helper Methods "*/
//- (void)setChords;
-(void)sendNotificationToSendCommandToSocket:(NSString *)stringToSend;
-(void)chipFollowsMouseWhileDragging;
//- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;
-(AGFIBSTriangle *)determineTriangleFromPoint:(NSPoint)aPoint;
-(BOOL)mouseDownCanMoveWindow;
-(void)pickupChip:(NSPoint)mouseLocation;
-(void)placeChip:(AGFIBSTriangle *)selectedTriangle;
-(BOOL)canMoveFromTriangle:(AGFIBSTriangle *)fromTriangle;
-(BOOL)canMoveToTriangle:(AGFIBSTriangle *)toTriangle;
-(int)pipNumToArrayPos:(int)pipPos;
- (void)rollDice;
- (void)tryToDouble;
- (void)setUpImagesAndChords;
- (void)setDynamicChords;
- (void)highlightTriangles;
- (void)setUndoData:(NSData *)newUndoData;
- (void)setHighlightStatusOfTriangles;
-(AGFIBSTriangle *)determineTriangleFromPoint:(NSPoint)aPoint;
-(void)clearUndoStack;
-(void)displayMoveString;
- (void)autoMoveFromTriangle:(AGFIBSTriangle *)fromTriangle;
- (void)clearAllHighlightedTriangles;
- (NSData *)undoData;

/*" Events "*/
- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;
- (void)mouseUp:(NSEvent *)theEvent;

/*" Accessors Methods"*/
- (NSWindow *)parentWindow;
- (void)setParentWindow:(NSWindow *)newParentWindow;
-(AGFIBSGameModel *)theAGFIBSGameModel; 
- (BOOL)isDragging;
- (void)setTheAGFIBSGameModel:(AGFIBSGameModel *)newTheAGFIBSGameModel;

/* move methods */
-(void)undoMove;
-(void)redoMove;

@end
