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

@interface AGFIBSTriangle : NSObject <NSCoding> {
	int				numberOfChips;		/*" How many chips are on me right now "*/
	int				pipNumber;			/*" What pip number does this triangle represent "*/
	int				arrayPos;
	BOOL			highlighted;
	enum {
		OWNEDBY_NOONE = 0,
		OWNEDBY_PLAYER,
		OWNEDBY_OPPONENT
	} ownedBy ;							/*" Possible values for ownedBy "*/
										/*" Which player is on me now 0=none 1=player 2=opponent "*/
	
}

/*" Designated Initializers "*/
- (id)initWithOwnedBy:(int)owner numberOfChips:(int)numOfChips pipNumber:(int)pNum;

/*" Overridden Initializer "*/
- (id)init;

/*" Chip methods  "*/
- (void)removeChip;
- (void)addChip;

/*" Accessor methods  "*/
- (int)ownedBy;
- (void)setOwnedBy:(int)newOwnedBy;
- (int)numberOfChips;
- (void)setNumberOfChips:(int)newNumberOfChips;
- (int)pipNumber;
- (void)setPipNumber:(int)newPipNumber;
- (int)arrayPos;
- (void)setArrayPos:(int)newArrayPos;
- (BOOL)highlighted;
- (void)setHighlighted:(BOOL)flag;
- (int)pipNumber;

/*" Clean Up "*/
- (void)dealloc;
@end
