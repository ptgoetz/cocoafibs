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

#import "AGFIBSTriangle.h"

@implementation AGFIBSTriangle
/*" 
Instances of this class encapsulate a single backgammon triangle. A triangle knows its pip number, how many chips are on it, and which player owns the triangle. A pip number can never change but owner and number of chips are updated as the game is played.
"*/

- (id)initWithOwnedBy:(int)owner numberOfChips:(int)numOfChips pipNumber:(int)pNum 
/*" Designated initializer: Initializes the receiver with the specified information about a triangle."*/
{
	self = [super init];
	ownedBy = owner;
	numberOfChips = numOfChips;
	pipNumber = pNum;
	highlighted = NO;
	return self;
}

- (id)init 
/*" Overridden Initializer "*/
{
	return [self initWithOwnedBy:0 numberOfChips:0 pipNumber:0];	
}

- (void)encodeWithCoder:(NSCoder *)coder 
{
    [coder encodeInt:[self ownedBy] forKey:@"noneOwnedBy"];
    [coder encodeInt:[self numberOfChips] forKey:@"noneNumberOfChips"];
    [coder encodeInt:[self pipNumber] forKey:@"nonePipNumber"];
    [coder encodeInt:[self arrayPos] forKey:@"noneArrayPos"];
    [coder encodeBool:[self highlighted] forKey:@"noneHighlighted"];
}

- (id)initWithCoder:(NSCoder *)coder 
{
		[super init];
        [self setOwnedBy:[coder decodeIntForKey:@"noneOwnedBy"]];
        [self setNumberOfChips:[coder decodeIntForKey:@"noneNumberOfChips"]];
        [self setPipNumber:[coder decodeIntForKey:@"nonePipNumber"]];
        [self setArrayPos:[coder decodeIntForKey:@"noneArrayPos"]];
        [self setHighlighted:[coder decodeBoolForKey:@"noneHighlighted"]];
		return self;
}

- (NSString *)description 
/*" Overridden description "*/
{
	return [NSString stringWithFormat:@"ownedBy: %d numberOfChips: %d pipNumber: %d arrayPos: %d highlighted: %d ", ownedBy,numberOfChips,pipNumber,arrayPos,highlighted];	
}

- (void)removeChip 
/*" Decrements the number of chips held on this triangle instance "*/
{
	numberOfChips--;
	if (numberOfChips < 1) {
		ownedBy = OWNEDBY_NOONE;
	}
}

- (void)addChip 
/*" Increments the number of chips held on this triangle instance "*/
{
	numberOfChips++;
}

//=========================================================== 
//  ownedBy 
//=========================================================== 
- (int)ownedBy { return ownedBy; }
- (void)setOwnedBy:(int)newOwnedBy
{
    ownedBy = newOwnedBy;
}

//=========================================================== 
//  numberOfChips 
//===========================================================
- (int)numberOfChips { return numberOfChips; }
- (void)setNumberOfChips:(int)newNumberOfChips
{
    numberOfChips = newNumberOfChips;
}

//=========================================================== 
//  pipNumber 
//=========================================================== 
- (int)pipNumber { return pipNumber; }
- (void)setPipNumber:(int)newPipNumber
{
    pipNumber = newPipNumber;
}

//=========================================================== 
//  arrayPos 
//=========================================================== 
- (int)arrayPos { return arrayPos; }
- (void)setArrayPos:(int)newArrayPos
{
    arrayPos = newArrayPos;
}

//=========================================================== 
//  highlighted 
//=========================================================== 
- (BOOL)highlighted { return highlighted; }
- (void)setHighlighted:(BOOL)flag
{
    highlighted = flag;
}


- (void)dealloc
/*" Clean Up "*/
{
	[super dealloc];
}
@end
