//
//  DCIntrospect.h
//
//  Created by Domestic Cat on 29/04/11.
//

#import <Foundation/Foundation.h>

@interface DCIntrospect : NSObject {
}

/////////////////////////////
// (Somewhat) Experimental //
/////////////////////////////
- (NSMutableString*)logPropertiesForObject:(id)object;
/////////////////////////
// Description Methods //
/////////////////////////
- (NSString *)describeProperty:(NSString *)propertyName value:(id)value;
- (NSString *)describeColor:(UIColor *)color;

@end
