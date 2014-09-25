//
//  main.m
//  MTGJudge
//
//  Created by Alexei Gousev on 1/22/10.
//  Copyright UC Davis 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTGJudgeAppDelegate.h"
#import "OutputComponent.h"
#import <objc/runtime.h>
#import "Aspects.h"

int main(int argc, char *argv[]) {
    
//   [[OutputComponent sharedOutput] addAOPToMethodCalls];
    unsigned classNamesCount = 0;
    const char** classNames = objc_copyClassNamesForImage([[[NSBundle mainBundle] executablePath] UTF8String], &classNamesCount);
    
    for(unsigned classIdx = 0; classIdx < classNamesCount; ++classIdx){
        
        NSString* className = [NSString stringWithFormat:@"%s", classNames[classIdx]];
        
        // No need to log iOS analyser classes
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
            
            unsigned methodsCount = 0;
            Method* methods = class_copyMethodList(objc_getClass(classNames[classIdx]), &methodsCount);
            for(unsigned methodIdx = 0; methodIdx < methodsCount; ++methodIdx){
                
                [[OutputComponent sharedOutput] traceAllClassesMethods:[NSString stringWithFormat:@"    %s", sel_getName(method_getName(methods[methodIdx]))]];
                
                [objc_getClass(classNames[classIdx]) aspect_hookSelector:method_getName(methods[methodIdx]) withOptions:0 usingBlock:^(id<AspectInfo> info) {
                    
                    NSString* string = [NSString stringWithFormat:@"%@", info.instance];
                    NSRange searchFromRange = [string rangeOfString:@"<"];
                    NSRange searchToRange = [string rangeOfString:@" "];
                    NSString *class1 = [string substringWithRange:NSMakeRange(searchFromRange.location+searchFromRange.length, searchToRange.location-searchFromRange.location-searchFromRange.length)];
                    NSString* method1 = [NSStringFromSelector(info.originalInvocation.selector) stringByReplacingOccurrencesOfString:@"aspects__" withString:@""];
                    
                    [[OutputComponent sharedOutput].methodCallsArray addObject:[NSString stringWithFormat:@"[%@ %@]", class1, method1]];
                    //[[OutputComponent sharedOutput] traceMethod:[NSString stringWithFormat:@"[%@ %@]", class1, method1]];
                    
                } error:NULL];
                
            }
            free(methods);
        }
    }
    free(classNames);
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([MTGJudgeAppDelegate class]));
    [pool release];
    return retVal;
}
