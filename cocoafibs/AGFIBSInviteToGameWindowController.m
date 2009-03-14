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


#import "AGFIBSInviteToGameWindowController.h"

@implementation AGFIBSInviteToGameWindowController
- (id)init
{
    self = [super initWithWindowNibName:@"InviteToGameWindow"];
	//[NSApp requestUserAttention: NSInformationalRequest];
	[NSApp requestUserAttention: NSCriticalRequest];
	
    return self;
}

- (void)dealloc
/*" Clean Up "*/
{    
	[super dealloc];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	[self dealloc];
}

- (void)windowDidLoad
/*" Nib file is loaded "*/
{
	[[self window] setTitle:[NSString stringWithFormat:@"Invite from %@", [self playerWhoInvitedName]]];
	[[self window] setFrameAutosaveName:@"inviteToGameWindow"];	
	
	NSString *invitationString = nil;
	if (proposedMatchLength == 0) {
		invitationString = [NSString stringWithFormat:@"%@ wants to resume a saved match with you.", [self playerWhoInvitedName]];
	}
	else if (proposedMatchLength > 0) {
		invitationString = [NSString stringWithFormat:@"%@ wants to play a %d point match with you.", [self playerWhoInvitedName],[self proposedMatchLength]];
	}
	[inviteMsgTextField setStringValue:invitationString];
	
	if (playerRating != nil && playerExp != nil) {
		invitationString = [NSString stringWithFormat:@"Rating: %@",playerRating];
		[ratingTextField setStringValue:invitationString];
		invitationString = [NSString stringWithFormat:@"Experience: %@",[playerExp stringValue]];
		[expMsgTextField setStringValue:invitationString];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"checkRepBotOnInvite"]) {
		[self sendNotificationToSendCommandToSocket:[NSString stringWithFormat:@"tell repbot ask %@", [self playerWhoInvitedName]]];
	}
	if (([[NSUserDefaults standardUserDefaults] boolForKey:@"chatDisplayDeclineInviteDefualtMsg"])) {
		NSMutableString *dynamicChatDeclineInviteDefualtMsg = [[NSMutableString alloc] initWithCapacity:1];
		[dynamicChatDeclineInviteDefualtMsg appendString:[[NSUserDefaults standardUserDefaults] objectForKey:@"chatDeclineInviteDefualtMsg"]];
		if (!([dynamicChatDeclineInviteDefualtMsg rangeOfString:@"<name>"].location == NSNotFound)) {
			[dynamicChatDeclineInviteDefualtMsg replaceCharactersInRange:[dynamicChatDeclineInviteDefualtMsg rangeOfString:@"<name>"] withString:[self playerWhoInvitedName]];
		}
		[declineTellMsgTextField setStringValue:dynamicChatDeclineInviteDefualtMsg];
	}
}

-(void)sendNotificationToSendCommandToSocket:(NSString *)stringToSend 
/*" Send a string to the server "*/
{
	NSNotificationCenter *nc;
	nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"AGFIBSSendCommandToSocket" object:stringToSend];
}

- (IBAction)acceptMatchInvite:(id)sender {
	[self sendNotificationToSendCommandToSocket:[NSString stringWithFormat:@"join %@", [self playerWhoInvitedName]]];
	[self close];
}

- (IBAction)declineMatchInvite:(id)sender {	
	if (![[declineTellMsgTextField stringValue] isEqualToString:@""]) {
		[self sendNotificationToSendCommandToSocket:[NSString stringWithFormat:@"tell %@ %@", [self playerWhoInvitedName], [declineTellMsgTextField stringValue]]];
	}
	[self close];
}


- (NSString *)playerWhoInvitedName {
    return [[playerWhoInvitedName retain] autorelease];
}

- (void)setPlayerWhoInvitedName:(NSString *)newPlayerWhoInvitedName {
    if (playerWhoInvitedName != newPlayerWhoInvitedName) {
        [playerWhoInvitedName release];
        playerWhoInvitedName = [newPlayerWhoInvitedName retain];
    }
}

- (int)proposedMatchLength {
    return proposedMatchLength;
}

- (void)setProposedMatchLength:(int)newProposedMatchLength {
    if (proposedMatchLength != newProposedMatchLength) {
        proposedMatchLength = newProposedMatchLength;
    }
}

- (NSString *)playerRating {
    return [[playerRating retain] autorelease];
}

- (void)setPlayerRating:(NSString *)newPlayerRating {
	if (playerRating != newPlayerRating) {
        [playerRating release];
        playerRating = [newPlayerRating retain];
    }
}

- (NSNumber *)playerExp {
    return [[playerExp retain] autorelease];
}

- (void)setPlayerExp:(NSNumber *)newPlayerExp {
    if (playerExp != newPlayerExp) {
        [playerExp release];
        playerExp = [newPlayerExp retain];
    }
}




@end
