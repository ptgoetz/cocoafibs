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


#import "AGFIBSGameModel.h"
#import "AGFIBSGameView.h"
#import "AGFIBSTriangle.h"
#import "AGFIBSDice.h"

/*" Model Constants "*/
#define NUMBER_OF_TRIANGLES 24		/*" Standard number of triangles in a game of backgammon "*/
#define BAR_PIP_NUMBER 0			/*" Pip number assigned to the players BAR "*/
#define HOME_PIP_NUMBER 25			/*" Pip number assigned to the players OFFHOME "*/
#define DIRECTION_PIP24_TO_PIP1 -1	/*"  "*/
#define DIRECTION_PIP1_TO_PIP24 1	/*"  "*/

@implementation AGFIBSGameModel
/*"  
Instances of this class encapsulate the game board. This is a model class that represents 24 triangles, 2 bar positions, 2 homes, 2 sets of dice. These values are initialized for a new game. Then when the server returns a FIBS_Board state that values are tokenized into an NSDictionary and then assigned to the instance variables that make up this model. This class contains accessor methods for the various board items as well as methods for determining information about the current state of the board.
"*/

- (id)init {
/*" Designated Initializer "*/
	self = [super init];
	gameBoard  = [[NSMutableArray alloc] initWithCapacity:24];
	return self;
}
- (id)copyWithZone:(NSZone *)zone {
	AGFIBSGameModel *copy = [[AGFIBSGameModel alloc] init];
	[copy setGameBoard:[gameBoard mutableCopy]];
	//[copy newGame];
	return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder 
{

    [coder encodeObject:[self gameBoard] forKey:@"noneGameBoard"];
    [coder encodeObject:[self playerDice] forKey:@"nonePlayerDice"];
    [coder encodeObject:[self opponentDice] forKey:@"noneOpponentDice"];
    [coder encodeObject:[self playerDiceFromLastTurn] forKey:@"nonePlayerDiceFromLastTurn"];
    [coder encodeObject:[self opponentDiceFromLastTurn] forKey:@"noneOpponentDiceFromLastTurn"];
    [coder encodeObject:[self playerBar] forKey:@"nonePlayerBar"];
    [coder encodeObject:[self opponentBar] forKey:@"noneOpponentBar"];
    [coder encodeObject:[self playerHome] forKey:@"nonePlayerHome"];
    [coder encodeInt:[self opponentHome] forKey:@"noneOpponentHome"];
    [coder encodeInt:[self theCube] forKey:@"noneTheCube"];
    [coder encodeObject:[self playerName] forKey:@"nonePlayerName"];
    [coder encodeObject:[self opponentName] forKey:@"noneOpponentName"];
    [coder encodeInt:color forKey:@"noneColor"];
    [coder encodeObject:[self draggedFromTriangle] forKey:@"noneDraggedFromTriangle"];
    [coder encodeObject:[self draggedToTriangle] forKey:@"noneDraggedToTriangle"];
    [coder encodeObject:[self fibsBoardStateDictionary] forKey:@"noneFibsBoardStateDictionary"];
    [coder encodeInt:[self direction] forKey:@"noneDirection"];
}

- (id)initWithCoder:(NSCoder *)coder 
{
  
   AGFIBSGameModel *copy = [[AGFIBSGameModel alloc] init];     
        [copy setPlayerDice:[coder decodeObjectForKey:@"nonePlayerDice"]];
        [copy setOpponentDice:[coder decodeObjectForKey:@"noneOpponentDice"]];
        [copy setPlayerDiceFromLastTurn:[coder decodeObjectForKey:@"nonePlayerDiceFromLastTurn"]];
        [copy setOpponentDiceFromLastTurn:[coder decodeObjectForKey:@"noneOpponentDiceFromLastTurn"]];
        [copy setPlayerBar:[coder decodeObjectForKey:@"nonePlayerBar"]];
        [copy setOpponentBar:[coder decodeObjectForKey:@"noneOpponentBar"]];
        [copy setPlayerHome:[coder decodeObjectForKey:@"nonePlayerHome"]];
        [copy setOpponentHome:[coder decodeIntForKey:@"noneOpponentHome"]];
        [copy setTheCube:[coder decodeIntForKey:@"noneTheCube"]];
        [copy setPlayerName:[coder decodeObjectForKey:@"nonePlayerName"]];
        [copy setOpponentName:[coder decodeObjectForKey:@"noneOpponentName"]];
        [copy setColor:[coder decodeIntForKey:@"noneColor"]];
        [copy setDraggedFromTriangle:[coder decodeObjectForKey:@"noneDraggedFromTriangle"]];
        [copy setDraggedToTriangle:[coder decodeObjectForKey:@"noneDraggedToTriangle"]];
        [copy setFibsBoardStateDictionary:[coder decodeObjectForKey:@"noneFibsBoardStateDictionary"]];
        [copy setDirection:[coder decodeIntForKey:@"noneDirection"]];
		[copy setGameBoard:[coder decodeObjectForKey:@"noneGameBoard"]];
    
    return copy;
}
- (void)invertGameBoardArray {
/*" "*/
	NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:24];
	int j = [gameBoard count]-1;
	int i;
	for (i = 0; i < [gameBoard count]; i++) {
		[temp insertObject:[gameBoard objectAtIndex:j] atIndex:i];
		j--;
	}
	[self setGameBoard:temp];
	[temp release];
}

- (void)newGame {
/*" Sets up a new game from scratch "*/
	int ownedBySetup[24] =			{1,0,0,0,0,2,0,2,0,0,0,1,2,0,0,0,1,0,1,0,0,0,0,2};
	int numberOfChipsSetup[24] =	{2,0,0,0,0,5,0,3,0,0,0,5,5,0,0,0,3,0,5,0,0,0,0,2};
	
	color = 1;
	
	playerDice = [[AGFIBSDice alloc] initWithDie:0 otherDie:0];
	opponentDice = [[AGFIBSDice alloc] initWithDie:0 otherDie:0];
	
	playerDiceFromLastTurn = [[AGFIBSDice alloc] initWithDie:6 otherDie:6];
	opponentDiceFromLastTurn = [[AGFIBSDice alloc] initWithDie:5 otherDie:6];
	
	playerBar = [[AGFIBSTriangle alloc] initWithOwnedBy:1 numberOfChips:0 pipNumber:BAR_PIP_NUMBER];
	opponentBar = [[AGFIBSTriangle alloc] initWithOwnedBy:2 numberOfChips:0 pipNumber:BAR_PIP_NUMBER];
	playerHome = [[AGFIBSTriangle alloc] initWithOwnedBy:1 numberOfChips:0 pipNumber:HOME_PIP_NUMBER];
	opponentHome = 0;
	int i,j;
	j = NUMBER_OF_TRIANGLES;
	for (i = 0; i < NUMBER_OF_TRIANGLES; i++) {		
		AGFIBSTriangle *aTriangle = [[AGFIBSTriangle alloc] initWithOwnedBy:ownedBySetup[i] numberOfChips:numberOfChipsSetup[i] pipNumber:j];
		[gameBoard insertObject:aTriangle atIndex:i];
		[aTriangle release];
		[self setGameBoard:gameBoard];
		j--;
	}
	
	//Ready to bare off
	//NSString *tempBoard = @"board:ParlorBot:mrklaw:15:12:2:0:1:0:-1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:-1:-1:-2:-3:-7:0:1:2:3:0:0:2:1:0:0:1:-1:0:25:14:0:0:0:2:3:0:0";
	
	//Normal move
	//NSString *tempBoard =   @"board:You:ain:3:0:0:0:-2:1:0:0:0:5:0:3:0:0:0:-5:5:0:0:0:-3:0:-5:0:0:0:-1:2:0:1:1:1:0:0:1:1:1:0:1:-1:0:25:0:0:0:0:2:0:0:0";

	//on bar
	//NSString *tempBoard = @"board:You:ain:3:0:0:0:-2:0:1:0:0:5:0:2:0:0:0:-3:5:0:0:0:-4:-1:-5:0:0:0:0:1:1:1:5:5:1:2:1:1:1:0:1:-1:0:25:0:0:1:0:2:0:0:0";
	
//

//Bug from bot 
	//NSString *tempBoard = @"board:You:jigsaw:3:0:0:0:3:0:0:0:0:0:-2:0:0:0:0:0:-1:0:0:0:0:-1:-4:-3:-2:-2:0:0:0:-1:0:0:0:0:2:0:1:0:1:-1:0:25:12:0:0:0:2:6:0:0";
//nasty bareoff bug 
//NSString *tempBoard = @"board:You:sponi:5:0:2:0:2:2:1:2:2:3:0:0:1:0:0:0:0:0:0:0:0:-2:-2:0:-5:2:-4:-2:0:-1:6:3:0:0:2:0:1:0:-1:1:25:0:0:0:0:0:2:0:0:0";
	
	//matias
	//NSString *tempBoard = @"board:You:koltes:7:4:4:-1:0:2:0:0:0:1:1:3:1:0:0:-3:1:0:-2:0:-3:2:-2:0:-2:-2:0:0:0:-1:3:3:0:0:1:1:1:0:-1:1:25:0:0:0:1:0:4:3:0:0";

	//Start Game
	NSString *tempBoard = @"board:You:someplayer:3:0:0:0:-2:0:0:0:0:5:0:3:0:0:0:-5:5:0:0:0:-3:0:-5:0:0:0:0:2:0:1:0:0:0:0:1:1:1:0:1:-1:0:25:0:0:0:0:2:0:0:0";
	

	//
	//line um up



	NSArray *fibsBoardStateKeys = [@"board player opponent matchLength playerScore opponentScore playerBar tri1 tri2 tri3 tri4 tri5 tri6 tri7 tri8 tri9 tri10 tri11 tri12 tri13 tri14 tri15 tri16 tri17 tri18 tri19 tri20 tri21 tri22 tri23 tri24 opponentBar turn playerDie1 playerDie2 opponentDie1 opponentDie2 doubleCube playerMayDouble opponentMayDouble wasDoubled color direction home bar playerHomeNum opponentHomeNum playerBarNum opponentBarNum canMove forcedMove didCrawford redoubles" componentsSeparatedByString:@" "];
	NSArray *fibsBoardStateMessage = [tempBoard componentsSeparatedByString:@":"];
	NSDictionary *lfibsBoardStateDictionary = [[NSDictionary alloc] initWithObjects:fibsBoardStateMessage forKeys:fibsBoardStateKeys];
	

	
	[self setFibsBoardStateDictionary:lfibsBoardStateDictionary];
	
	[self updateModelFromFIBS_Board];
		
}




- (BOOL)isWatching {
	if ([[fibsBoardStateDictionary objectForKey:@"player"] isEqualToString:@"You"]) {
		return NO;
	}
	return YES;
}

- (void)updateModelFromFIBS_Board 
/*" Updates the model's instance variables from a new FIBS_Board state returned from the server "*/
{
/*
	NSDate *now = [NSDate date];
	NSString *nowAsFormattedString = [[NSDate date] descriptionWithCalendarFormat:@"%m%d%Y" timeZone:nil locale:nil];
	NSString *fileName = [NSString stringWithFormat:@"oldmoves/%@_vs_%@_%@", [fibsBoardStateDictionary objectForKey:@"player"],[fibsBoardStateDictionary objectForKey:@"opponent"],nowAsFormattedString];
	NSString *fileContents = [NSString stringWithContentsOfFile:fileName];
	NSString *newFileContents = [NSString stringWithFormat:@" %@ %@ %@ ", fileContents, @"\n", [fibsBoardStateDictionary description]];
	[newFileContents writeToFile:fileName atomically:YES];
	
	*/
	
	//NSLog([fibsBoardStateDictionary description]);
	NSArray *fibsBoardStateTriangleKeys = nil;
	[self setDirection:[[fibsBoardStateDictionary objectForKey:@"direction"] intValue]];
	
	//Handle the direction preference
	if (direction == DIRECTION_PIP1_TO_PIP24) {
		fibsBoardStateTriangleKeys = [@"tri1 tri2 tri3 tri4 tri5 tri6 tri7 tri8 tri9 tri10 tri11 tri12 tri13 tri14 tri15 tri16 tri17 tri18 tri19 tri20 tri21 tri22 tri23 tri24"					componentsSeparatedByString:@" "];
	}
	else if (direction == DIRECTION_PIP24_TO_PIP1) {
		fibsBoardStateTriangleKeys = [@"tri24 tri23 tri22 tri21 tri20 tri19 tri18 tri17 tri16 tri15 tri14 tri13 tri12 tri11 tri10 tri9 tri8 tri7 tri6 tri5 tri4 tri3 tri2 tri1"					componentsSeparatedByString:@" "];
	}

	NSEnumerator * e = [fibsBoardStateTriangleKeys objectEnumerator];
	id triangleKey;
	int i = 0;
	int j = NUMBER_OF_TRIANGLES;
	color = [[fibsBoardStateDictionary objectForKey:@"color"] intValue];
	
	NSLog(@"color %d",color);
	while (triangleKey = [e nextObject]) 
	{
		if ([[fibsBoardStateDictionary objectForKey:triangleKey] intValue] < 0) 
		{
			if (color == -1)
				[[gameBoard objectAtIndex:i] setOwnedBy:1];
			else if (color == 1)
				[[gameBoard objectAtIndex:i] setOwnedBy:2];
			[[gameBoard objectAtIndex:i] setNumberOfChips:abs([[fibsBoardStateDictionary objectForKey:triangleKey] intValue])];
		}
		else if  ([[fibsBoardStateDictionary objectForKey:triangleKey] intValue] > 0)
		{	
			if (color == -1)
				[[gameBoard objectAtIndex:i] setOwnedBy:2];
			else if (color == 1)
				[[gameBoard objectAtIndex:i] setOwnedBy:1];
			[[gameBoard objectAtIndex:i] setNumberOfChips:abs([[fibsBoardStateDictionary objectForKey:triangleKey] intValue])];
		}
		else {
			[[gameBoard objectAtIndex:i] setOwnedBy:0];
			[[gameBoard objectAtIndex:i] setNumberOfChips:abs([[fibsBoardStateDictionary objectForKey:triangleKey] intValue])];
		}
		//Handle the direction preference
		if (direction == DIRECTION_PIP1_TO_PIP24) {
			[[gameBoard objectAtIndex:i] setPipNumber:i+1];
		}
		else if (direction == DIRECTION_PIP24_TO_PIP1) {
			[[gameBoard objectAtIndex:i] setPipNumber:j];
		}
		i++;
		j--;
	}
	
	
	
	int playerDie1 = [[fibsBoardStateDictionary objectForKey:@"playerDie1"] intValue];
	int playerDie2 = [[fibsBoardStateDictionary objectForKey:@"playerDie2"] intValue];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"highestDiceFirst"] && playerDie1 < playerDie2) {
		playerDice = [[AGFIBSDice alloc] initWithDie:playerDie2 otherDie:playerDie1];
	}
	else {
		playerDice = [[AGFIBSDice alloc] initWithDie:playerDie1 otherDie:playerDie2];
	}
	[self setPlayerDice:playerDice];

	[opponentDice release];
	opponentDice = [[AGFIBSDice alloc] initWithDie:[[fibsBoardStateDictionary objectForKey:@"opponentDie1"] intValue] otherDie:[[fibsBoardStateDictionary objectForKey:@"opponentDie2"] intValue]];
	
	if ([[fibsBoardStateDictionary objectForKey:@"playerDie1"] intValue] > 0) {
		playerDiceFromLastTurn =  [[AGFIBSDice alloc] initWithDie:[[fibsBoardStateDictionary objectForKey:@"playerDie1"] intValue] otherDie:[[fibsBoardStateDictionary objectForKey:@"playerDie2"] intValue]];
	}
	else if ([[fibsBoardStateDictionary objectForKey:@"opponentDie1"] intValue] > 0) {
		opponentDiceFromLastTurn = [[AGFIBSDice alloc] initWithDie:[[fibsBoardStateDictionary objectForKey:@"opponentDie1"] intValue] otherDie:[[fibsBoardStateDictionary objectForKey:@"opponentDie2"] intValue]];
	}
	
	[playerBar setNumberOfChips:[[fibsBoardStateDictionary objectForKey:@"playerBarNum"] intValue]];
	[playerBar setOwnedBy:1];
	
	[opponentBar setNumberOfChips:[[fibsBoardStateDictionary objectForKey:@"opponentBarNum"] intValue]];
	[opponentBar setOwnedBy:2];
		
	[playerHome setNumberOfChips:[[fibsBoardStateDictionary objectForKey:@"playerHomeNum"] intValue]];

	opponentHome = [[fibsBoardStateDictionary objectForKey:@"opponentHomeNum"] intValue];
	
	if ([playerDice valueOfDie:1] && ![self isWatching]) {
		NSNotificationCenter *nc;
		nc = [NSNotificationCenter defaultCenter];
		NSString *moveStringForPrint;
		int numberOfLegalMoves = [[fibsBoardStateDictionary objectForKey:@"canMove"] intValue];
		int numberOfDiceUsed = [playerDice numberOfDiceUsed];
		int movesLeft = numberOfLegalMoves - numberOfDiceUsed;
		if (movesLeft == 1) {
			moveStringForPrint = [NSString stringWithFormat:@"Please move 1 piece "];
		}
		else {
			moveStringForPrint = [NSString stringWithFormat:@"Please move %d pieces ",movesLeft];
		}
		[nc postNotificationName:@"AGFIBSDisplaySystemMsg" object:moveStringForPrint];
	}
	
	
	

	
		
}


- (BOOL)isPlayerHome 
/*" Returns YES if the player has all of their peices in the home. Otherwise returns NO "*/
{
	
	int i;
	for (i = 0; i <= 17; i++) {
		if ([[[self gameBoard] objectAtIndex:i] numberOfChips] > 0 && [[[self gameBoard] objectAtIndex:i] ownedBy] == OWNEDBY_PLAYER) {
			return NO;
		}
	}
	return YES;
}

- (int)clearTrianglesInHomeForBareoff
/*" How many triangles are free in the player's home for greedy baroffs? BAD EXPLINATON - FIX! "*/
{
	int draggedFromTriangleArrayPos = [self pipNumToArrayPos:[[self draggedFromTriangle] pipNumber]];
	int i;
	int clearTrianglesInHomeForBareoff = 6;
	for (i = 18; i < 23; i++) {
		if ([[[self gameBoard] objectAtIndex:i] numberOfChips] == 0 && draggedFromTriangleArrayPos != i || [[[self gameBoard] objectAtIndex:i] ownedBy] == OWNEDBY_OPPONENT) {
			clearTrianglesInHomeForBareoff--;
		}
		else if ([[[self gameBoard] objectAtIndex:i] numberOfChips] > 0 && [[[self gameBoard] objectAtIndex:i] ownedBy] == OWNEDBY_PLAYER || draggedFromTriangleArrayPos == i)
		{
			return clearTrianglesInHomeForBareoff;
		}
	}
	return clearTrianglesInHomeForBareoff;
}

-(int)pipNumToArrayPos:(int)pipPos 
/*" Get pip number of triangle from its position in the array. "*/
{
	if ([self direction] == DIRECTION_PIP1_TO_PIP24) {
		return (pipPos - 1);
	}
	else {
		return (abs(NUMBER_OF_TRIANGLES - pipPos));
	}
}


- (int)howManyChipsNotHome
/*" Returns the number of chips still in play outside of the player's home "*/
{
	int i;
	int howManyChipsNotHome = 0;
	if ([self color] == -1) {
		for (i = 0; i < 17; i++) {
			if ([[[self gameBoard] objectAtIndex:i] numberOfChips] > 0 && [[[self gameBoard] objectAtIndex:i] ownedBy] == OWNEDBY_PLAYER) {
				howManyChipsNotHome++;
			}
		}
	}
	else if ([self color] == 1) {
		for (i = 6; i < 23; i++) {
			if ([[[self gameBoard] objectAtIndex:i] numberOfChips] > 0 && [[[self gameBoard] objectAtIndex:i] ownedBy] == OWNEDBY_PLAYER) {
				howManyChipsNotHome++;
			}
		}
	}
	return howManyChipsNotHome;
}



//=========================================================== 
//  gameBoard 
//=========================================================== 
- (NSMutableArray *)gameBoard { return [[gameBoard retain] autorelease]; }
- (void)setGameBoard:(NSMutableArray *)aGameBoard
{
    if (gameBoard != aGameBoard) {
        [gameBoard release];
        gameBoard = [aGameBoard retain];
    }
}

//=========================================================== 
//  playerDice 
//=========================================================== 
- (AGFIBSDice *)playerDice { return [[playerDice retain] autorelease]; }
- (void)setPlayerDice:(AGFIBSDice *)aPlayerDice
{
    if (playerDice != aPlayerDice) {
        [playerDice release];
        playerDice = [aPlayerDice retain];
    }
}

//=========================================================== 
//  opponentDice 
//=========================================================== 
- (AGFIBSDice *)opponentDice { return [[opponentDice retain] autorelease]; }
- (void)setOpponentDice:(AGFIBSDice *)anOpponentDice
{
    if (opponentDice != anOpponentDice) {
        [opponentDice release];
        opponentDice = [anOpponentDice retain];
    }
}

//=========================================================== 
//  playerDiceFromLastTurn 
//=========================================================== 
- (AGFIBSDice *)playerDiceFromLastTurn { return [[playerDiceFromLastTurn retain] autorelease]; }
- (void)setPlayerDiceFromLastTurn:(AGFIBSDice *)aPlayerDiceFromLastTurn
{
    if (playerDiceFromLastTurn != aPlayerDiceFromLastTurn) {
        [playerDiceFromLastTurn release];
        playerDiceFromLastTurn = [aPlayerDiceFromLastTurn retain];
    }
}

//=========================================================== 
//  opponentDiceFromLastTurn 
//=========================================================== 
- (AGFIBSDice *)opponentDiceFromLastTurn { return [[opponentDiceFromLastTurn retain] autorelease]; }
- (void)setOpponentDiceFromLastTurn:(AGFIBSDice *)anOpponentDiceFromLastTurn
{
    if (opponentDiceFromLastTurn != anOpponentDiceFromLastTurn) {
        [opponentDiceFromLastTurn release];
        opponentDiceFromLastTurn = [anOpponentDiceFromLastTurn retain];
    }
}

//=========================================================== 
//  playerBar 
//=========================================================== 
- (AGFIBSTriangle *)playerBar { return [[playerBar retain] autorelease]; }
- (void)setPlayerBar:(AGFIBSTriangle *)aPlayerBar
{
    if (playerBar != aPlayerBar) {
        [playerBar release];
        playerBar = [aPlayerBar retain];
    }
}

//=========================================================== 
//  opponentBar 
//=========================================================== 
- (AGFIBSTriangle *)opponentBar { return [[opponentBar retain] autorelease]; }
- (void)setOpponentBar:(AGFIBSTriangle *)anOpponentBar
{
    if (opponentBar != anOpponentBar) {
        [opponentBar release];
        opponentBar = [anOpponentBar retain];
    }
}

//=========================================================== 
//  playerHome 
//=========================================================== 
- (AGFIBSTriangle *)playerHome { return [[playerHome retain] autorelease]; }
- (void)setPlayerHome:(AGFIBSTriangle *)aPlayerHome
{
    if (playerHome != aPlayerHome) {
        [playerHome release];
        playerHome = [aPlayerHome retain];
    }
}

//=========================================================== 
//  opponentHome 
//=========================================================== 
- (int)opponentHome { return opponentHome; }
- (void)setOpponentHome:(int)anOpponentHome
{
    opponentHome = anOpponentHome;
}

//=========================================================== 
//  theCube 
//=========================================================== 
- (int)theCube { return theCube; }
- (void)setTheCube:(int)aTheCube
{
    theCube = aTheCube;
}

//=========================================================== 
//  playerName 
//=========================================================== 
- (NSString *)playerName { return [[playerName retain] autorelease]; }
- (void)setPlayerName:(NSString *)aPlayerName
{
    if (playerName != aPlayerName) {
        [playerName release];
        playerName = [aPlayerName retain];
    }
}

//=========================================================== 
//  opponentName 
//=========================================================== 
- (NSString *)opponentName { return [[opponentName retain] autorelease]; }
- (void)setOpponentName:(NSString *)anOpponentName
{
    if (opponentName != anOpponentName) {
        [opponentName release];
        opponentName = [anOpponentName retain];
    }
}

//=========================================================== 
//  color 
//=========================================================== 
- (int)color { return color; }
- (void)setColor:(int)aColor
{
    color = aColor;
}

//=========================================================== 
//  draggedFromTriangle 
//=========================================================== 
- (AGFIBSTriangle *)draggedFromTriangle { return [[draggedFromTriangle retain] autorelease]; }
- (void)setDraggedFromTriangle:(AGFIBSTriangle *)aDraggedFromTriangle
{
    if (draggedFromTriangle != aDraggedFromTriangle) {
        [draggedFromTriangle release];
        draggedFromTriangle = [aDraggedFromTriangle retain];
    }
}

//=========================================================== 
//  draggedToTriangle 
//=========================================================== 
- (AGFIBSTriangle *)draggedToTriangle { return [[draggedToTriangle retain] autorelease]; }
- (void)setDraggedToTriangle:(AGFIBSTriangle *)aDraggedToTriangle
{
    if (draggedToTriangle != aDraggedToTriangle) {
        [draggedToTriangle release];
        draggedToTriangle = [aDraggedToTriangle retain];
    }
}

//=========================================================== 
//  fibsBoardStateDictionary 
//=========================================================== 
- (NSDictionary *)fibsBoardStateDictionary { return [[fibsBoardStateDictionary retain] autorelease]; }
- (void)setFibsBoardStateDictionary:(NSDictionary *)aFibsBoardStateDictionary
{
    if (fibsBoardStateDictionary != aFibsBoardStateDictionary) {
        [fibsBoardStateDictionary release];
        fibsBoardStateDictionary = [aFibsBoardStateDictionary retain];
    }
}

//=========================================================== 
//  direction 
//=========================================================== 
- (int)direction { return direction; }
- (void)setDirection:(int)aDirection
{
    direction = aDirection;
}





- (void)dealloc
/*" Clean Up "*/
{
	[gameBoard release];
	[playerDice release];
	[playerHome release];
	[super dealloc];
}
@end
