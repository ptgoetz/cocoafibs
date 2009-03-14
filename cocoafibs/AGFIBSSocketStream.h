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
@class AGFIBSAppController;
@class AGFIBSSocketStream;
@class AGFIBSGameModel;
@class NetSocket;

@interface AGFIBSSocketStream : NSObject {
	NSInputStream *inputStream;							/* provides read-only stream functionality. "*/
    NSOutputStream *outputStream;						/* provides write-only stream functionality. "*/
	NSString *serverAddress;							/* IP Address or fully qualified domain name of host "*/			/* The game model "*/
	IBOutlet AGFIBSAppController *theAppController;		/* The app controller "*/
	int serverPort;										/* The port on the server to connect to "*/
    bool connected;										/* YES or NO based on connectiion status "*/
	id delegate;										/* A reference to the delegate of the AGFIBSSocketStream "*/
	NetSocket*	mSocket;
	NSMutableArray *toBeWrittenQueue;
	NSTimer *sendMessageFromQueueTimer;
	BOOL blockSending;
}

/*" Overridden Initializer "*/
- (id)init;

/*" Designated Initializer "*/
- (id)initWithServer:(NSString *)myServerAddress port:(int)myPort;

/*" Accessor methods  "*/
//- (AGFIBSGameModel *)theAGFIBSGameModel;
//- (void)setTheAGFIBSGameModel:(AGFIBSGameModel *)newTheAGFIBSGameModel;
- (NSInputStream *)inputStream;
- (void)setInputStream:(NSInputStream *)newInputStream;
- (NSOutputStream *)outputStream;
- (void)setOutputStream:(NSOutputStream *)newOutputStream;
- (id)delegate;
- (void)setDelegate:(id)newDelegate;
- (bool)isConnected;
- (void)setConnected:(bool)isConnected;

/*" Stream methods  "*/
- (void)connect;
- (void)disconnect;
- (void)sendMessage:(NSString *)stringToSend;
//- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent;
- (void)sendMessage:(NSString *)stringToSend;
- (void)sendMessages;
- (void)sendMessageNow:(NSString *)stringToSend;
- (void)reset;
- (void)setBlockSendingYes;
- (NSString *)findAndReplaceStringInString:(NSString *)string find:(NSString *)findString replace:(NSString *)replaceString;

/*" Clean Up "*/
- (void)dealloc;
@end
