//
//  TabBar.h
//  Cordova Plugin
//
//  Created by Lifetime.com.eg Technical Team (Amr Hossam / Emad ElShafie) on 6 January 2016.
//  Copyright (c) 2016 Lifetime.com.eg. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "Cordova/CDV.h"

@interface TabBar : CDVPlugin <UITabBarDelegate> {
    UITabBar* tabBar;
    
    NSMutableDictionary* tabBarItems;
    
    // Represents frame of web view as if started in portrait mode. Coordinates are relative to the superview. With
    // Cordova 2.1.0, frame.origin.y=0 means directly under the status bar, while in older versions it would have been
    // frame.origin.y=20.
    CGRect	originalWebViewFrame;
    
    CGFloat navBarHeight;
    CGFloat tabBarHeight;
    bool tabBarAtBottom;
}

- (void)create:(CDVInvokedUrlCommand*)command;
- (void)show:(CDVInvokedUrlCommand*)command;
- (void)resize:(CDVInvokedUrlCommand*)command;
- (void)hide:(CDVInvokedUrlCommand*)command;
- (void)init:(CDVInvokedUrlCommand*)command;
- (void)showItems:(CDVInvokedUrlCommand*)command;
- (void)createItem:(CDVInvokedUrlCommand*)command;
- (void)updateItem:(CDVInvokedUrlCommand*)command;
- (void)selectItem:(CDVInvokedUrlCommand*)command;

@end

@interface UITabBar (NavBarCompat)
@property (nonatomic) bool tabBarAtBottom;
@end