//
//  main.m
//  Koi HD
//
//  Created by 大畅 on 13-5-9.
//  Copyright OceanDev 2013. All rights reserved.
//


#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
