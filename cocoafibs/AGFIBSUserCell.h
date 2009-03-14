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

@interface AGFIBSUserCell : NSActionCell {
	NSMutableDictionary *userListWindowData;		/*" A dictionary of information relating to a single user. "*/
	BOOL selected;									/*" Is this cell the currently selected cell? "*/
	NSApplication *app;
}

/*" Designated Initializers "*/
- (id)init;

/*" NSActionCell Methods "*/
- (void)setObjectValue:(id)x;
- (void)setNeedsDisplay:(BOOL)yn;
- (NSCellType)type;
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

/*" AGFIBSUserCell Methods "*/
- (NSImage*)imageForClientName:(NSString *)clientName;

@end
