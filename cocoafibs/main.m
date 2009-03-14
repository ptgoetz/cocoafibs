//
//  main.m
//  AGFIBS1
//
//  Created by Adam on Tue May 11 2004.
//  Copyright (c) 2004 Adam Gerson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSDebug.h>


int main(int argc, const char *argv[])
{
   
	
	NSZombieEnabled = YES;
	NSDeallocateZombies = NO;
	
	return NSApplicationMain(argc, argv);
	
}
