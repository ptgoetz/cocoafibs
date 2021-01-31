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


#import "AGFIBSDice.h"
#import "AGFIBSTriangle.h"
#import "AGFIBSGameModel.h"

#define HOME_PIP_NUMBER 25		/*" Pip number assigned to the players OFFHOME "*/

@implementation AGFIBSDice
/*"  
Instances of this class encapsulate the dice and moves of a player for a specific turn. This is a model class that represent 2 six-sided dice and between 0 - 4 player moves. The reason that we can store up to 4 values is because in backgammon a roll of doubles such as 5-5 gives you four moves of 5. When the server returns the values for dice they are put into the playersDice array. For all corresponding die positions hasThisRollBeenUsed is set to NO. As a player uses dies the values with the same array position are set to YES. As a player makes moves they are pushed onto the playerMoves array. 
"*/

- (id)initWithDie:(int)die0 otherDie:(int)die1
/*" Designated initializer: Initializes the receiver with the specified dice."*/
{
	self = [super init];
	//Not double roll
	if (die0 != die1){
		playersDice[0] = die0;
		playersDice[1] = die1;
		hasThisRollBeenUsed[0] = NO;
		hasThisRollBeenUsed[1] = NO;
		hasThisRollBeenUsed[2] = YES;
		hasThisRollBeenUsed[3] = YES;
		playerMoves = [[NSMutableArray alloc] initWithCapacity:2];
	}
	//Double roll
	else {
		playersDice[0] = die0;
		playersDice[1] = die0;
		playersDice[2] = die0;
		playersDice[3] = die0;
		hasThisRollBeenUsed[2] = NO;
		hasThisRollBeenUsed[3] = NO;
		playerMoves = [[NSMutableArray alloc] initWithCapacity:4];
	}
	return self;
}

- (id)init 
/*" Overridden Initializer "*/
{
	return [self initWithDie:0 otherDie:0];	
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [coder encodeInt:playersDice[0] forKey:@"nonePlayersDice0"];
	[coder encodeInt:playersDice[1] forKey:@"nonePlayersDice1"];
	[coder encodeInt:playersDice[2] forKey:@"nonePlayersDice2"];
	[coder encodeInt:playersDice[3] forKey:@"nonePlayersDice3"];
    [coder encodeObject:[self playerMoves] forKey:@"nonePlayerMoves"];
    [coder encodeBool:hasThisRollBeenUsed[0] forKey:@"noneHasThisRollBeenUsed0"];
	[coder encodeBool:hasThisRollBeenUsed[1] forKey:@"noneHasThisRollBeenUsed1"];
	[coder encodeBool:hasThisRollBeenUsed[2] forKey:@"noneHasThisRollBeenUsed2"];
	[coder encodeBool:hasThisRollBeenUsed[3] forKey:@"noneHasThisRollBeenUsed3"];
}

- (id)initWithCoder:(NSCoder *)coder 
{
    [super init];
        playersDice[0] = [coder decodeIntForKey:@"nonePlayersDice0"];
		playersDice[1] = [coder decodeIntForKey:@"nonePlayersDice1"];
		playersDice[2] = [coder decodeIntForKey:@"nonePlayersDice2"];
		playersDice[3] = [coder decodeIntForKey:@"nonePlayersDice3"];
        [self setPlayerMoves:[coder decodeObjectForKey:@"nonePlayerMoves"]];
        hasThisRollBeenUsed[0] = [coder decodeBoolForKey:@"noneHasThisRollBeenUsed0"];
		hasThisRollBeenUsed[1] = [coder decodeBoolForKey:@"noneHasThisRollBeenUsed1"];
		hasThisRollBeenUsed[2] = [coder decodeBoolForKey:@"noneHasThisRollBeenUsed2"];
		hasThisRollBeenUsed[3] = [coder decodeBoolForKey:@"noneHasThisRollBeenUsed3"];

    
    return self;
}

- (int)legalMoveType:(int)distanceMoved withGameModel:(AGFIBSGameModel *)theAGFIBSGameModel 
/*" Determines if the distance the player has moved is a legal move and how many dice it consumes. Pass in a game model object and a distance moved. Return the number of dice used by a move"*/
{
	int i,j;
	int numberOfUnusedRolls;
	distanceMoved = abs(distanceMoved);
	//Check for single die move
	BOOL barringOff = [theAGFIBSGameModel isPlayerHome];
	int clearTrianglesInHomeForBareoff = [theAGFIBSGameModel clearTrianglesInHomeForBareoff];
	for (i = 0; i < 4; i++) {
		if (!hasThisRollBeenUsed[i] && playersDice[i] == distanceMoved) {
			return 1;
		}
		else if (barringOff && !hasThisRollBeenUsed[i] && playersDice[i] > clearTrianglesInHomeForBareoff &&  playersDice[i] >= distanceMoved && distanceMoved >= clearTrianglesInHomeForBareoff && [[theAGFIBSGameModel draggedToTriangle] pipNumber] == HOME_PIP_NUMBER) {
			return 1;
		}
	}
	//Check for two-die move
	if (!hasThisRollBeenUsed[0] && !hasThisRollBeenUsed[1] && (playersDice[0] + playersDice[1]) == distanceMoved) {
		return 2;
	}
	else if (barringOff && distanceMoved != clearTrianglesInHomeForBareoff && !hasThisRollBeenUsed[0] && !hasThisRollBeenUsed[1] && (playersDice[0] + playersDice[1]) >= distanceMoved && distanceMoved >= clearTrianglesInHomeForBareoff && !(clearTrianglesInHomeForBareoff == 6 && distanceMoved > 6) && [[theAGFIBSGameModel draggedToTriangle] pipNumber] == HOME_PIP_NUMBER) {
		return 2;
	}
	//Check for 2 or more of a double roll move
	numberOfUnusedRolls = [self numberOfUnusedRolls];
	for (j = numberOfUnusedRolls; j > 0; j--) {
		if ((playersDice[0] * j) == distanceMoved  && [self isDoubleRoll]) {
			return j;
		}
		else if (barringOff && (playersDice[0] * j) >= distanceMoved  && [self isDoubleRoll] && distanceMoved >= clearTrianglesInHomeForBareoff && distanceMoved <= 6) {
			if ([[theAGFIBSGameModel draggedToTriangle] pipNumber] != HOME_PIP_NUMBER || clearTrianglesInHomeForBareoff == distanceMoved && playersDice[0] < distanceMoved && playersDice[0] < clearTrianglesInHomeForBareoff)
				return 0;
			else
				return j;
		}
	}
	return 0;
}


- (void)useDie:(int)distanceMovied withGameModel:(AGFIBSGameModel *)theAGFIBSGameModel
/*" Marks the dice as used "*/
{
	int i;
	distanceMovied = abs(distanceMovied);
	BOOL barringOff = [theAGFIBSGameModel isPlayerHome];
	int clearTrianglesInHomeForBareoff = [theAGFIBSGameModel clearTrianglesInHomeForBareoff];
	for (i = 0; i < 4; i++) {
	//	if (playersDice[i] == distanceMovied && !hasThisRollBeenUsed[i] || barringOff && clearTrianglesInHomeForBareoff == draggedFromTrianglePipNumber && clearTrianglesInHomeForBareoff >= distanceMovied && playersDice[i] >= distanceMovied && !hasThisRollBeenUsed[i] ) {
		
			if (playersDice[i] == distanceMovied && !hasThisRollBeenUsed[i] || barringOff &&  distanceMovied >=  clearTrianglesInHomeForBareoff && playersDice[i] >= distanceMovied && !hasThisRollBeenUsed[i] ) {
			hasThisRollBeenUsed[i] = YES;
			NSLog(@"roll used %d  Dice left %d", playersDice[i], [self numberOfUnusedRolls]);
			return;
		}
	}
	if ((playersDice[0] +  playersDice[1]) == distanceMovied && ![self isDoubleRoll]) {
		hasThisRollBeenUsed[0] = YES;
		hasThisRollBeenUsed[1] = YES;
	}
	else if (barringOff && clearTrianglesInHomeForBareoff >= distanceMovied && (playersDice[0] +  playersDice[1]) >= distanceMovied && ![self isDoubleRoll]) {
		hasThisRollBeenUsed[0] = YES;
		hasThisRollBeenUsed[1] = YES;
	}
	else if ((playersDice[0] * 2) == distanceMovied && [self isDoubleRoll] || barringOff && clearTrianglesInHomeForBareoff >= distanceMovied && (playersDice[0] * 2) >= distanceMovied) {
		[self useThisNumberOfDice:2];
	}
	else if ((playersDice[0] * 3) == distanceMovied && [self isDoubleRoll] || barringOff && clearTrianglesInHomeForBareoff >= distanceMovied && (playersDice[0] * 3) >= distanceMovied) {
		[self useThisNumberOfDice:3];
	}
	else if ((playersDice[0] * 4) == distanceMovied && [self isDoubleRoll] || barringOff && clearTrianglesInHomeForBareoff >= distanceMovied && (playersDice[0] * 4) >= distanceMovied) {
		[self useThisNumberOfDice:4];
	}
	NSLog(@"dDice left %d", [self numberOfUnusedRolls]);
	//[theGameController displaySystemMsg:aMessage withTime:YES];
}


- (void)useThisNumberOfDice:(int)num 
/*" Marks a number of unused dice as used "*/
{
	int i;
	while (num > 0) {
		for (i = 0; i < 4; i++) {
			if (!hasThisRollBeenUsed[i]) {
				hasThisRollBeenUsed[i] = YES;
				break;
			}
		}
		num--;
	}
	NSLog(@"Dice left %d", [self numberOfUnusedRolls]);
}

- (int)numberOfUnusedRolls
/*" Returns how many unused dice remain "*/
{
	int countRemainingRolls;
	int j;
	if ([self isDoubleRoll]) {
		countRemainingRolls = 4;
		j = 4;
	}
	else {
		countRemainingRolls = 2;
		j = 2;
	}
	int i;
		for (i = 0; i < j; i++) {
			if (hasThisRollBeenUsed[i]) {
				countRemainingRolls--;
			}
		}
		//NSLog(@"Remaining rolls - %d", countRemainingRolls);
		return countRemainingRolls;
}

- (int)numberOfDiceUsed
/*" Returns how many dice were used "*/
{
	int countOfDiceUsed = 0;
	int i;
	int numberOfTotalDice;
	if ([self isDoubleRoll]) {
		numberOfTotalDice = 4;
	}
	else {
		numberOfTotalDice = 2;
	}
	for (i = 0; i < numberOfTotalDice; i++) {
		if (hasThisRollBeenUsed[i]) {
			countOfDiceUsed++;
		}
	}
	return countOfDiceUsed;
}

- (void)swapDice
{
	int tempDieValue = playersDice[0];
	playersDice[0] = playersDice[1];
	playersDice[1] = tempDieValue;
	
	int tempDieHasBeenUsedValue = hasThisRollBeenUsed[0];
	hasThisRollBeenUsed[0] = hasThisRollBeenUsed[1];
	hasThisRollBeenUsed[1] = tempDieHasBeenUsedValue;
}

- (BOOL)isDoubleRoll
/*" Is this roll a double? "*/
{
	if (playersDice[0] == playersDice[1]) {
		return YES;
	}
	return NO;
}

- (int)valueOfDie:(int)dieNumber 
/*" Returns the value of a specific die number "*/
{
    return playersDice[dieNumber];
}

//=========================================================== 
//  playerMoves 
//=========================================================== 
- (NSMutableArray *)playerMoves { return [[playerMoves retain] autorelease]; }
- (void)setPlayerMoves:(NSMutableArray *)newPlayerMoves
{
    if (playerMoves != newPlayerMoves) {
        [playerMoves release];
        playerMoves = [newPlayerMoves retain];
    }
}

- (void)dealloc
/*" Clean Up "*/
{
	[super dealloc];
}


@end
