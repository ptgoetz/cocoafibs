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


#import <Foundation/Foundation.h>
@class AGFIBSTriangle;
@class AGFIBSGameModel;

@interface AGFIBSDice : NSObject <NSCoding> {
	int playersDice[4];				/*" The player's dice "*/
	NSMutableArray *playerMoves;	/*" Which moves have been made by the player "*/
	BOOL hasThisRollBeenUsed[4];	/*" Which dice have been used "*/
}

/*" Designated Initializer "*/
- (id)initWithDie:(int)die0 otherDie:(int)die1;

/*" Overridden Initializer "*/
- (id)init;

/*" Dice Methods "*/
- (void)useDie:(int)distanceMovied withGameModel:(AGFIBSGameModel *)theAGFIBSGameModel;
- (void)useThisNumberOfDice:(int)num;
- (void)swapDice;
- (int)numberOfUnusedRolls;
- (BOOL)isDoubleRoll;
- (int)valueOfDie:(int)dieNumber;
- (NSMutableArray *)playerMoves;
- (int)numberOfDiceUsed;
- (void)setPlayerMoves:(NSMutableArray *)newPlayerMoves;
- (int)legalMoveType:(int)distanceMoved withGameModel:(AGFIBSGameModel *)theAGFIBSGameModel;

/*" Move Methods "*/
- (int)legalMoveType:(int)distanceMoved withGameModel:(AGFIBSGameModel *)theAGFIBSGameModel;

/*" Clean Up "*/
- (void)dealloc;





@end
