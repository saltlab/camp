//
//  main.m
//  MTGJudge
//
//  Created by Alexei Gousev on 1/22/10.
//  Copyright UC Davis 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTGJudgeAppDelegate.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([MTGJudgeAppDelegate class]));
    [pool release];
    return retVal;
}
