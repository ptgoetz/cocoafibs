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


#import  "AGFIBSLoginWindowController.h"
#import  "AGFIBSKeychain.h"
#include "AGFIBSAppController.h"




@implementation AGFIBSLoginWindowController
/*" Instances of this class act as the controller for the login window. "*/



- (BOOL)areFieldsEmpty
/*" Called when the server reports that login is sucessful. "*/
{
	NSString *emptyFieldMsg;
	BOOL fieldsWereEmprty = NO;
	
	if ([[userNameTextField stringValue] length] == 0) {
		emptyFieldMsg = [NSString stringWithString:@"Please enter a value for username"];
		fieldsWereEmprty = YES;
	}
	else if ([[passwordTextField stringValue] length] == 0) {
		emptyFieldMsg = [NSString stringWithString:@"Please enter a value for password"];
		fieldsWereEmprty = YES;
	}
	
	if (fieldsWereEmprty) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[[alert window] setAlphaValue:0.9];
		[alert addButtonWithTitle:@"Ok"];
		[alert setMessageText:emptyFieldMsg];
		[alert setInformativeText:@""];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[self loginWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];   
	}
	return fieldsWereEmprty;
}

- (IBAction)reset
{
	[errorMsgTextField setStringValue:@"CocoaFIBS"];
	[userNameTextField setEnabled:YES];
	[passwordTextField setEnabled:YES];
	[connectButton setEnabled:YES];
	[newAccountButton setEnabled:YES];
	[[theAppController disconnectMenuItem] setEnabled:YES];
	[[theAppController connectMenuItem] setEnabled:NO];
	[[theAppController connectMenuItem] setEnabled:NO];
	[connectionProgressIndicator stopAnimation:nil];
	[cancelButton setHidden:YES];
	[connectButton setHidden:NO];

}


- (IBAction)connect:(id)sender
/*" Formats the login string, disables the connect button, sets the login string, animates the progress indicator and tells the app controller to connect. "*/
{
	
	if (![self areFieldsEmpty]) {
		[cancelButton setHidden:NO];
		[connectButton setHidden:YES];
		[[NSUserDefaults standardUserDefaults] setObject:[userNameTextField stringValue] forKey:@"username"];
		
		if (![AGFIBSKeychain doesAccountExistInKeychain] && [addToKeychainButton state] == NSOnState) {
			[AGFIBSKeychain addAccountInfoToKeychain:[passwordTextField stringValue]];
		}
		else if (![[AGFIBSKeychain getKeychainPasswordForUsername:[userNameTextField stringValue]] isEqualToString:[passwordTextField stringValue]] && [addToKeychainButton state] == NSOnState) {
			[AGFIBSKeychain modifyPasswordInKeychain:[passwordTextField stringValue]];
		}
		
		[errorMsgTextField setStringValue:@"Connecting..."];
		[connectionProgressIndicator startAnimation:sender];
		NSMutableString *loginString = [NSString stringWithFormat:@"login CocoaFIBSBeta0.5 1008 %@ %@",[userNameTextField stringValue], [passwordTextField stringValue]];
		[userNameTextField setEnabled:NO];
		[passwordTextField setEnabled:NO];
		[connectButton setEnabled:NO];
		[newAccountButton setEnabled:NO];
		[[theAppController connectMenuItem] setEnabled:NO];
		
		
		
		
		
		[[theAppController disconnectMenuItem] setEnabled:YES];
		[theAppController setLoginString:loginString];	
		[theAppController connect];
		//Timeout Check
		double loginTimeoutDelayTime = [[[NSUserDefaults standardUserDefaults] stringForKey:@"loginTimeoutDelayTime"]doubleValue];
		
		loginTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:loginTimeoutDelayTime 
			target:self 
			selector:@selector(loginFailed) 
			userInfo:nil 
			repeats:NO];
			
		}
	
}

- (IBAction)loginCanceled:(id)sender 
{
	[self loginFailed];
}

- (void)loginDone
/*" Called when the server reports that login is sucessful. "*/
{
	[loginTimeoutTimer invalidate];
	[connectionProgressIndicator stopAnimation:nil];
	[loginWindow close];
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AGFIBSSPlaySoundFile" object:@"connect"];
		[cancelButton setHidden:YES];
	[connectButton setHidden:NO];
}

- (void)loginFailed
/*" Called when the server reports that login has failed. NOT WORKING "*/
{
	
	NSLog(@"loginFailed at login window!!!!!!!!!");
	 if ([[NSUserDefaults standardUserDefaults] integerForKey:@"soundOnOff"] == 1) {
		NSBeep();
	}
	[self displayFailedLoginAlertySheet];
	[[theAppController theAGFIBSSocket] reset];
	[theAppController loginFailed];
	[self reset];
	[connectionProgressIndicator stopAnimation:nil];
	[loginTimeoutTimer invalidate];
	[errorMsgTextField setStringValue:@"Login Failed"];
	[NSApp requestUserAttention: NSCriticalRequest];
	

}

- (void)displayFailedLoginAlertySheet
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[[alert window] setAlphaValue:1.0];
	[alert addButtonWithTitle:@"Ok"];
	[alert setMessageText:@"Your attempt to login to FIBS has failed."];
	[alert setInformativeText:@"Please try again."];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:[self loginWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)addToKeychainPrefCheckboxButtonClicked:(id)sender
{
	if ([addToKeychainButton state] == NSOnState) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"addToKeychain"];
	}
	else if ([addToKeychainButton state] == NSOffState) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"addToKeychain"];
		if ([AGFIBSKeychain doesAccountExistInKeychain]) {
			[AGFIBSKeychain deletePasswordInKeychain];
		}
	}

}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
	NSLog(@"login windowDidBecomeKey!!!!!!!");
	[self setUsernameAndPasswordFields];
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
/*" "*/
{
	[[NSUserDefaults standardUserDefaults] setObject:[userNameTextField stringValue] forKey:@"username"];
	if ([addToKeychainButton state] == NSOnState) {
		[self setUsernameAndPasswordFields];
	}
}

- (IBAction)newUserRegistration:(id)sender
{
    //Open terminal window
	
	NSString *command = @"telnet fibs.com 4321";
	NSString *script= [NSString stringWithFormat:@"tell application \"Terminal\"\nactivate\ndo script \"%@\"\nend tell\n",command];
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource:script];
    [as executeAndReturnError:NULL];
    [as release];
	
	/*
	//Open web browser
	NSString *stringURL = @"http://www.fibs.com/~cthulhu/register.html";
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:stringURL]];
	*/
}

- (void)setUsernameAndPasswordFields
/*" "*/
{
	
	[userNameTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]];

	if ([AGFIBSKeychain doesAccountExistInKeychain] && [[NSUserDefaults standardUserDefaults] boolForKey:@"addToKeychain"] == YES) {
		[passwordTextField setStringValue:[AGFIBSKeychain getKeychainPasswordForUsername:[[NSUserDefaults standardUserDefaults] stringForKey:@"username"]]];
	}
	else {
		[passwordTextField setStringValue:@""];
	}
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"addToKeychain"] == YES) {
		[addToKeychainButton setState:NSOnState];
	}
	else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"addToKeychain"] == NO) {
		[addToKeychainButton setState:NSOffState];
	}
	
	
}

- (NSWindow *)loginWindow {
    return [[loginWindow retain] autorelease];
}

- (void)windowDidLoad
/*" Nib file is loaded "*/
{
	[[self loginWindow] setFrameAutosaveName:@"LoginWindow"];	
}

@end
