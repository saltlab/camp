#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "OutputComponent.h"
#import <objc/runtime.h>
#import "Aspects.h"

int main(int argc, char *argv[])
{
    //   [[OutputComponent sharedOutput] addAOPToMethodCalls];
    unsigned classNamesCount = 0;
    const char** classNames = objc_copyClassNamesForImage([[[NSBundle mainBundle] executablePath] UTF8String], &classNamesCount);
    
    for(unsigned classIdx = 0; classIdx < classNamesCount; ++classIdx){
        
        NSString* className = [NSString stringWithFormat:@"%s", classNames[classIdx]];
        
        // No need to log our iOS analyser classes
        if (!([className isEqualToString:@"AspectInfo"] ||
              [className isEqualToString:@"AspectsContainer"] ||
              [className isEqualToString:@"AspectIdentifier"] ||
              [className isEqualToString:@"AspectTracker"] ||
              [className isEqualToString:@"OutputComponent"] ||
              [className isEqualToString:@"XMLWriter"] ||
              [className isEqualToString:@"UIElement"] ||
              [className isEqualToString:@"UIState"] ||
              [className isEqualToString:@"UIEdge"] ||
              [className isEqualToString:@"DCIntrospect"])) {
            
            [[OutputComponent sharedOutput] traceAllClassesMethods:className];
            
            
            //get the properties list
            NSMutableArray *propNames = [NSMutableArray array];
            unsigned int outCount, i;
            objc_property_t *properties = class_copyPropertyList(objc_getClass(classNames[classIdx]), &outCount);
            for(i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                const char *propName = property_getName(property);
                if(propName) {
                    NSString *propertyName = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
                    //add getter
                    [propNames addObject:propertyName];
                    //add setter
                    propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                         withString:[[propertyName substringToIndex:1] uppercaseString]];
                    [propNames addObject:[NSString stringWithFormat:@"set%@:",propertyName]];
                }
            }
            
            
            unsigned methodsCount = 0;
            Method* methods = class_copyMethodList(objc_getClass(classNames[classIdx]), &methodsCount);
            for(unsigned methodIdx = 0; methodIdx < methodsCount; ++methodIdx){
                
                NSString* methodName = [NSString stringWithFormat:@"%s", sel_getName(method_getName(methods[methodIdx]))];
                
                //igoner setter getter for @properties
                if (![propNames containsObject:methodName]) {
                    
                    [[OutputComponent sharedOutput] traceAllClassesMethods:[NSString stringWithFormat:@"    %@", methodName]];
                    
                    NSMutableArray* builtInMethods = [[NSMutableArray alloc] init];
//                    [builtInMethods addObject:@"applicationDidFinishLaunching:"];
//                    [builtInMethods addObject:@"viewDidLoad"];
//                    [builtInMethods addObject:@"numberOfSectionsInTableView:"];
//                    [builtInMethods addObject:@"tableView:numberOfRowsInSection:"];
//                    [builtInMethods addObject:@"tableView:cellForRowAtIndexPath:"];
//                    [builtInMethods addObject:@"viewDidAppear:"];
//                    [builtInMethods addObject:@"tableView:didSelectRowAtIndexPath:"];
//                    [builtInMethods addObject:@"tableView:titleForHeaderInSection:"];
//                    [builtInMethods addObject:@"tableView:heightForRowAtIndexPath:"];
//                    [builtInMethods addObject:@"viewWillDisappear:"];
//                    [builtInMethods addObject:@"viewWillAppear:"];
//                    [builtInMethods addObject:@"hidesBottomBarWhenPushed"];
//                    [builtInMethods addObject:@"scrollViewDidScroll:"];
//                    [builtInMethods addObject:@"viewDidDisappear:"];
//                    [builtInMethods addObject:@"searchBarTextDidBeginEditing:"];
//                    [builtInMethods addObject:@"viewDidLoad"];
//                    [builtInMethods addObject:@"viewDidLoad"];
                    
                    
                    //if (![[objc_getClass(classNames[classIdx]) superclass] respondsToSelector:NSSelectorFromString(methodName)]) {
                    if (![builtInMethods containsObject:methodName]) {
                        
                        [objc_getClass(classNames[classIdx]) aspect_hookSelector:method_getName(methods[methodIdx]) withOptions:0 usingBlock:^(id<AspectInfo> info) {
                            
                            NSString* string = [NSString stringWithFormat:@"%@", info.instance];
                            NSRange searchFromRange = [string rangeOfString:@"<"];
                            NSRange searchToRange = [string rangeOfString:@" "];
                            NSString *class1 = [string substringWithRange:NSMakeRange(searchFromRange.location+searchFromRange.length, searchToRange.location-searchFromRange.location-searchFromRange.length)];
                            NSString* method1 = [NSStringFromSelector(info.originalInvocation.selector) stringByReplacingOccurrencesOfString:@"aspects__" withString:@""];
                            
                            [[OutputComponent sharedOutput].methodCallsArray addObject:[NSString stringWithFormat:@"[%@ %@]", class1, method1]];
                            
                        } error:NULL];
                    }
                }
            }
            free(properties);
            free(methods);
        }
    }
    free(classNames);
    
    
    //get the libraries
    unsigned libNamesCount = 0;
    const char** libNames = objc_copyImageNames(&libNamesCount);
    for(unsigned libIdx = 0; libIdx < libNamesCount; ++libIdx) {
        [[OutputComponent sharedOutput] traceAllClassesMethods:[NSString stringWithFormat:@"%s", libNames[libIdx]]];
    }
    free(libNames);
    
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
