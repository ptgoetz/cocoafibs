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
@class AGFIBSAppController;
@class AGFIBSKeychain;

@interface AGFIBSLoginWindowController : NSObject
{
    IBOutlet NSProgressIndicator *connectionProgressIndicator;		/*" The progress indicator on the login window "*/
    IBOutlet NSWindow *loginWindow;									/*" The Login Window "*/
    IBOutlet NSTextField *passwordTextField;						/*" The password field on the login window "*/
    IBOutlet NSTextField *userNameTextField;						/*" The username field on the login window "*/
	IBOutlet NSTextField *errorMsgTextField;						/*" Displays connection status "*/
	IBOutlet NSButton *connectButton;								/*" The connect button on the login window "*/
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *newAccountButton;							/*" The New Account button on the login window "*/
	IBOutlet AGFIBSAppController *theAppController;					/*" The Application Controller "*/
	IBOutlet NSButton *addToKeychainButton;	
	NSTimer *loginTimeoutTimer;
	AGFIBSKeychain *theKeychain;
	
}
/*" Login Window Methods "*/
- (IBAction)connect:(id)sender;
- (void)loginDone;
- (void)loginFailed;
- (IBAction)loginCanceled:(id)sender;
- (IBAction)newUserRegistration:(id)sender;
- (void)setUsernameAndPasswordFields;
- (NSWindow *)loginWindow;
- (IBAction)addToKeychainPrefCheckboxButtonClicked:(id)sender;
- (void)displayFailedLoginAlertySheet;
- (IBAction)reset;
@end
