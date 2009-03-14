//
//  AGFIBSSocketStream.m
//  AGFIBS1
//
//  Based on SocketStreamTest by Prachi Gauriar. Version 0.1, Copyright 2004
//  <gallenx@mac.com>
//
//  Created by Adam on Tue May 11 2004.
//  Copyright (c) 2004 Adam Gerson. All rights reserved.
//

#import "AGFIBSSocketStream.h"
#import "AGFIBSAppController.h"

@implementation AGFIBSSocketStream
/*" 
An instance of this class creates and returns input and output streams for a socket connection with the specified port on host. This class handles connection, disconnection, sending data, and stream events such as open, close, data available, and errors. When a line is received by the stream it is passed into the FIBSCookieMonster for RegEx parsing and then the returned string is passed to the app controller for handling. 
"*/

- (id)init
/*" Overridden Initializer "*/
{
	return [self initWithServer:@"fibs.com" port:4321];
	//return [self initWithServer:@"localhost" port:4321];
}

- (id)initWithServer:(NSString *)myServerAddress port:(int)myPort
/*" Designated Initializer "*/
{
    [super init];
	serverAddress = myServerAddress;
	serverPort = myPort;
	connected = NO;
    return self;
}

- (AGFIBSGameModel *)theAGFIBSGameModel 
/*" Returns the AGFIBSGameModel for the socket "*/
{
    return [[theAGFIBSGameModel retain] autorelease];
}

- (void)setTheAGFIBSGameModel:(AGFIBSGameModel *)newTheAGFIBSGameModel 
/*" Sets the AGFIBSGameModel for the socket "*/
{
    if (theAGFIBSGameModel != newTheAGFIBSGameModel) {
        [theAGFIBSGameModel release];
        theAGFIBSGameModel = [newTheAGFIBSGameModel retain];
    }
}

- (NSInputStream *)inputStream 
/*" Returns the NSInputStream for the socket "*/
{
    return [[inputStream retain] autorelease];
}

- (void)setInputStream:(NSInputStream *)newInputStream 
/*" Sets the NSInputStream for the socket "*/
{
    if (inputStream != newInputStream) {
        [inputStream release];
        inputStream = [newInputStream retain];
    }
    return;
}

- (NSOutputStream *)outputStream 
/*" Returns the NSOutputStream for the socket "*/
{
    return [[outputStream retain] autorelease];
}

- (void)setOutputStream:(NSOutputStream *)newOutputStream 
/*" Sets the NSOutputStream for the socket "*/
{
    if (outputStream != newOutputStream) {
        [outputStream release];
        outputStream = [newOutputStream retain];
    }
}

- (id)delegate 
/*" Returns the delegate of the socket "*/
{
    return [[delegate retain] autorelease];
}

- (void)setDelegate:(id)newDelegate 
/*" Sets the delegate of the socket "*/
{
	delegate = newDelegate;
}

- (bool)isConnected
/*" Returns the connection status of the socket "*/
{
    return connected;
}

- (void)setConnected:(bool)isConnected
/*" Sets the connection status of the socket "*/
{
    connected = isConnected;
}

- (void)connect
/*" Connect to the specified host at the specified port. Set ourself to to the delegate, schedule ourselves in the runloop, and open the streams. Reset the FIBSCookieMonster for parseing"*/
{
	// Connect to the specified host
    [NSStream getStreamsToHost:[NSHost hostWithName:serverAddress]
                          port:serverPort
                   inputStream:&inputStream
                  outputStream:&outputStream];
	
    // Set ourself to to the delegate, schedule ourselves in the runloop, and open the streams
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
	
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
    [inputStream open];
    [outputStream open];
	
	ResetFIBSCookieMonster();
}

- (void)disconnect
/*" Disconnect, close and dealloc the streams, release the FIBSCookieMonster. "*/
{
    [self sendMessage:@"exit"];
	[self setConnected:NO];
    [inputStream close];
    [outputStream close];
	 [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	
    [self setInputStream:nil];
    [self setOutputStream:nil];
	ReleaseFIBSCookieMonster();
}

- (void)sendMessage:(NSString *)stringToSend
/*" Send the message stringToSend to the receiver.  Append a \r\n to the end for telnet like behavior. "*/
{
    NSString *message = [stringToSend stringByAppendingString:@"\r\n"];
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    [outputStream write:[messageData bytes] maxLength:[messageData length]];
    NSLog(@"sent %@",stringToSend);
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent 
/*" This method handles all stream events (stream open, close, data available, etc) "*/
{
	NSString *messageString = nil;
	NSString *newLineChar = @"\n";
	NSString *temp = nil; 
	NSString *carriageReturnChar = @"\r";
	NSString *cookieString = nil;
	NSString *oneStringFromArray = nil;
	NSArray *arrayToStripNewLineCharFromString = nil;
	NSData *cString = nil;
	NSData *messageData = nil;
	uint8_t buffer[1024];
	int numberOfLinesInBuffer = 0;
	int cookie = 0;
	int i = 0;
	int bytesRead = 0;
    switch(streamEvent) {
        case NSStreamEventNone:
			break;
        case NSStreamEventOpenCompleted:
            // If the stream has completed opening, update the UI
            NSLog(@"Connected\n");
            [self setConnected:YES];
            break;
        case NSStreamEventHasBytesAvailable:;
			// If the stream has bytes available to read, read it and strip the new line chars.
            bytesRead = [(NSInputStream *)stream read:buffer maxLength:1024];
            messageData = [NSData dataWithBytes:buffer length:bytesRead];
            messageString = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
			arrayToStripNewLineCharFromString = [ messageString componentsSeparatedByString:newLineChar];
			numberOfLinesInBuffer = [arrayToStripNewLineCharFromString count];
			//Append the last line of the previous data avilible block to the first line of this one
			
			for (i=0; i < numberOfLinesInBuffer; i++) {
				
				oneStringFromArray = [arrayToStripNewLineCharFromString objectAtIndex:i];
				/*
				if (i == 0 && numberOfLinesInBuffer > 4) {
					temp = lastStringFromDataAvail;
					oneStringFromArray = [lastStringFromDataAvail stringByAppendingString:oneStringFromArray];
				}
				else if (i == (numberOfLinesInBuffer-1) && numberOfLinesInBuffer > 2) {
					lastStringFromDataAvail = oneStringFromArray;   
					break;
				}
				*/
				oneStringFromArray = [self findAndReplaceStringInString:oneStringFromArray find:carriageReturnChar replace:@""];
				//Convert NSString to cstring
				int aBufferSize = [oneStringFromArray length];
				char aBuffer[aBufferSize];
				cString = [oneStringFromArray dataUsingEncoding:[NSString defaultCStringEncoding]];
				[cString getBytes:aBuffer];
				cookie = FIBSCookie(aBuffer);
				[delegate handleFIBSResponseEvent:cookie message:oneStringFromArray];
				//Format a nice string to print to the terminal
				cookieString = [[NSString alloc] initWithFormat:@"(%d)", cookie];
				oneStringFromArray = [cookieString stringByAppendingString:oneStringFromArray];
				NSLog(oneStringFromArray);
				
			}
			
			[cookieString release];
			[messageString release];
        case NSStreamEventHasSpaceAvailable:
            break;
        case NSStreamEventErrorOccurred:
            // If an error occurred, log it in the text view and disconnect
			 NSLog(@"Errorrrrr %@", [theAppController description]);
			 [[theAppController theLoginWindowController] loginFailed];
            NSLog(@"Error");
			NSLog([[stream streamError] description]);           
            [self disconnect];
            break;
        case NSStreamEventEndEncountered:
            // Log the disconnection and disconnect
			NSLog(@"Disconected");
            [self disconnect];
            break;
    }
}

- (NSString *)findAndReplaceStringInString:(NSString *)string find:(NSString *)findString replace:(NSString *)replaceString
/*" Redudent, replace with built in Cocoa method "*/
{
	NSArray *found = [string componentsSeparatedByString:findString]; 
	NSString *replaced = [found componentsJoinedByString:replaceString];
	return replaced;
}

- (void)dealloc
/*" Clean Up "*/
{    
    [self setInputStream:nil];
    [self setOutputStream:nil];
    [super dealloc];
    
    return;
}

@end
