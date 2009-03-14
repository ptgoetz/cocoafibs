//
//  RoundRects.m
//
//				http://www.cocoadev.com/index.pl?NSBezierPathCategory
//				bezierPathWithRoundRectInRect:radius:
//              
//


#import <Foundation/Foundation.h>


@interface NSBezierPath (RoundRects)

/*" The one and olny method. "*/
+ (NSBezierPath *) bezierPathWithRoundedRect: (NSRect) aRect cornerRadius: (double) radius;
@end
