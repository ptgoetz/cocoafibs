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


#import "AGFIBSKeychain.h"

#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>
#include <stdio.h> // for printf()

@implementation AGFIBSKeychain

/* OF: why is this a class emthod? */

+ (BOOL)doesAccountExistInKeychain
{
	SecKeychainSearchRef search;
	SecKeychainItemRef item;
	SecKeychainAttributeList list;
	SecKeychainAttribute attributes[3];
    OSErr result;
    int i = 0;

	NSString *keychainItemName = [NSString stringWithString:@"FIBS Account"];
	NSString *keychainItemKind = [NSString stringWithString:@"FIBS Username/Password"];
	
	
    // create an attribute list with just one attribute specified	
	attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void*)[[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] cString];
    attributes[0].length = [[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] length];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void*)[keychainItemName cString];
    attributes[1].length = [keychainItemName length];
	
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void*)[keychainItemKind cString];
    attributes[2].length = [keychainItemKind length];

    list.count = 3;
    list.attr = attributes;

    result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);

    if (result != noErr) {
        printf ("status %d from SecKeychainSearchCreateFromAttributes\n", result);
    }

    while (SecKeychainSearchCopyNext (search, &item) == noErr) {
        CFRelease (item);
        i++;
    }
	
   //printf ("%d items found\n", i);
    CFRelease (search);
	return i;
}

+ (BOOL)deletePasswordInKeychain
{
	SecKeychainAttribute attributes[3];
    SecKeychainAttributeList list;
    SecKeychainItemRef item;
	SecKeychainSearchRef search;
    OSStatus status = 0;
	OSErr result;

	NSString *keychainItemName = [NSString stringWithString:@"FIBS Account"];
	NSString *keychainItemKind = [NSString stringWithString:@"FIBS Username/Password"];
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void*)[[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] cString];
    attributes[0].length = [[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] length];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void*)[keychainItemName cString];
    attributes[1].length = [keychainItemName length];
	
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void*)[keychainItemKind cString];
    attributes[2].length = [keychainItemKind length];

    list.count = 3;
    list.attr = attributes;
	
	result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);
	SecKeychainSearchCopyNext (search, &item);
    
	if (result == noErr) {
		status = SecKeychainItemDelete(item);
	}
	
    if (status != 0) {
        printf("Error deleting item: %d\n", (int)status);
    }
	 CFRelease (item);
	 CFRelease(search);
	return !status;
}

+ (BOOL)modifyPasswordInKeychain:(NSString *)newPassword
{
	SecKeychainAttribute attributes[3];
    SecKeychainAttributeList list;
    SecKeychainItemRef item;
	SecKeychainSearchRef search;
    OSStatus status;
	OSErr result;

	NSString *keychainItemName = [NSString stringWithString:@"FIBS Account"];
	NSString *keychainItemKind = [NSString stringWithString:@"FIBS Username/Password"];
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void*)[[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] cString];
    attributes[0].length = [[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] length];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void*)[keychainItemName cString];
    attributes[1].length = [keychainItemName length];
	
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void*)[keychainItemKind cString];
    attributes[2].length = [keychainItemKind length];

    list.count = 3;
    list.attr = attributes;
	
	result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);
	SecKeychainSearchCopyNext (search, &item);
    status = SecKeychainItemModifyContent(item, &list, [newPassword length], [newPassword cString]);
	
    if (status != 0) {
        printf("Error modifying item: %d\n", (int)status);
    }
	 CFRelease (item);
	 CFRelease(search);
	return !status;
}

+ (BOOL)addAccountInfoToKeychain:(NSString *)password
{
	SecKeychainAttribute attributes[3];
    SecKeychainAttributeList list;
    SecKeychainItemRef item;
    OSStatus status;

	NSString *keychainItemName = [NSString stringWithString:@"FIBS Account"];
	NSString *keychainItemKind = [NSString stringWithString:@"FIBS Username/Password"];
	
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void*)[[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] cString];
    attributes[0].length = [[[NSUserDefaults standardUserDefaults] stringForKey:@"username"] length];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void*)[keychainItemName cString];
    attributes[1].length = [keychainItemName length];
	
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void*)[keychainItemKind cString];
    attributes[2].length = [keychainItemKind length];

    list.count = 3;
    list.attr = attributes;

    status = SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass, &list, [password length], [password cString], NULL,NULL,&item);
    if (status != 0) {
        printf("Error creating new item: %d\n", (int)status);
    }
	return !status;
}

+ (NSString *)getKeychainPasswordForUsername:(NSString *)username
{
    SecKeychainSearchRef search;
    SecKeychainItemRef item;
    SecKeychainAttributeList list;
    SecKeychainAttribute attributes[3];
    OSErr result;

	NSString *keychainItemName = [NSString stringWithString:@"FIBS Account"];
	NSString *keychainItemKind = [NSString stringWithString:@"FIBS Username/Password"];
	
	
    // create an attribute list with just one attribute specified	
	attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void*)[username cString];
    attributes[0].length = [username length];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void*)[keychainItemName cString];
    attributes[1].length = [keychainItemName length];
	
	attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void*)[keychainItemKind cString];
    attributes[2].length = [keychainItemKind length];

    list.count = 3;
    list.attr = attributes;

    result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);

    if (result != noErr) {
        printf ("status %d from SecKeychainSearchCreateFromAttributes\n", result);
    }
	
	NSString *password = @"error";
    if (SecKeychainSearchCopyNext (search, &item) == noErr) {
		//NSLog(@"Found Password %@", [self getPassword:item]);
		password = [self getPassword:item];
		CFRelease(item);
		CFRelease (search);
	}
	return password;
}

/* OF: why is this a class method? */
+ (NSString *)getPassword:(SecKeychainItemRef)item
{
    UInt32 length;
    char *password;
    SecKeychainAttribute attributes[8];
    SecKeychainAttributeList list;
    OSStatus status;

    // list the attributes you wish to read
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
 
    list.count = 4;
    list.attr = attributes;

    status = SecKeychainItemCopyContent (item, NULL, &list, &length, 
                                         (void **)&password);

    // use this version if you don't really want the password,
    // but just want to peek at the attributes
    //status = SecKeychainItemCopyContent (item, NULL, &list, NULL, NULL);
    
    // make it clear that this is the beginning of a new
    // keychain item
    if (status == noErr) {
        if (password != NULL) {

            // copy the password into a buffer so we can attach a
            // trailing zero byte in order to be able to print
            // it out with printf
            char passwordBuffer[1024];

            if (length > 1023) {
                length = 1023; // save room for trailing \0
            }
            strncpy (passwordBuffer, password, length);

            passwordBuffer[length] = '\0';
			//printf ("passwordBuffer = %s\n", passwordBuffer);
			return [NSString stringWithCString:passwordBuffer];
        } else {
		    SecKeychainItemFreeContent (&list, password);
			printf("Error = %d\n", (int)status);
			return @"";
		}

    } else {
        printf("Error = %d\n", (int)status);
		return @"";
    }
}



@end
