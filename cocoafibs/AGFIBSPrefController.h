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

@interface AGFIBSPrefController : NSWindowController {
	IBOutlet NSButton *leftStartPositionPrefRadioButton;
	IBOutlet NSButton *rightStartPositionPrefRadioButton;
	IBOutlet NSButton *onSoundPrefRadioButton;
	IBOutlet NSButton *offSoundPrefRadioButton;
	IBOutlet NSButton *highlightTargetPipsPrefCheckboxButton;
	NSMutableArray *contentsOfBoardsFolder;
}

- (void)prefsHaveChanged;
- (void)getCustomBoards;

- (IBAction)leftStartPositionPrefRadioButtonClicked:(id)sender;
- (IBAction)rightStartPositionPrefRadioButtonClicked:(id)sender;
- (IBAction)onSoundnPrefRadioButtonClicked:(id)sender;
- (IBAction)offSoundPrefRadioButtonClicked:(id)sender;
- (IBAction)highlightTargetPipsPrefCheckboxButtonClicked:(id)sender;
- (IBAction)changeCustomBoard:(id)sender;
@end
