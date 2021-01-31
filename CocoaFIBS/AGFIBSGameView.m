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


#import "AGFIBSGameView.h"
#import "AGFIBSGameModel.h"
#import "AGFIBSTriangle.h"
#include "AGFIBSDice.h"

/*" Game View Constants "*/
#define NUMBER_OF_TRIANGLES 24
#define TRIANGLE_WIDTH 32
#define TRIANGLE_HEIGHT 150
#define BAR_PIP_NUMBER 0
#define HOME_PIP_NUMBER 25
#define START_DIRECTION_LEFT 1
#define START_DIRECTION_RIGHT 2
#define DIRECTION_PIP24_TO_PIP1 -1	/*"  "*/
#define DIRECTION_PIP1_TO_PIP24 1	/*"  "*/

@implementation AGFIBSGameView
/*"
An instance of this view class defines the basic drawing, event-handling, and printing architecture of the game model. 
"*/

- (id)initWithFrame:(NSRect)frameRect
/*" Designated Initializer. Set the inicial X,Y chordinates for all objects in the game. "*/
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		[self setUpImagesAndChords];
		[self setNeedsDisplay:YES];
		undoDataStack = [[NSMutableArray alloc] initWithCapacity:1];
		redoDataStack = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return self;
}


- (void)dealloc
/*" Clean Up "*/
{
	[boardAttributes release];
	[undoDataStack release];
	[redoDataStack release];
	[super dealloc];
}

- (void)setUpImagesAndChords
/*"  "*/
{
		NSString *boardsFolderInBundle = [NSString stringWithFormat:@"%@/Contents/Resources/boards", [[NSBundle mainBundle] bundlePath]];
		NSString *prefForBoardImages = [[NSUserDefaults standardUserDefaults] stringForKey:@"customBoard"];
		if (prefForBoardImages == nil) {
			prefForBoardImages = @"wood";
		}
		//NSString *pathToApplicationSupportBoardsFolder = @"/Library/Application Support/Mac OS X FIBS/boards";

		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		[fileManager changeCurrentDirectoryPath:boardsFolderInBundle];
		
		pathToBoardImages = [[[NSString alloc] initWithString:[NSString stringWithFormat:@"%@/%@/", boardsFolderInBundle, prefForBoardImages]]autorelease];
		
		imageType =  [NSString stringWithString:@"png"];
		
		NSLog([NSString stringWithFormat:@"%@",pathToBoardImages]);
		
		boardAttributes = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@boardAttributes.plist", pathToBoardImages]];
		
		
		firstTimeDiceRoll = YES;
		mouseIsDown = NO;
		isDragging = NO;
		draggedChipOwnedBy = 0;
		
		chipSize = [[boardAttributes objectForKey:@"chipSize"]intValue];
		
		topRowY = [[boardAttributes objectForKey:@"topRowY"]intValue];
		topRowHomeY = [[boardAttributes objectForKey:@"topRowHomeY"]intValue];
		bottomRowY = [[boardAttributes objectForKey:@"bottomRowY"]intValue];
		chipHeightInHome = [[boardAttributes objectForKey:@"chipHeightInHome"]intValue];
		
		xChordsForBar = [[boardAttributes objectForKey:@"xChordsForBar"]intValue];
		yChordsForPlayerBar = [[boardAttributes objectForKey:@"yChordsForPlayerBar"]intValue];
		yChordsForOpponentBar = [[boardAttributes objectForKey:@"yChordsForOpponentBar"]intValue];
		
		chordsForPlayerDiceLeft = NSMakePoint([[boardAttributes objectForKey:@"xChordsForPlayerDiceLeft"]intValue],[[boardAttributes objectForKey:@"yChordsForPlayerDiceLeft"]intValue]);
		chordsForPlayerDiceRight = NSMakePoint([[boardAttributes objectForKey:@"xChordsForPlayerDiceRight"]intValue],[[boardAttributes objectForKey:@"yChordsForPlayerDiceRight"]intValue]);
		
		chordsForOpponentDiceLeft = NSMakePoint([[boardAttributes objectForKey:@"xChordsForOpponentDiceLeft"]intValue],[[boardAttributes objectForKey:@"yChordsForOpponentDiceLeft"]intValue]);
		chordsForOpponentDiceRight = NSMakePoint([[boardAttributes objectForKey:@"xChordsForOpponentDiceRight"]intValue],[[boardAttributes objectForKey:@"yChordsForOpponentDiceRight"]intValue]);
		
		yChordsForLeftOpponentDieInHome = [[boardAttributes objectForKey:@"yChordsForLeftOpponentDieInHome"]intValue];
		yChordsForRightOpponentDieInHome = [[boardAttributes objectForKey:@"yChordsForRightOpponentDieInHome"]intValue];
		
		yChordsForLeftPlayerDieInHome = [[boardAttributes objectForKey:@"yChordsForLeftPlayerDieInHome"]intValue];
		yChordsForRightPlayerDieInHome = [[boardAttributes objectForKey:@"yChordsForRightPlayerDieInHome"]intValue];;
		int sizeOfDiceImage = [[boardAttributes objectForKey:@"sizeOfDiceImage"]intValue];
		
		xChordsForTopPipNumbers = [[boardAttributes objectForKey:@"xChordsForTopPipNumbers"]intValue];
		yChordsForTopPipNumbers = [[boardAttributes objectForKey:@"yChordsForTopPipNumbers"]intValue];
		xChordsForBottomPipNumbers = [[boardAttributes objectForKey:@"xChordsForBottomPipNumbers"]intValue];
		yChordsForBottomPipNumbers = [[boardAttributes objectForKey:@"yChordsForBottomPipNumbers"]intValue];
				
		chipSizeRect = NSMakeRect(0,0,chipSize,chipSize);
		chipRect = NSMakeRect(0,0,chipSize,chipSize);
		
		
		
		NSImage *tempImageLoader;
		tempImageLoader = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@playerpiece.%@", pathToBoardImages,imageType]];
		chipImages[1] = tempImageLoader;
		
		tempImageLoader = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@opponentpiece.%@", pathToBoardImages,imageType]];
		chipImages[2] = tempImageLoader;
		
		tempImageLoader = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@playerpiecehome.%@", pathToBoardImages,imageType]];
		chipImages[3] = tempImageLoader;
		
		tempImageLoader = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@opponentpiecehome.%@", pathToBoardImages,imageType]];
		chipImages[4] = tempImageLoader;
		
		
		playerDiceImages[1] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@playerdie1.%@", pathToBoardImages,imageType]];
		playerDiceImages[2] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@playerdie2.%@", pathToBoardImages,imageType]];
		playerDiceImages[3] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@playerdie3.%@", pathToBoardImages,imageType]];
		playerDiceImages[4] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@playerdie4.%@", pathToBoardImages,imageType]];
		playerDiceImages[5] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@playerdie5.%@", pathToBoardImages,imageType]];
		playerDiceImages[6] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@playerdie6.%@", pathToBoardImages,imageType]];
		
		opponentDiceImages[1] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@opponentdie1.%@", pathToBoardImages,imageType]];
		opponentDiceImages[2] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@opponentdie2.%@", pathToBoardImages,imageType]];
		opponentDiceImages[3] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@opponentdie3.%@", pathToBoardImages,imageType]];
		opponentDiceImages[4] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@opponentdie4.%@", pathToBoardImages,imageType]];
		opponentDiceImages[5] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@opponentdie5.%@", pathToBoardImages,imageType]];
		opponentDiceImages[6] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@opponentdie6.%@", pathToBoardImages,imageType]];
		
		rollOrDoubleImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@rolldice.%@", pathToBoardImages,imageType]];
		cubeImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@cube1.%@", pathToBoardImages,imageType]];
		backgroundImage = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@background.%@", pathToBoardImages,imageType]];
		
		pip1to12Image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@pip1to12.%@", pathToBoardImages,imageType]];
		pip24to13Image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@pip24to13.%@", pathToBoardImages,imageType]];
		pip12to1Image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@pip12to1.%@", pathToBoardImages,imageType]];
		pip13to24Image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@pip13to24.%@", pathToBoardImages,imageType]];
		
		cubeImages[1] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@cube1.%@", pathToBoardImages,imageType]];
		cubeImages[2] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@cube2.%@", pathToBoardImages,imageType]];
		cubeImages[4] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@cube4.%@", pathToBoardImages,imageType]];
		cubeImages[8] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@cube8.%@", pathToBoardImages,imageType]];
		cubeImages[16] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@cube16.%@", pathToBoardImages,imageType]];
		cubeImages[32] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@cube32.%@", pathToBoardImages,imageType]];
		cubeImages[64] = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@cube64.%@", pathToBoardImages,imageType]];
		
		chordsForPlayerRollDice = NSMakePoint((chordsForPlayerDiceLeft.x+sizeOfDiceImage),chordsForPlayerDiceLeft.y);
		oldRedrawRect = NSMakeRect(0,0,0,0);
		
		[self setDynamicChords];
}

- (void)setDynamicChords
/*"  Sets chords based on user preference"*/
{
		

		int i;
		startDirectionLeftRightPref = [[NSUserDefaults standardUserDefaults] integerForKey:@"startPosition"];
		
		if (startDirectionLeftRightPref == 2) {
			for (i = 0; i < NUMBER_OF_TRIANGLES; i++) {
				xChordsForTriangles[i] = [[[boardAttributes objectForKey:@"rightPipOriginsX"] objectAtIndex:i]intValue];
				if (i < 12) {
					yChordsForTriangles[i] = [[boardAttributes objectForKey:@"topRowY"]intValue];
				}
				else {
					yChordsForTriangles[i] = [[boardAttributes objectForKey:@"bottomRowY"]intValue];
				}
			}
			xChordsForHome = [[boardAttributes objectForKey:@"xChordsForHomeRight"]intValue];
			xChordsForDiceOnSide = [[boardAttributes objectForKey:@"xChordsForDiceOnSideRight"]intValue];
			xChordsForCube = [[boardAttributes objectForKey:@"xChordsForCubeRight"]intValue];
		}
		else {
			for (i = 0; i < NUMBER_OF_TRIANGLES; i++) {
				xChordsForTriangles[i] = [[[boardAttributes objectForKey:@"leftPipOriginsX"] objectAtIndex:i]intValue];
				if (i < 12) {
					yChordsForTriangles[i] = [[boardAttributes objectForKey:@"topRowY"]intValue];
				}
				else {
					yChordsForTriangles[i] = [[boardAttributes objectForKey:@"bottomRowY"]intValue];
				}
			}
			xChordsForHome = [[boardAttributes objectForKey:@"xChordsForHomeLeft"]intValue];
			xChordsForDiceOnSide = [[boardAttributes objectForKey:@"xChordsForDiceOnSideLeft"]intValue];
			xChordsForCube = [[boardAttributes objectForKey:@"xChordsForCubeLeft"]intValue];
		}
		
}

- (void)drawRect:(NSRect)rect 
/*" Draw the view "*/
{
	[self setDynamicChords];
	[self drawBackground];
	[self drawModel];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"highlightTargetPips"]) {
		[self highlightTriangles];
	}
	if (isDragging && [self canMoveFromTriangle:draggedFromTriangle]) {
		[self chipFollowsMouseWhileDragging];
	}
}


- (NSWindow *)parentWindow 
/*" Returns the Parent Window of this view"*/
{
    return [[parentWindow retain] autorelease];
}

- (void)setParentWindow:(NSWindow *)newParentWindow 
/*" Sets the Parent Window of this view "*/
{
    if (parentWindow != newParentWindow) {
        [parentWindow release];
        parentWindow = [newParentWindow retain];
    }
}

-(void)sendNotificationToSendCommandToSocket:(NSString *)stringToSend 
/*" Send a string to the server "*/
{
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AGFIBSSendCommandToSocket" object:stringToSend];
}
-(void)chipFollowsMouseWhileDragging 
/*" Redraws a chip on the view to match the current mouse position while dragging. "*/
{
	chipRect = NSMakeRect((mouseLocationWhileDragging.x-chipSize/2),(mouseLocationWhileDragging.y-chipSize/2),chipSize,chipSize);
	[chipImages[draggedChipOwnedBy] compositeToPoint:chipRect.origin operation:NSCompositeSourceOver];
}


-(void)mouseDown:(NSEvent *)theEvent 
/*" Informs the receiver that the user has pressed the left mouse button specified by theEvent. Trys to pick up a chip. "*/
{
	//[self addCursorRect:[self frame] cursor:[NSCursor closedHandCursor]];
	//[self highlightTriangles];
	[self setUndoData:[NSKeyedArchiver archivedDataWithRootObject:theAGFIBSGameModel]];
	[self pickupChip:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
	
	if ([theEvent clickCount] == 1) {
		[self setHighlightStatusOfTriangles];
	}
	[self setNeedsDisplay:YES];
	firstDragMovement = YES;
		
}

-(void)mouseDragged:(NSEvent *)theEvent 
/*" Informs the receiver that the user has moved the mouse with the left button pressed specified by theEvent. "*/
{
	
	if (firstDragMovement == YES) {
		if ([self canMoveFromTriangle:draggedFromTriangle]) { 
			mouseLocationWhileDown = [self convertPoint:[theEvent locationInWindow] fromView:nil];
			mouseIsDown = YES;
			[draggedFromTriangle removeChip]; 
		}
		else {
			draggedFromTriangle = nil;
			[theAGFIBSGameModel setDraggedFromTriangle:nil];
			draggedChipOwnedBy = 0;
		}
		[self setNeedsDisplay:YES];
		firstDragMovement = NO;
	}
	isDragging = YES;
	mouseIsDown = NO;
	mouseLocationWhileDragging = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSRect redrawRect = NSMakeRect(mouseLocationWhileDragging.x-(chipSize/2),mouseLocationWhileDragging.y-(chipSize/2),chipSize,chipSize);
	oldRedrawRect = redrawRect;
	[self setNeedsDisplay:YES];
}



-(void)mouseUp:(NSEvent *)theEvent 
/*" Informs the receiver that the user has released the left mouse button specified by theEvent. Cheks to see if the mouse position matches the position of any board objects the user may have been trying to interact with. "*/
{

	//[self removeCursorRect:[self bounds] cursor:[NSCursor closedHandCursor]];
	mouseIsDown = NO;
	NSPoint aPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	//NSLog(@"%f",aPoint.y);
	NSRect myRectPlayerDiceLeft;
	NSRect myRectPlayerDiceRight;
	myRectPlayerDiceLeft = NSMakeRect(chordsForPlayerDiceLeft.x,chordsForPlayerDiceLeft.y,[playerDiceImages[1] size].height,[playerDiceImages[1] size].width);
	myRectPlayerDiceRight = NSMakeRect(chordsForPlayerDiceRight.x,chordsForPlayerDiceRight.y,[playerDiceImages[1] size].height,[playerDiceImages[1] size].width);
	
	NSRect myRectPlayerRollDice =  NSMakeRect(chordsForPlayerRollDice.x,chordsForPlayerRollDice.y,[rollOrDoubleImage size].height,[rollOrDoubleImage size].width);
	
	NSRect myRectCube = NSMakeRect(chordsForCube.x,chordsForCube.y,[cubeImage size].height,[cubeImage size].width);
		
				
				
	//Clicks on dice
	//NSLog(@"%d",[[theAGFIBSGameModel playerHome] numberOfChips]);
	if (NSPointInRect(aPoint,  myRectPlayerDiceLeft) || NSPointInRect(aPoint,  myRectPlayerDiceRight)) {
		if([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSAlternateKeyMask) {
			[[theAGFIBSGameModel playerDice] swapDice];
			[self setNeedsDisplay:YES];
		}
		else {
			NSEnumerator * e = [[[theAGFIBSGameModel playerDice] playerMoves] objectEnumerator];
			id obj;
			NSString *moveString = @"move";
			while (obj = [e nextObject]) {
				moveString = [moveString stringByAppendingFormat:@"%@ ",obj];
			}
			[self sendNotificationToSendCommandToSocket:moveString];
			NSNotificationCenter *nc;
			nc = [NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"AGFIBSSPlaySoundFile" object:@"pickup0"];
			[self setNeedsDisplay:YES];
			firstTimeDiceRoll = YES;
			[nc postNotificationName:@"AGFIBSDisplaySystemMsg" object:@""];
			[self clearUndoStack];
		}
		
		
	}
	//Clicks on roll
	else if (NSPointInRect(aPoint,  myRectPlayerRollDice) ) {
		[self rollDice];
	}
	//Clicks on cube
	else if (NSPointInRect(aPoint,  myRectCube) ) {
		[self tryToDouble];
	}
	
	//Clicks on chip or lets go on triangle
	AGFIBSTriangle *selectedTriangle = [self determineTriangleFromPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
		if (isDragging == NO && [[NSUserDefaults standardUserDefaults] integerForKey:@"autoMoveClickCountPref"] == 1 && [theEvent clickCount] == 2 && [selectedTriangle numberOfChips] > 1) {
			[self autoMoveFromTriangle:selectedTriangle];
		}
		else if (isDragging == NO && draggedFromTriangle == selectedTriangle && [theEvent clickCount] == [[NSUserDefaults standardUserDefaults] integerForKey:@"autoMoveClickCountPref"]) { {
			[self autoMoveFromTriangle:selectedTriangle];
		}
	}
	else if (isDragging == YES){
		[self placeChip:selectedTriangle];
	}
	isDragging = NO;
	[self clearAllHighlightedTriangles];
	[self setNeedsDisplay:YES];
}

- (void)autoMoveFromTriangle:(AGFIBSTriangle *)fromTriangle
/*" "*/
{
		
		int fromTriangleArrayPos = [self pipNumToArrayPos:[fromTriangle pipNumber]];
		
		int playerDie1 = [[theAGFIBSGameModel playerDice] valueOfDie:0];
		int playerDie2 = [[theAGFIBSGameModel playerDice] valueOfDie:1];
		
		if ([fromTriangle pipNumber] == BAR_PIP_NUMBER) {
			playerDie1--;
			playerDie2--;
			fromTriangle = [theAGFIBSGameModel playerBar];
			fromTriangleArrayPos = 0;
		}
		
		AGFIBSTriangle *toTrianglePossability1 = nil;
		AGFIBSTriangle *toTrianglePossability2 = nil;
		AGFIBSTriangle *toHomeTrianglePossability = [theAGFIBSGameModel playerHome];
		BOOL moveIsToHome = NO;
		int i;
		
		//Do this once, break if we want to
		for (i = 0; i <= 0; i++) { 
			
			if([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSAlternateKeyMask) {
				if (fromTriangleArrayPos+playerDie1 < NUMBER_OF_TRIANGLES) {
					toTrianglePossability1 = [[theAGFIBSGameModel gameBoard] objectAtIndex:fromTriangleArrayPos+playerDie1];
				}
				else if (fromTriangleArrayPos+playerDie1 >= NUMBER_OF_TRIANGLES) {
					if ([self canMoveFromTriangle:fromTriangle] && [self canMoveToTriangle:toHomeTrianglePossability]) {
						[fromTriangle removeChip]; 
						[self placeChip:toHomeTrianglePossability];
						break;
					}
				}
			}
			else if([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSCommandKeyMask) {
				if (fromTriangleArrayPos+playerDie2 < NUMBER_OF_TRIANGLES) {
					toTrianglePossability2 = [[theAGFIBSGameModel gameBoard] objectAtIndex:fromTriangleArrayPos+playerDie2];
				}
				else if (fromTriangleArrayPos+playerDie2 >= NUMBER_OF_TRIANGLES) {
					if ([self canMoveFromTriangle:fromTriangle] && [self canMoveToTriangle:toHomeTrianglePossability]) {
						[fromTriangle removeChip]; 
						[self placeChip:toHomeTrianglePossability];
						break;
					}
				}
			}
			else if ([self canMoveFromTriangle:fromTriangle] && [self canMoveToTriangle:toHomeTrianglePossability]) {
				[fromTriangle removeChip]; 
				[self placeChip:toHomeTrianglePossability];
				break;
			}
			else {
				if (fromTriangleArrayPos+playerDie1 < NUMBER_OF_TRIANGLES) {
					toTrianglePossability1 = [[theAGFIBSGameModel gameBoard] objectAtIndex:fromTriangleArrayPos+playerDie1];
				}
				if (fromTriangleArrayPos+playerDie2 < NUMBER_OF_TRIANGLES) {
					toTrianglePossability2 = [[theAGFIBSGameModel gameBoard] objectAtIndex:fromTriangleArrayPos+playerDie2];
				}
			}

			//then try others
			if (!moveIsToHome && toTrianglePossability1 != nil) {
				if ([self canMoveFromTriangle:fromTriangle] && [self canMoveToTriangle:toTrianglePossability1]) {
					[fromTriangle removeChip]; 
					[self placeChip:toTrianglePossability1];
					break;
				}
			}
			if (!moveIsToHome && toTrianglePossability2 != nil) {
				if ([self canMoveFromTriangle:fromTriangle] && [self canMoveToTriangle:toTrianglePossability2]) {
					[fromTriangle removeChip]; 
					[self placeChip:toTrianglePossability2];
					break;
				}
			}
			//[self placeChip:fromTriangle];
		}
		
}

- (void)autoDoubleMoveFromTriangle:(AGFIBSTriangle *)fromTriangle
/*" "*/
{
		int fromTriangleArrayPos = [self pipNumToArrayPos:[fromTriangle pipNumber]];
		
		int playerDie1 = [[theAGFIBSGameModel playerDice] valueOfDie:0];
		int playerDie2 = [[theAGFIBSGameModel playerDice] valueOfDie:1];
		
		if ([fromTriangle pipNumber] == BAR_PIP_NUMBER) {
			playerDie1--;
			playerDie2--;
			fromTriangle = [theAGFIBSGameModel playerBar];
			fromTriangleArrayPos = 0;
		}
		
		AGFIBSTriangle *toTrianglePossability1 = nil;
		AGFIBSTriangle *toTrianglePossability2 = nil;
		AGFIBSTriangle *toHomeTrianglePossability = [theAGFIBSGameModel playerHome];
		BOOL moveIsToHome = NO;
		int i;
		
		//Do this once, break if we want to
		for (i = 0; i <= 0; i++) { 
			if ([self canMoveFromTriangle:fromTriangle] && [self canMoveToTriangle:toHomeTrianglePossability]) {
				[fromTriangle removeChip]; 
				[self placeChip:toHomeTrianglePossability];
				break;
			}
			else {
				if (fromTriangleArrayPos+playerDie1 < NUMBER_OF_TRIANGLES && fromTriangleArrayPos+playerDie2 < NUMBER_OF_TRIANGLES) {
					toTrianglePossability1 = [[theAGFIBSGameModel gameBoard] objectAtIndex:fromTriangleArrayPos+playerDie1];
					toTrianglePossability2 = [[theAGFIBSGameModel gameBoard] objectAtIndex:fromTriangleArrayPos+playerDie2];
				}
			}

			//then try others
			if (!moveIsToHome && toTrianglePossability1 != nil  && toTrianglePossability2 != nil) {
				if ([self canMoveFromTriangle:fromTriangle] && [self canMoveToTriangle:toTrianglePossability1]) {
					[fromTriangle removeChip]; 
					[self placeChip:toTrianglePossability1];
					[fromTriangle removeChip]; 
					[self placeChip:toTrianglePossability2];
					break;
				}
			}
		}
		
}

- (void)doubleAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
/*"  Called if the player confirms that they want to double. "*/
{
    if (returnCode == NSAlertFirstButtonReturn) {
		[self sendNotificationToSendCommandToSocket:@"double"];
		[self setNeedsDisplay:YES];
    }
}

- (void)tryToDouble
{
NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	NSString *playerMayDouble = [[theAGFIBSGameModel fibsBoardStateDictionary] objectForKey:@"playerMayDouble"];
	int playerMayDoubleInt = [playerMayDouble intValue];
	[[alert window] setAlphaValue:0.9];
	if (playerMayDoubleInt) {
		[alert addButtonWithTitle:@"Double"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert setMessageText:@"Would you like to double the cube?"];
		[alert setIcon:[NSImage imageNamed:@"double"]];
		[alert setInformativeText:@""];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[self parentWindow] modalDelegate:self didEndSelector:@selector(doubleAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	}
	else {
		[alert addButtonWithTitle:@"Ok"];
		[alert addButtonWithTitle:nil];
		[alert setMessageText:@"You are not allowed to double at this time."];
		[alert setInformativeText:@""];
		[alert setIcon:[NSImage imageNamed:@"double"]];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[self parentWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
}

- (void)rollDice
{
	[self sendNotificationToSendCommandToSocket:@"roll"];
	[self setNeedsDisplay:YES];
}


-(AGFIBSTriangle *)determineTriangleFromPoint:(NSPoint)aPoint 
/*" Given a point what triangle or other game object is at that point. "*/
{
	int i;
	NSRect myRectTop;
	NSRect myRectBottom;
	NSRect myRectPlayerBar;
	NSRect myRectOpponentBar;
	NSRect myRectPlayerHome;
	
	for (i = 0; i < NUMBER_OF_TRIANGLES; i++) {
		myRectTop = NSMakeRect(xChordsForTriangles[i],(yChordsForTriangles[i]-TRIANGLE_HEIGHT+chipSize),TRIANGLE_WIDTH,TRIANGLE_HEIGHT);
		myRectBottom = NSMakeRect(xChordsForTriangles[i],yChordsForTriangles[i],TRIANGLE_WIDTH,TRIANGLE_HEIGHT);
		myRectPlayerBar = NSMakeRect(xChordsForBar,yChordsForPlayerBar,TRIANGLE_WIDTH,TRIANGLE_HEIGHT);
		myRectOpponentBar = NSMakeRect(xChordsForBar,(yChordsForOpponentBar-TRIANGLE_HEIGHT+chipSize),TRIANGLE_WIDTH,TRIANGLE_HEIGHT);
		myRectPlayerHome = NSMakeRect(xChordsForHome,bottomRowY,TRIANGLE_WIDTH,TRIANGLE_HEIGHT);

		
		if (i <= 11 && NSPointInRect(aPoint,  myRectTop) || NSPointInRect(aPoint, myRectBottom))
			return [[theAGFIBSGameModel gameBoard] objectAtIndex:i];
		else if (NSPointInRect(aPoint,  myRectPlayerBar))
			return [theAGFIBSGameModel playerBar];
		else if (NSPointInRect(aPoint,  myRectOpponentBar))
			return [theAGFIBSGameModel opponentBar];
		else if (NSPointInRect(aPoint,  myRectPlayerHome))
			return [theAGFIBSGameModel playerHome];
	}
	return nil; //user dragged chip into invalid area
}

- (void)drawBackground 
/*" Draw the background eliments onto the view. "*/
{
	
	NSImage *topPipNumbers;
	NSImage *bottomPipNumbers;

	int playerDirectionInGame = [theAGFIBSGameModel direction];
	
	topPipNumbers = [NSImage imageNamed:@"blank"];
	bottomPipNumbers = [NSImage imageNamed:@"blank"];




	if (startDirectionLeftRightPref == START_DIRECTION_LEFT) {
		if (playerDirectionInGame == DIRECTION_PIP1_TO_PIP24) {
			topPipNumbers = pip1to12Image;
			bottomPipNumbers = pip24to13Image;
		}
		else if (playerDirectionInGame == DIRECTION_PIP24_TO_PIP1) {
			topPipNumbers = pip24to13Image;
			bottomPipNumbers = pip1to12Image;
		}
	}
	else if (startDirectionLeftRightPref == START_DIRECTION_RIGHT) {
		if (playerDirectionInGame == DIRECTION_PIP1_TO_PIP24) {
			topPipNumbers = pip12to1Image;
			bottomPipNumbers = pip13to24Image;
		}
		else if (playerDirectionInGame == DIRECTION_PIP24_TO_PIP1) {
			topPipNumbers = pip13to24Image;
			bottomPipNumbers = pip12to1Image;
		}
	}


	
	NSRect backgroundImageRect = NSMakeRect(0,0,[backgroundImage size].width,[backgroundImage size].height);
	[backgroundImage drawInRect:backgroundImageRect fromRect:backgroundImageRect operation:NSCompositeSourceOver fraction:1.0];
	
	NSRect topPipNumbersImageRect1 = NSMakeRect(xChordsForTopPipNumbers,yChordsForTopPipNumbers,[topPipNumbers size].width,[topPipNumbers size].height);
	NSRect topPipNumbersImageRect2 = NSMakeRect(0,0,[topPipNumbers size].width,[topPipNumbers size].height);
	[topPipNumbers drawInRect:topPipNumbersImageRect1 fromRect:topPipNumbersImageRect2 operation:NSCompositeSourceOver fraction:1.0];
	
	NSRect bottomPipNumbersImageRect1 = NSMakeRect(xChordsForBottomPipNumbers,yChordsForBottomPipNumbers,[bottomPipNumbers size].width,[bottomPipNumbers size].height);
	NSRect bottomPipNumbersImageRect2 = NSMakeRect(0,0,[bottomPipNumbers size].width,[bottomPipNumbers size].height);
	[bottomPipNumbers drawInRect:bottomPipNumbersImageRect1 fromRect:bottomPipNumbersImageRect2 operation:NSCompositeSourceOver fraction:1.0];
	



}

- (int)windowWidthBoardAttribute
{
	return [[boardAttributes objectForKey:@"windowWidth"]intValue];
}

- (int)windowHeightBoardAttribute
{
	return [[boardAttributes objectForKey:@"windowHeight"]intValue];
}


- (void)setHighlightStatusOfTriangles
{
	int i;
	for (i = 0; i < NUMBER_OF_TRIANGLES; i++) {
		AGFIBSTriangle *potentialMoveToTriangle = [[theAGFIBSGameModel gameBoard] objectAtIndex:i];
		//NSLog([potentialMoveToTriangle description]);
		if ([self canMoveToTriangle:potentialMoveToTriangle]) {
			[potentialMoveToTriangle setHighlighted:YES];
		}
	}
	if ([self canMoveToTriangle:[theAGFIBSGameModel playerHome]]) {
		[[theAGFIBSGameModel playerHome] setHighlighted:YES];
	}
}

- (void)highlightTriangles
/*" "*/
{
	int i;
	NSRect triangleHighlightRect;
	NSBezierPath *highlightRectPath;
	AGFIBSTriangle *potentialMoveToTriangle;
	[[NSColor yellowColor] set];
	for (i = 0; i < NUMBER_OF_TRIANGLES; i++) {
		potentialMoveToTriangle = [[theAGFIBSGameModel gameBoard] objectAtIndex:i];
		if ([potentialMoveToTriangle highlighted]) {			
			if (i <= 11) {
				triangleHighlightRect = NSMakeRect(xChordsForTriangles[i],(yChordsForTriangles[i]-TRIANGLE_HEIGHT+chipSize+1),TRIANGLE_WIDTH,TRIANGLE_HEIGHT);
			}
			else if (i > 11) {
				triangleHighlightRect = NSMakeRect(xChordsForTriangles[i],yChordsForTriangles[i],TRIANGLE_WIDTH,TRIANGLE_HEIGHT);
			}
			highlightRectPath = [NSBezierPath bezierPathWithRect:triangleHighlightRect];
			[highlightRectPath stroke];
		}
	}
	if ([[theAGFIBSGameModel playerHome] highlighted]) {
		NSRect myRectPlayerHome = NSMakeRect(xChordsForHome-4,bottomRowY,TRIANGLE_WIDTH,TRIANGLE_HEIGHT);
		highlightRectPath = [NSBezierPath bezierPathWithRect:myRectPlayerHome];
		[highlightRectPath stroke];
	}
}

- (void)clearAllHighlightedTriangles
/*" "*/
{
	unsigned int i;
	AGFIBSTriangle *aTriangle;
	for (i = 0; i < NUMBER_OF_TRIANGLES; i++) {
		aTriangle = [[theAGFIBSGameModel gameBoard] objectAtIndex:i];
		[aTriangle setHighlighted:NO];
	}
	[[theAGFIBSGameModel playerHome] setHighlighted:NO];
}

- (void)drawModel 
/*" Draw the eliments from the Game Model onto the view. "*/
{
	
	int i,j;
	NSPoint myPoint;
	int ownedBy;
	int numberOfChipsOnTriangle;
	int y;
	for (i = 0; i < NUMBER_OF_TRIANGLES; i++) {
		myPoint = NSMakePoint(xChordsForTriangles[i]+2, yChordsForTriangles[i]);
		ownedBy = [[[theAGFIBSGameModel gameBoard] objectAtIndex:i] ownedBy];
		numberOfChipsOnTriangle = [[[theAGFIBSGameModel gameBoard] objectAtIndex:i] numberOfChips];
		y = 0;
		
		
		for (j = 0; j < numberOfChipsOnTriangle; j++) {
			if (j < 5) {										//5 or less chips on tri
				if (i <= 11)
					y =  myPoint.y - (chipSize * j);			//top row
				else
					y =  myPoint.y + (chipSize * j);			//bottom row
			}
			else {												//more then 5 chips on tri, add some space for the offset
				if (i <= 11)
					y =  myPoint.y - 10 - (chipSize * (j-5));  //top row
				else
					y =  myPoint.y + 10 + (chipSize * (j-5));  //bottom row
			}
			
			chipRect = NSMakeRect(myPoint.x,y,chipSize,chipSize);
			[chipImages[ownedBy] drawInRect:chipRect fromRect:chipSizeRect operation:NSCompositeSourceOver fraction:1.0];
		}
	}
	
	if (mouseIsDown) {
	//MouseDown
	chipRect = NSMakeRect((mouseLocationWhileDown.x-chipSize/2),(mouseLocationWhileDown.y-chipSize/2),chipSize,chipSize);
	[chipImages[1] compositeToPoint:chipRect.origin operation:NSCompositeSourceOver];
	}
	//Playey Bar
	int numOfChipsOnBar = [[theAGFIBSGameModel playerBar] numberOfChips];
	ownedBy = 1;
	myPoint = NSMakePoint(xChordsForBar, yChordsForPlayerBar);
	for (j = 0; j < numOfChipsOnBar; j++) {
		y =  myPoint.y + (chipSize * j);
		chipRect = NSMakeRect(myPoint.x,y,chipSize,chipSize);
		[chipImages[ownedBy] drawInRect:chipRect fromRect:chipSizeRect operation:NSCompositeSourceOver fraction:1.0];
	}
	//Opponent Bar
	numOfChipsOnBar = [[theAGFIBSGameModel opponentBar] numberOfChips];
	ownedBy = 2;
	myPoint = NSMakePoint(xChordsForBar, yChordsForOpponentBar);
	for (j = 0; j < numOfChipsOnBar; j++) {
		y =  myPoint.y - (chipSize * j);
		chipRect = NSMakeRect(myPoint.x,y,chipSize,chipSize);
		[chipImages[ownedBy] drawInRect:chipRect fromRect:chipSizeRect operation:NSCompositeSourceOver fraction:1.0];
	}
	//Player Home
	int numOfChipsInHome = [[theAGFIBSGameModel playerHome] numberOfChips];
	ownedBy = 1;
	myPoint = NSMakePoint(xChordsForHome, bottomRowY);
	for (j = 0; j < numOfChipsInHome; j++) {
		y =  myPoint.y + (chipHeightInHome * j);
		chipRect = NSMakeRect(myPoint.x,y,chipSize,chipSize);
		[chipImages[ownedBy+2] drawInRect:chipRect fromRect:chipSizeRect operation:NSCompositeSourceOver fraction:1.0];
	}

	
	//Opponent Home
	numOfChipsInHome = [theAGFIBSGameModel opponentHome];
	ownedBy = 2;
	myPoint = NSMakePoint(xChordsForHome, topRowY);
	for (j = 0; j < numOfChipsInHome; j++) {
		y =  myPoint.y - (chipHeightInHome * j+3)+(chipHeightInHome * 2.7);
		chipRect = NSMakeRect(myPoint.x,y,chipSize,chipSize);
		[chipImages[ownedBy+2] drawInRect:chipRect fromRect:chipSizeRect operation:NSCompositeSourceOver fraction:1.0];
	}
		
	
	//Cube
	NSString *cubeValue = [[theAGFIBSGameModel fibsBoardStateDictionary] objectForKey:@"doubleCube"];
	NSImage *lcubeImage = cubeImages[[cubeValue intValue]];
	
	if ([[[theAGFIBSGameModel fibsBoardStateDictionary] objectForKey:@"playerMayDouble"] intValue] && [[[theAGFIBSGameModel fibsBoardStateDictionary] objectForKey:@"opponentMayDouble"] intValue]) {
		chordsForCube = NSMakePoint(xChordsForCube,164);
	}
	else if ([[[theAGFIBSGameModel fibsBoardStateDictionary] objectForKey:@"playerMayDouble"] intValue]) {
		chordsForCube = NSMakePoint(xChordsForCube,10);
	}
	else if ([[[theAGFIBSGameModel fibsBoardStateDictionary] objectForKey:@"opponentMayDouble"] intValue]) {
		chordsForCube = NSMakePoint(xChordsForCube,319);
	}
	
	[lcubeImage drawInRect:NSMakeRect(chordsForCube.x,chordsForCube.y,[lcubeImage size].height,[lcubeImage size].width) 
					fromRect:NSMakeRect(0,0,[lcubeImage size].height,[lcubeImage size].width) 
					operation:NSCompositeSourceOver 
					fraction:1.0];
	//Dice
	
	
	
	
	int playerDie1 = [[theAGFIBSGameModel playerDice] valueOfDie:0];
	int playerDie2 = [[theAGFIBSGameModel playerDice] valueOfDie:1];
	int opponentDie1 = [[theAGFIBSGameModel opponentDice] valueOfDie:0];
	int opponentDie2 = [[theAGFIBSGameModel opponentDice] valueOfDie:1];
	
	int playerDieFromLastTurn1 = [[theAGFIBSGameModel playerDiceFromLastTurn] valueOfDie:0];
	int playerDieFromLastTurn2 = [[theAGFIBSGameModel playerDiceFromLastTurn] valueOfDie:1];
	int opponentDieFromLastTurn1 = [[theAGFIBSGameModel opponentDiceFromLastTurn] valueOfDie:0];
	int opponentDieFromLastTurn2 = [[theAGFIBSGameModel opponentDiceFromLastTurn] valueOfDie:1];
	
	
	int color = [[[theAGFIBSGameModel fibsBoardStateDictionary] objectForKey:@"color"] intValue];
	int turn = [[[theAGFIBSGameModel fibsBoardStateDictionary] objectForKey:@"turn"] intValue];
	
	if (playerDie1 != 0)
	{
	
		if (firstTimeDiceRoll) {
			firstTimeDiceRoll = NO;	
		}
	
		[playerDiceImages[playerDie1] drawInRect:NSMakeRect(chordsForPlayerDiceLeft.x,chordsForPlayerDiceLeft.y,[playerDiceImages[playerDie1] size].height,[playerDiceImages[playerDie1] size].width) 
							  fromRect:NSMakeRect(0,0,[playerDiceImages[playerDie1] size].height,[playerDiceImages[playerDie1] size].width) 
							 operation:NSCompositeSourceOver 
							  fraction:1.0];
	
		[playerDiceImages[playerDie2] drawInRect:NSMakeRect(chordsForPlayerDiceRight.x,chordsForPlayerDiceRight.y,[playerDiceImages[playerDie2] size].height,[playerDiceImages[playerDie2] size].width) 
							  fromRect:NSMakeRect(0,0,[playerDiceImages[playerDie2] size].height,[playerDiceImages[playerDie2] size].width) 
							 operation:NSCompositeSourceOver 
							  fraction:1.0];

	}
	else if (opponentDie1 != 0)
	{
		
		[opponentDiceImages[opponentDie1] drawInRect:NSMakeRect(chordsForOpponentDiceLeft.x,chordsForOpponentDiceLeft.y,[opponentDiceImages[opponentDie1] size].height,[opponentDiceImages[opponentDie1] size].width) 
								fromRect:NSMakeRect(0,0,[opponentDiceImages[opponentDie1] size].height,[opponentDiceImages[opponentDie1] size].width) 
							   operation:NSCompositeSourceOver 
								fraction:1.0];
								
		[opponentDiceImages[opponentDie2] drawInRect:NSMakeRect(chordsForOpponentDiceRight.x,chordsForOpponentDiceRight.y,[opponentDiceImages[opponentDie2] size].height,[opponentDiceImages[opponentDie2] size].width) 
							  fromRect:NSMakeRect(0,0,[opponentDiceImages[opponentDie2] size].height,[opponentDiceImages[opponentDie2] size].width) 
							 operation:NSCompositeSourceOver 
							  fraction:1.0];
							  

	}

	
	else if (playerDie1 == 0 && opponentDie1 == 0 && color == turn) {

		[rollOrDoubleImage				drawInRect:NSMakeRect((chordsForPlayerDiceLeft.x + [playerDiceImages[1] size].width),chordsForPlayerDiceLeft.y,[rollOrDoubleImage size].height,[rollOrDoubleImage size].width) 
									fromRect:NSMakeRect(0,0,[rollOrDoubleImage size].height,[rollOrDoubleImage size].width) 
									operation:NSCompositeSourceOver 
									fraction:1.0];
	}
	
	//Draw dice from last roll
	if (color == turn) {
									  
		[opponentDiceImages[opponentDieFromLastTurn1] drawInRect:NSMakeRect(xChordsForDiceOnSide,yChordsForLeftOpponentDieInHome,[opponentDiceImages[opponentDieFromLastTurn1] size].height,[opponentDiceImages[opponentDieFromLastTurn1] size].width) 
								fromRect:NSMakeRect(0,0,[opponentDiceImages[opponentDieFromLastTurn1] size].height,[opponentDiceImages[opponentDieFromLastTurn1] size].width) 
							   operation:NSCompositeSourceOver 
								fraction:1.0];
								
		[opponentDiceImages[opponentDieFromLastTurn2] drawInRect:NSMakeRect(xChordsForDiceOnSide,yChordsForRightOpponentDieInHome,[opponentDiceImages[opponentDieFromLastTurn2] size].height,[opponentDiceImages[opponentDieFromLastTurn2] size].width) 
							  fromRect:NSMakeRect(0,0,[opponentDiceImages[opponentDieFromLastTurn2] size].height,[opponentDiceImages[opponentDieFromLastTurn2] size].width) 
							 operation:NSCompositeSourceOver 
							  fraction:1.0];
	}
	else {
		[playerDiceImages[playerDieFromLastTurn1] drawInRect:NSMakeRect(xChordsForDiceOnSide,yChordsForLeftPlayerDieInHome,[playerDiceImages[playerDieFromLastTurn1] size].height,[playerDiceImages[playerDieFromLastTurn1] size].width) 
							  fromRect:NSMakeRect(0,0,[playerDiceImages[playerDieFromLastTurn1] size].height,[playerDiceImages[playerDieFromLastTurn1] size].width) 
							 operation:NSCompositeSourceOver 
							  fraction:1.0];
	
		[playerDiceImages[playerDieFromLastTurn2] drawInRect:NSMakeRect(xChordsForDiceOnSide,yChordsForRightPlayerDieInHome,[playerDiceImages[playerDieFromLastTurn2] size].height,[playerDiceImages[playerDieFromLastTurn2] size].width) 
							  fromRect:NSMakeRect(0,0,[playerDiceImages[playerDieFromLastTurn2] size].height,[playerDiceImages[playerDieFromLastTurn2] size].width) 
							 operation:NSCompositeSourceOver 
							  fraction:1.0];
	}
}

-(BOOL)mouseDownCanMoveWindow
/*" Prevents in-view clicking from moving textured metal windows "*/
{
	return NO;
}

- (BOOL)isDragging {
    return isDragging;
}




-(void)pickupChip:(NSPoint)mouseLocation 
/*" Remove a chip from a triangle in the model. "*/
{
	

	AGFIBSTriangle *selectedTriangle = [self determineTriangleFromPoint:mouseLocation];
	draggedFromTriangle = selectedTriangle;
	[theAGFIBSGameModel setDraggedFromTriangle:selectedTriangle];
	draggedChipOwnedBy = [draggedFromTriangle ownedBy];
	

	
}

-(void)placeChip:(AGFIBSTriangle *)selectedTriangle 
/*" Add a chip to a triangle in the model. Check to see if its a legal move. Use the apropriate number of dice. Handle bumps. "*/
{

	if (draggedFromTriangle != selectedTriangle) {
		[undoDataStack addObject:[self undoData]];
	}
	
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	if ([self canMoveToTriangle:selectedTriangle] && selectedTriangle != nil) { 
		int color = [theAGFIBSGameModel color];
		NSString *moveString = @"";
		int draggedFromTrianglePipNum = [draggedFromTriangle pipNumber];
		int distanceBetweenTriangles = abs([selectedTriangle pipNumber] - [draggedFromTriangle pipNumber]);
		if ([draggedFromTriangle pipNumber] == 0 && color == 1)  {
				distanceBetweenTriangles = 25 - distanceBetweenTriangles;
				draggedFromTrianglePipNum = 25;
		}
		if ([theAGFIBSGameModel isPlayerHome] &&  [selectedTriangle pipNumber] == HOME_PIP_NUMBER  && color == 1) {
			distanceBetweenTriangles = [draggedFromTriangle pipNumber];
		}	
		
		int moveType = [[theAGFIBSGameModel playerDice] legalMoveType:distanceBetweenTriangles withGameModel:theAGFIBSGameModel];
		//NSLog(@"moveType %d",moveType);
		int die1 = [[theAGFIBSGameModel playerDice] valueOfDie:0];
		int die2 = [[theAGFIBSGameModel playerDice] valueOfDie:1];
		
		
		if (moveType == 1) {
			moveString = [NSString stringWithFormat:@" %d - %d ", [draggedFromTriangle pipNumber], [selectedTriangle pipNumber]];
			//NSLog(@"[selectedTriangle pipNumber] %d",[selectedTriangle pipNumber]);
		}

		if (moveType == 2) {
			int inbetweenTrianglePipNum = 0;
			int otherPossablilityForInbetweenTriabglePipNum = 0;
			if (color == 1 && [draggedFromTriangle pipNumber]  == 0 ) {
				inbetweenTrianglePipNum = 25 - abs([draggedFromTriangle pipNumber] - die1);
				otherPossablilityForInbetweenTriabglePipNum = 25 - abs([draggedFromTriangle pipNumber] - die2);
			}
			else if (color == 1 && [draggedFromTriangle pipNumber] > 0) {
				inbetweenTrianglePipNum = abs([draggedFromTriangle pipNumber] - die1);
				otherPossablilityForInbetweenTriabglePipNum = abs([draggedFromTriangle pipNumber] - die2);
			}
			else if (color == -1) {
				inbetweenTrianglePipNum = abs([draggedFromTriangle pipNumber] + die1);
				otherPossablilityForInbetweenTriabglePipNum = abs([draggedFromTriangle pipNumber] + die2);
			}
				
				
				//for bearing off
				if (inbetweenTrianglePipNum < otherPossablilityForInbetweenTriabglePipNum) {
					int temp = inbetweenTrianglePipNum;
					int temp2 = otherPossablilityForInbetweenTriabglePipNum;
					inbetweenTrianglePipNum = temp2;
					otherPossablilityForInbetweenTriabglePipNum = temp;
				}
				
				int inbetweenTriangleArrayPos = abs([self pipNumToArrayPos:inbetweenTrianglePipNum]);
				int otherPossablilityForInbetweenTriabgleArrayPos = abs([self pipNumToArrayPos:otherPossablilityForInbetweenTriabglePipNum]);
				
				
				
				int ownedBY = [[[theAGFIBSGameModel gameBoard] objectAtIndex:inbetweenTriangleArrayPos] ownedBy];
				int otherOwnedBY = [[[theAGFIBSGameModel gameBoard] objectAtIndex:otherPossablilityForInbetweenTriabgleArrayPos] ownedBy];
				
	
	//NSLog(@"Object at 11 ownedby %d ", [[[theAGFIBSGameModel gameBoard] objectAtIndex:11] ownedBy]);
	
				
				if (ownedBY == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:inbetweenTriangleArrayPos] numberOfChips] == 1){
					moveString = [NSString stringWithFormat:@" %d - %d %d - %d ", [draggedFromTriangle pipNumber], inbetweenTrianglePipNum, inbetweenTrianglePipNum, [selectedTriangle pipNumber]];
				}
				else if (otherOwnedBY == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:otherPossablilityForInbetweenTriabgleArrayPos] numberOfChips] == 1){
					moveString = [NSString stringWithFormat:@" %d - %d %d - %d ", [draggedFromTriangle pipNumber], otherPossablilityForInbetweenTriabglePipNum, otherPossablilityForInbetweenTriabglePipNum, [selectedTriangle pipNumber]];
				}
				
				//try to find an empty chip for no forced bump
				if (ownedBY == OWNEDBY_PLAYER || ownedBY == OWNEDBY_NOONE){
					moveString = [NSString stringWithFormat:@" %d - %d %d - %d ", [draggedFromTriangle pipNumber], inbetweenTrianglePipNum, inbetweenTrianglePipNum, [selectedTriangle pipNumber]];
				}
				else if (otherOwnedBY == OWNEDBY_PLAYER || otherOwnedBY == OWNEDBY_NOONE){
					moveString = [NSString stringWithFormat:@" %d - %d %d - %d ", [draggedFromTriangle pipNumber], otherPossablilityForInbetweenTriabglePipNum, otherPossablilityForInbetweenTriabglePipNum, [selectedTriangle pipNumber]];
				}
				
				//Send it back from whence it came
				else {
					
					//[draggedFromTriangle addChip]; 
					//[draggedFromTriangle setOwnedBy:draggedChipOwnedBy];
					//return;
				}
				//Put inbetween chip on bar

				if (ownedBY == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:inbetweenTriangleArrayPos] numberOfChips] == 1 && otherOwnedBY == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:otherPossablilityForInbetweenTriabgleArrayPos] numberOfChips] == 1 && ![[theAGFIBSGameModel playerDice] isDoubleRoll]){
					[[[theAGFIBSGameModel gameBoard] objectAtIndex:inbetweenTriangleArrayPos] removeChip];
					[[theAGFIBSGameModel opponentBar] addChip];
					//[[[theAGFIBSGameModel gameBoard] objectAtIndex:otherPossablilityForInbetweenTriabgleArrayPos] removeChip];
				//	[[theAGFIBSGameModel opponentBar] addChip];
				}
				else if (ownedBY == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:inbetweenTriangleArrayPos] numberOfChips] > 1 && otherOwnedBY == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:otherPossablilityForInbetweenTriabgleArrayPos] numberOfChips] == 1 && ![[theAGFIBSGameModel playerDice] isDoubleRoll]){
					[[[theAGFIBSGameModel gameBoard] objectAtIndex:otherPossablilityForInbetweenTriabgleArrayPos] removeChip];
					[[theAGFIBSGameModel opponentBar] addChip];
				}
				else if (ownedBY == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:inbetweenTriangleArrayPos] numberOfChips] == 1 && otherOwnedBY == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:otherPossablilityForInbetweenTriabgleArrayPos] numberOfChips] > 1 && ![[theAGFIBSGameModel playerDice] isDoubleRoll]){
					[[[theAGFIBSGameModel gameBoard] objectAtIndex:inbetweenTriangleArrayPos] removeChip];
					[[theAGFIBSGameModel opponentBar] addChip];
				}
				
				
									
				else if ([[theAGFIBSGameModel playerDice] isDoubleRoll]	&& otherOwnedBY == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:otherPossablilityForInbetweenTriabgleArrayPos] numberOfChips] == 1){
					[[[theAGFIBSGameModel gameBoard] objectAtIndex:otherPossablilityForInbetweenTriabgleArrayPos] removeChip];
					[[theAGFIBSGameModel opponentBar] addChip];
				}
			}
		if (moveType == 3) {
			int firstInbetweenTrianglePipNum = 0;
			int secondInbetweenTrianglePipNum = 0;
			
			if (color == 1) {
				firstInbetweenTrianglePipNum = draggedFromTrianglePipNum - die1;
				secondInbetweenTrianglePipNum = draggedFromTrianglePipNum - (2 * die2);
			}
			else if (color == -1) {
				firstInbetweenTrianglePipNum = [draggedFromTriangle pipNumber] + die1;
				secondInbetweenTrianglePipNum = [draggedFromTriangle pipNumber] + (2 * die2);
			}
				int firstInbetweenTriangleArrayPos = [self pipNumToArrayPos:firstInbetweenTrianglePipNum];
				int secondInbetweenTriangleArrayPos = [self pipNumToArrayPos:secondInbetweenTrianglePipNum];
				
				int firstOwnedBy = [[[theAGFIBSGameModel gameBoard] objectAtIndex:firstInbetweenTriangleArrayPos] ownedBy];
				int secondOwnedBy = [[[theAGFIBSGameModel gameBoard] objectAtIndex:secondInbetweenTriangleArrayPos] ownedBy];
				
				if (firstOwnedBy == OWNEDBY_PLAYER || firstOwnedBy == OWNEDBY_NOONE || firstOwnedBy == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:firstInbetweenTriangleArrayPos] numberOfChips] == 1){
					if (secondOwnedBy == OWNEDBY_PLAYER || secondOwnedBy == OWNEDBY_NOONE || secondOwnedBy == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:secondInbetweenTriangleArrayPos] numberOfChips] == 1){
						moveString = [NSString stringWithFormat:@" %d - %d %d - %d %d - %d ", [draggedFromTriangle pipNumber], firstInbetweenTrianglePipNum, firstInbetweenTrianglePipNum, secondInbetweenTrianglePipNum, secondInbetweenTrianglePipNum, [selectedTriangle pipNumber]];
					}
				}
				//Send it back from whence it came
				else {
					[draggedFromTriangle addChip]; 
					[draggedFromTriangle setOwnedBy:draggedChipOwnedBy];
					return;
				}
				//Put inbetween chip on bar
				if (firstOwnedBy == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:firstInbetweenTriangleArrayPos] numberOfChips] == 1){
					[[[theAGFIBSGameModel gameBoard] objectAtIndex:firstInbetweenTriangleArrayPos] removeChip];
					[[theAGFIBSGameModel opponentBar] addChip];
				}
				if (secondOwnedBy == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:secondInbetweenTriangleArrayPos] numberOfChips] == 1){
					[[[theAGFIBSGameModel gameBoard] objectAtIndex:secondInbetweenTriangleArrayPos] removeChip];
					[[theAGFIBSGameModel opponentBar] addChip];
				}
		}
		if (moveType == 4) {
			int firstInbetweenTrianglePipNum = 0;
			int secondInbetweenTrianglePipNum = 0;
			int thirdInbetweenTrianglePipNum = 0;
			
			if (color == 1) {
				firstInbetweenTrianglePipNum = draggedFromTrianglePipNum - die1;
				secondInbetweenTrianglePipNum = draggedFromTrianglePipNum - (2 * die2);
				thirdInbetweenTrianglePipNum = draggedFromTrianglePipNum - (3 * die2);
			}
			else if (color == -1) {
				firstInbetweenTrianglePipNum = [draggedFromTriangle pipNumber] + die1;
				secondInbetweenTrianglePipNum = [draggedFromTriangle pipNumber] + (2 * die2);
				thirdInbetweenTrianglePipNum = [draggedFromTriangle pipNumber] + (3 * die2);
			}
				int firstInbetweenTriangleArrayPos = [self pipNumToArrayPos:firstInbetweenTrianglePipNum];
				int secondInbetweenTriangleArrayPos = [self pipNumToArrayPos:secondInbetweenTrianglePipNum];
				int thirdInbetweenTriangleArrayPos = [self pipNumToArrayPos:thirdInbetweenTrianglePipNum];
				
				int firstOwnedBy = [[[theAGFIBSGameModel gameBoard] objectAtIndex:firstInbetweenTriangleArrayPos] ownedBy];
				int secondOwnedBy = [[[theAGFIBSGameModel gameBoard] objectAtIndex:secondInbetweenTriangleArrayPos] ownedBy];
				int thirdOwnedBy = [[[theAGFIBSGameModel gameBoard] objectAtIndex:secondInbetweenTriangleArrayPos] ownedBy];
				
				if (firstOwnedBy == OWNEDBY_PLAYER || firstOwnedBy == OWNEDBY_NOONE || firstOwnedBy == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:firstInbetweenTriangleArrayPos] numberOfChips] == 1){
					if (secondOwnedBy == OWNEDBY_PLAYER || secondOwnedBy == OWNEDBY_NOONE || secondOwnedBy == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:secondInbetweenTriangleArrayPos] numberOfChips] == 1){
						if (thirdOwnedBy == OWNEDBY_PLAYER || thirdOwnedBy == OWNEDBY_NOONE || thirdOwnedBy == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:thirdInbetweenTriangleArrayPos] numberOfChips] == 1){
							moveString = [NSString stringWithFormat:@" %d - %d %d - %d %d - %d %d - %d ", [draggedFromTriangle pipNumber], firstInbetweenTrianglePipNum, firstInbetweenTrianglePipNum, secondInbetweenTrianglePipNum, secondInbetweenTrianglePipNum, thirdInbetweenTrianglePipNum, thirdInbetweenTrianglePipNum, [selectedTriangle pipNumber]];
						}
					}
				}
				//Send it back from whence it came
				else {
					[draggedFromTriangle addChip]; 
					[draggedFromTriangle setOwnedBy:draggedChipOwnedBy];
					return;
				}
				//Put inbetween chip on bar
				if (firstOwnedBy == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:firstInbetweenTriangleArrayPos] numberOfChips] == 1){
					[[[theAGFIBSGameModel gameBoard] objectAtIndex:firstInbetweenTriangleArrayPos] removeChip];
					[[theAGFIBSGameModel opponentBar] addChip];
				}
				if (secondOwnedBy == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:secondInbetweenTriangleArrayPos] numberOfChips] == 1){
					[[[theAGFIBSGameModel gameBoard] objectAtIndex:secondInbetweenTriangleArrayPos] removeChip];
					[[theAGFIBSGameModel opponentBar] addChip];
				}
				if (thirdOwnedBy == OWNEDBY_OPPONENT && [[[theAGFIBSGameModel gameBoard] objectAtIndex:thirdInbetweenTriangleArrayPos] numberOfChips] == 1){
					[[[theAGFIBSGameModel gameBoard] objectAtIndex:thirdInbetweenTriangleArrayPos] removeChip];
					[[theAGFIBSGameModel opponentBar] addChip];
				}
		}
		 
		
			
		NSMutableString *moveStringReplaceBar = [[NSMutableString alloc] init];
		[moveStringReplaceBar setString:moveString];
		[moveStringReplaceBar replaceOccurrencesOfString:@" 0 " withString:@" bar " options:NSLiteralSearch range:NSMakeRange(0, [moveStringReplaceBar length])];
		[moveStringReplaceBar replaceOccurrencesOfString:@" 25 " withString:@" home " options:NSLiteralSearch range:NSMakeRange(0, [moveStringReplaceBar length])];
		//NSLog(@"Move String: %2", moveStringReplaceBar);
		[[[theAGFIBSGameModel playerDice] playerMoves] addObject:moveStringReplaceBar];
		
		if ([selectedTriangle ownedBy] == OWNEDBY_OPPONENT && [selectedTriangle numberOfChips] == 1) {
			//NSLog(@"to bar");
			[selectedTriangle removeChip];
			[[theAGFIBSGameModel opponentBar] addChip];
		}
		
		[selectedTriangle addChip];
		[selectedTriangle setOwnedBy:draggedChipOwnedBy];
	
		if ([theAGFIBSGameModel isPlayerHome]) {
			if ([[theAGFIBSGameModel playerDice] isDoubleRoll]){
				[[theAGFIBSGameModel playerDice] useThisNumberOfDice:moveType];
			}
			else {
				[[theAGFIBSGameModel playerDice] useDie:distanceBetweenTriangles withGameModel:theAGFIBSGameModel];
			}
		}
		else {
			if ([draggedFromTriangle pipNumber] == 0 && color == 1)  {
				//distanceToUseUpDice = 25 - distanceToUseUpDice;
		}
			[[theAGFIBSGameModel playerDice] useDie:distanceBetweenTriangles withGameModel:theAGFIBSGameModel];
			
		}
		
		[nc postNotificationName:@"AGFIBSSPlaySoundFile" object:@"checkerMove0"];
		
		[self displayMoveString];
		
		
	}
	else {
		 //Send it back from whence it came
		 //NSLog(@"sent back");
		[draggedFromTriangle addChip]; 
		[draggedFromTriangle setOwnedBy:draggedChipOwnedBy];
	}
	

	
	
	
	[self setNeedsDisplay:YES];
	
}

-(void)displayMoveString
{
	
	NSEnumerator *e = [[[theAGFIBSGameModel playerDice] playerMoves] objectEnumerator];
	id obj;
	NSString *moveStringForPrint;
	int numberOfLegalMoves = [[[theAGFIBSGameModel fibsBoardStateDictionary] objectForKey:@"canMove"] intValue];
	int numberOfDiceUsed = [[theAGFIBSGameModel playerDice] numberOfDiceUsed];

	int movesLeft = numberOfLegalMoves - numberOfDiceUsed;
	if ([[theAGFIBSGameModel playerHome] numberOfChips] == 15) {
		movesLeft = 0;
	}
	
	if ([e nextObject] == nil) {
		if (movesLeft == 1) {
			moveStringForPrint = [NSString stringWithFormat:@"Please move 1 piece "];
		}
		else {
			moveStringForPrint = [NSString stringWithFormat:@"Please move %d pieces ",movesLeft];
		}
	}
	else {
		 moveStringForPrint = @"You have moved: ";
		 e = [[[theAGFIBSGameModel playerDice] playerMoves] objectEnumerator];
		 while (obj = [e nextObject]) {
			moveStringForPrint = [moveStringForPrint stringByAppendingFormat:@"%@ ",obj];
		}
		moveStringForPrint = [moveStringForPrint stringByAppendingFormat:@"(Moves left: %d)",movesLeft];
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:@"AGFIBSDisplaySystemMsg" object:moveStringForPrint];
}

-(void)undoMove
{
	int topObject = [undoDataStack count]-1;
	if (topObject >= 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AGFIBSDisplaySystemMsg" object:@"undo move"];
		

		[redoDataStack addObject:[NSKeyedArchiver archivedDataWithRootObject:theAGFIBSGameModel]];
		
		[self setTheAGFIBSGameModel:[NSKeyedUnarchiver unarchiveObjectWithData:[undoDataStack objectAtIndex:topObject]]];
		
		
		
		[undoDataStack removeObjectAtIndex:topObject];
		
		[self displayMoveString];
		[self setNeedsDisplay:YES];
	}
}

-(void)redoMove
{
	int topObject = [redoDataStack count]-1;
	if (topObject >= 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AGFIBSDisplaySystemMsg" object:@"redo move"];
		
		[undoDataStack addObject:[NSKeyedArchiver archivedDataWithRootObject:theAGFIBSGameModel]];
		
		[self setTheAGFIBSGameModel:[NSKeyedUnarchiver unarchiveObjectWithData:[redoDataStack objectAtIndex:topObject]]];
		
		
		
		[redoDataStack removeObjectAtIndex:topObject];
		
		[self displayMoveString];
		[self setNeedsDisplay:YES];
	}
}

-(void)clearUndoStack
{
	[undoDataStack release];
	undoDataStack = [[NSMutableArray alloc] initWithCapacity:1];
	[redoDataStack release];
	redoDataStack = [[NSMutableArray alloc] initWithCapacity:1];
}


	
	
-(BOOL)canMoveFromTriangle:(AGFIBSTriangle *)fromTriangle 
/*" Is it legal to remove a chip from this triangle? "*/
{
	if ([fromTriangle pipNumber] == HOME_PIP_NUMBER) {
		NSLog(@"Failed: can take chips out of home");
		return NO;
	}
	if (draggedChipOwnedBy != OWNEDBY_PLAYER) {
		NSLog(@"Failed: not owned by you");
		return NO;
	}
	else if ([[theAGFIBSGameModel playerBar] numberOfChips] > 0 && ![fromTriangle isEqual:[theAGFIBSGameModel playerBar]]) {
		NSLog(@"Failed: on bar");
		return NO;
	}
	else if ([[theAGFIBSGameModel playerDice] numberOfUnusedRolls] == 0) {
		NSLog(@"Failed: numberOfUnusedRolls");
		return NO;
	}
	else {
		return YES;
	}

	
}

-(BOOL)canMoveToTriangle:(AGFIBSTriangle *)toTriangle 
/*" Is it legal to move a chip to this triangle? "*/
{
	[theAGFIBSGameModel setDraggedToTriangle:toTriangle];
	int draggedFromTrianglePipNumber = [draggedFromTriangle pipNumber];
	int color = [theAGFIBSGameModel color];
	if (draggedFromTrianglePipNumber == 0 && color == 1) {
		draggedFromTrianglePipNumber = 25;
	}
	int distanceBetweenTriangles = abs([toTriangle pipNumber] - draggedFromTrianglePipNumber);
	
	if ([theAGFIBSGameModel isPlayerHome] && [toTriangle pipNumber] == HOME_PIP_NUMBER && [theAGFIBSGameModel direction] == DIRECTION_PIP24_TO_PIP1) {
		distanceBetweenTriangles = [draggedFromTriangle pipNumber];
	}
	int moveType = [[theAGFIBSGameModel playerDice] legalMoveType:distanceBetweenTriangles withGameModel:theAGFIBSGameModel];
	
	
	BOOL canMove = NO;
	if (![self canMoveFromTriangle:draggedFromTriangle]) {
		NSLog(@"Failed: canMoveFromTriangle");
		canMove = NO;
	}
	
	
	else if (color == 1 &&  [toTriangle pipNumber] >= [draggedFromTriangle pipNumber] && [toTriangle pipNumber] != HOME_PIP_NUMBER && [draggedFromTriangle pipNumber] != BAR_PIP_NUMBER) {
	NSLog(@"Backwards move");
		canMove =  NO;
	}
	else if (distanceBetweenTriangles > 6 && [[theAGFIBSGameModel playerBar] numberOfChips] >= 1 && isDragging) {
		canMove =  NO;
	}
	else if (distanceBetweenTriangles > 6 && [[theAGFIBSGameModel playerBar] numberOfChips] >= 2 && isDragging == NO) {
		canMove =  NO;
	}
	else if (color == -1 &&  [toTriangle pipNumber] <= [draggedFromTriangle pipNumber]) {
		NSLog(@"Backwards move");
		canMove =  NO;
	}
	else if (![theAGFIBSGameModel isPlayerHome] &&  [toTriangle pipNumber] == HOME_PIP_NUMBER) {
		NSLog(@"Failed: not home yet");
		canMove =  NO;
	}
	/* else if ([draggedFromTriangle pipNumber] > [toTriangle pipNumber]) {
		NSLog(@"Failed: draggedFromTriangle pipNumber] > [toTriangle pipNumber]");
		canMove =  NO;
	} 
	*/
	else if ([toTriangle ownedBy] == OWNEDBY_OPPONENT && [toTriangle numberOfChips] > 1) {
		NSLog(@"Failed: [toTriangle ownedBy] == OWNEDBY_OPPONENT && [toTriangle numberOfChips] > 1");
		canMove =  NO;
	}
	//else if ([draggedFromTriangle pipNumber] == 0 && color == 1 && ![[theAGFIBSGameModel playerDice] legalMoveType:(25 - distanceBetweenTriangles) withGameModel:theAGFIBSGameModel]) {
	else if ([draggedFromTriangle pipNumber] == 0 && color == 1 && ![[theAGFIBSGameModel playerDice] legalMoveType:distanceBetweenTriangles withGameModel:theAGFIBSGameModel]) {
			//NSLog(@"Failed: llegalMoveType distanceBetweenTriangles %d legalMoveType %d ",distanceBetweenTriangles, [[theAGFIBSGameModel playerDice] legalMoveType:distanceBetweenTriangles barringOff:[theAGFIBSGameModel isPlayerHome]]);
			canMove =  NO;
	}
	else if ([draggedFromTriangle pipNumber] == 0 && color == -1 && ![[theAGFIBSGameModel playerDice] legalMoveType:distanceBetweenTriangles withGameModel:theAGFIBSGameModel]) {
		canMove =  NO;
	}
	else if ([draggedFromTriangle pipNumber] > 0 && ![[theAGFIBSGameModel playerDice] legalMoveType:distanceBetweenTriangles withGameModel:theAGFIBSGameModel]) {
			//NSLog(@"Failed: llegalMoveType distanceBetweenTriangles %d legalMoveType %d ",distanceBetweenTriangles, [[theAGFIBSGameModel playerDice] legalMoveType:distanceBetweenTriangles barringOff:[theAGFIBSGameModel isPlayerHome]]);
			canMove =  NO;
	}
	else if (![[theAGFIBSGameModel playerDice] isDoubleRoll] && moveType == 2) {
		int roll1 = [[theAGFIBSGameModel playerDice] valueOfDie:0];
		int roll2 = [[theAGFIBSGameModel playerDice] valueOfDie:1];
		int pip = [draggedFromTriangle pipNumber];
		
		int inbetweenJump1PipNum = 0;
		int inbetweenJump2PipNum = 0;
		
		if (color == -1) {
			inbetweenJump1PipNum =  pip + roll1;
			inbetweenJump2PipNum =  pip + roll2;
		}
		else if (color == 1) {
			inbetweenJump1PipNum =  pip - roll1;
			inbetweenJump2PipNum =  pip - roll2;
		}
		if ([draggedFromTriangle pipNumber] == BAR_PIP_NUMBER) {
			//inbetweenJump1PipNum++;
			//inbetweenJump2PipNum++;
		}
				
		inbetweenJump1PipNum = abs(inbetweenJump1PipNum);
		inbetweenJump2PipNum = abs(inbetweenJump2PipNum);
		
		
		
		
		AGFIBSTriangle *inbetweenStepTriangle1 = [[theAGFIBSGameModel gameBoard] objectAtIndex:[self pipNumToArrayPos:inbetweenJump1PipNum]];
		AGFIBSTriangle *inbetweenStepTriangle2 = [[theAGFIBSGameModel gameBoard] objectAtIndex:[self pipNumToArrayPos:inbetweenJump2PipNum]];
		if ([inbetweenStepTriangle1 ownedBy] == OWNEDBY_OPPONENT && [inbetweenStepTriangle1 numberOfChips] > 1 && [inbetweenStepTriangle2 ownedBy] == OWNEDBY_OPPONENT && [inbetweenStepTriangle2 numberOfChips] > 1) {
			canMove =  NO;
			NSLog(@"Both owned by 2");
		}

		else if ([inbetweenStepTriangle1 ownedBy] == OWNEDBY_OPPONENT && [inbetweenStepTriangle1 numberOfChips] == 1 && [inbetweenStepTriangle2 ownedBy] == OWNEDBY_OPPONENT && [inbetweenStepTriangle2 numberOfChips] == 1) {
			distanceToUseUpDice = distanceBetweenTriangles;
			canMove =  YES;
		}
		else {
			distanceToUseUpDice = distanceBetweenTriangles;
			canMove =  YES;
			NSLog(@"yes2");
		}
	}
	else if ([[theAGFIBSGameModel playerDice] isDoubleRoll] && moveType > 1) {
		int roll =  [[theAGFIBSGameModel playerDice] valueOfDie:0];
		int pip = draggedFromTrianglePipNumber;
		int inbetweenJumpPipNum = 0;
		
		int i;
		if ([theAGFIBSGameModel color] == -1) {
			inbetweenJumpPipNum =  pip +  roll;
			//if ([draggedFromTriangle pipNumber] == BAR_PIP_NUMBER)
				//inbetweenJumpPipNum++;
		}
		else if ([theAGFIBSGameModel color] == 1) {
			inbetweenJumpPipNum =  pip -  roll;
			//if ([draggedFromTriangle pipNumber] == BAR_PIP_NUMBER)
				//inbetweenJumpPipNum++;
		}
		inbetweenJumpPipNum = abs(inbetweenJumpPipNum);
		for (i = 0; i < moveType-1; i++) {
			AGFIBSTriangle *inbetweenStepTriangle = [[theAGFIBSGameModel gameBoard] objectAtIndex:[self pipNumToArrayPos:inbetweenJumpPipNum]];
			if ([inbetweenStepTriangle ownedBy] == OWNEDBY_OPPONENT && [inbetweenStepTriangle numberOfChips] > 1) {
				canMove =  NO;
				break;
				NSLog(@"[inbetweenStepTriangle ownedBy] == OWNEDBY_OPPONENT && [inbetweenStepTriangle numberOfChips] > 1");
			}
			else if (i > 0 && [[theAGFIBSGameModel playerBar] numberOfChips] >= 1 && isDragging) {
				canMove =  NO;
				break;
				NSLog(@"Still have a chip on the bar");
			}
			else if (i > 0 && [[theAGFIBSGameModel playerBar] numberOfChips] >= 2 && isDragging == NO) {
				canMove =  NO;
				break;
				NSLog(@"Still have a chip on the bar");
			}
			else {
				distanceToUseUpDice = distanceBetweenTriangles;
				canMove =  YES;
			}
			/* else if ([inbetweenStepTriangle ownedBy] == OWNEDBY_OPPONENT && [inbetweenStepTriangle numberOfChips] == 1) {
				[[theAGFIBSGameModel opponentBar] addChip];
				[inbetweenStepTriangle removeChip];
			}*/
			pip = [inbetweenStepTriangle pipNumber];
			if ([theAGFIBSGameModel color] == -1) {
				inbetweenJumpPipNum =  pip +  roll;
			}
			else if ([theAGFIBSGameModel color] == 1) {
				inbetweenJumpPipNum =  pip -  roll;
			}
		}
		//distanceToUseUpDice = distanceBetweenTriangles;
		//canMove =  YES;
	}
	else if ([toTriangle pipNumber] == BAR_PIP_NUMBER) {
		canMove =  NO;
	}
	else if ([toTriangle ownedBy] == OWNEDBY_OPPONENT && [toTriangle numberOfChips] == 1) {
		canMove =  YES;
	}
	else {
		distanceToUseUpDice = distanceBetweenTriangles;
		canMove =  YES;
	}

	NSLog(@"can move %d", canMove);
	return canMove;
}

-(void)checkForInbetweenMoveBumps 
{
/*" 

	if ([toTriangle ownedBy] == OWNEDBY_OPPONENT && [toTriangle numberOfChips] == 1) {
		distanceToUseUpDice = distanceBetweenTriangles;
		[[theAGFIBSGameModel opponentBar] addChip];
		[toTriangle removeChip];
		canMove =  YES;
	}
	else if ([inbetweenStepTriangle1 ownedBy] == OWNEDBY_OPPONENT && [inbetweenStepTriangle1 numberOfChips] == 1 && [inbetweenStepTriangle2 ownedBy] == OWNEDBY_OPPONENT && [inbetweenStepTriangle2 numberOfChips] == 1) {
			[[theAGFIBSGameModel opponentBar] addChip];
			//[[theAGFIBSGameModel opponentBar] addChip];
			[inbetweenStepTriangle1 removeChip];
			//[inbetweenStepTriangle2 removeChip];
			distanceToUseUpDice = distanceBetweenTriangles;
			[self setNeedsDisplay:YES];
			canMove =  YES;
		}
		"*/
}

//=========================================================== 
//  theAGFIBSGameModel 
//=========================================================== 
- (AGFIBSGameModel *)theAGFIBSGameModel { return [[theAGFIBSGameModel retain] autorelease]; }
- (void)setTheAGFIBSGameModel:(AGFIBSGameModel *)newTheAGFIBSGameModel
{
    if (theAGFIBSGameModel != newTheAGFIBSGameModel) {
        //[theAGFIBSGameModel release]; BUG?
        theAGFIBSGameModel = [newTheAGFIBSGameModel retain];
    }
}

//=========================================================== 
//  undoData 
//=========================================================== 
- (NSData *)undoData { return [[undoData retain] autorelease]; }
- (void)setUndoData:(NSData *)newUndoData
{
    if (undoData != newUndoData) {
        [undoData release];
        undoData = [newUndoData retain];
    }
}


-(int)pipNumToArrayPos:(int)pipPos 
/*" Get pip number of triangle from its position in the array. "*/
{
	if ([theAGFIBSGameModel direction] == DIRECTION_PIP1_TO_PIP24) {
		return (pipPos - 1);
	}
	else /* if ([theAGFIBSGameModel direction] == DIRECTION_PIP24_TO_PIP1) */ {
		return (abs(NUMBER_OF_TRIANGLES - pipPos));
	}
}



@end
