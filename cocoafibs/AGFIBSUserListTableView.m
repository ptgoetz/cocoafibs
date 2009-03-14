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

#import "AGFIBSUserListTableView.h"


@implementation AGFIBSUserListTableView
/*"
Instances of this class inherit from the built in NSTableView and allow a custom TableView.
"*/

- (NSMenu *)menuForEvent:(NSEvent *)theEvent 
/*"  Returns a context-sensitive pop-up menu for the mouse-down event theEvent.  "*/
{
	return [[self delegate] menuForEvent:theEvent];
}

-(void)mouseDown:(NSEvent *)theEvent 
/*" Informs the receiver that the user has pressed the left mouse button specified by theEvent. "*/
{
	return [[self delegate] mouseDown:theEvent];
}

-(void)mouseUp:(NSEvent *)theEvent 
/*" Informs the receiver that the user has pressed the left mouse button specified by theEvent. "*/
{
	return [[self delegate] mouseUp:theEvent];
}

-(void)keyDown:(NSEvent *)theEvent 
/*"  "*/
{
	return [[self delegate] keyDown:theEvent];
}


@end
