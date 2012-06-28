//
//  AppDelegate.h
//  Cocos2DSimpleGame
//
//  Created by Dilip Muthukrishnan on 12-06-15.
//  Copyright PointerWare Innovations Limited 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
