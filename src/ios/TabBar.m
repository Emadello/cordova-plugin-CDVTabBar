//
//  TabBar.m
//  Cordova Plugin
//
//  Created by Lifetime.com.eg Technical Team (Amr Hossam / Emad ElShafie) on 6 January 2016.
//  Copyright (c) 2016 Lifetime.com.eg. All rights reserved.
//

#import <objc/runtime.h>
#import "TabBar.h"
#import <UIKit/UINavigationBar.h>
#import <QuartzCore/QuartzCore.h>

@implementation TabBar
#ifndef __IPHONE_3_0
@synthesize webView;
#endif

- (void) pluginInitialize {
    
    UIWebView *uiwebview = nil;
    if ([self.webView isKindOfClass:[UIWebView class]]) {
        uiwebview = ((UIWebView*)self.webView);
    }
    tabBarItems = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    // -----------------------------------------------------------------------
    // This code block is the same for both the navigation and tab bar plugin!
    // -----------------------------------------------------------------------
    
    // The original web view frame must be retrieved here. On iPhone, it would be 0,0,320,460 for example. Since
    // Cordova seems to initialize plugins on the first call, there is a plugin method init() that has to be called
    // in order to make Cordova call *this* method. If someone forgets the init() call and uses the navigation bar
    // and tab bar plugins together, these values won't be the original web view frame and layout will be wrong.
    originalWebViewFrame = uiwebview.frame;
    UIApplication *app = [UIApplication sharedApplication];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            float statusBarHeight = 0;
            if(!app.statusBarHidden)
                statusBarHeight = MIN(app.statusBarFrame.size.width, app.statusBarFrame.size.height);
            
            originalWebViewFrame = CGRectMake(originalWebViewFrame.origin.y,
                                              originalWebViewFrame.origin.x,
                                              originalWebViewFrame.size.height,
                                              originalWebViewFrame.size.width);
            break;
        }
        default:
            NSLog(@"Unknown orientation: %d", orientation);
            break;
    }
    
    navBarHeight = 44.0f;
    
    //navBarHeight = 64.0f;
    tabBarHeight = 49.0f;
    // -----------------------------------------------------------------------
    
    tabBarAtBottom = true;
    
}

-(void)correctWebViewFrame
{
    if(!tabBar)
        return;
    
    const bool tabBarShown = !tabBar.hidden;
    bool navBarShown = false;
    
    UIView *parent = [tabBar superview];
    for(UIView *view in parent.subviews)
        if([view isMemberOfClass:[UINavigationBar class]])
        {
            navBarShown = !view.hidden;
            break;
        }
    
    // -----------------------------------------------------------------------------
    // IMPORTANT: Below code is the same in both the navigation and tab bar plugins!
    // -----------------------------------------------------------------------------
    
    CGFloat left = originalWebViewFrame.origin.x;
    CGFloat right = left + originalWebViewFrame.size.width;
    CGFloat top = originalWebViewFrame.origin.y;
    CGFloat bottom = top + originalWebViewFrame.size.height;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            // No need to change width/height from original frame
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            right = left + originalWebViewFrame.size.height + 20.0f;
            bottom = top + originalWebViewFrame.size.width - 20.0f;
            break;
        default:
            NSLog(@"Unknown orientation: %d", orientation);
            break;
    }
    
    if(navBarShown)
        //top += navBarHeight;
        
        if(tabBarShown)
        {
            if(tabBarAtBottom)
                bottom -= tabBarHeight;
            else
                top += tabBarHeight;
        }
    
    CGRect webViewFrame = CGRectMake(left, top, right - left, bottom - top);
    
    [self.webView setFrame:webViewFrame];
    
    // -----------------------------------------------------------------------------
    CGFloat iphonexfix = 0.0f;
    // NOTE: Following part again for tab bar plugin only
    if (@available(iOS 11.0, *)) {
        if ([[self webView] superview].safeAreaInsets.bottom > 0) iphonexfix = 1.0f;
        else iphonexfix = 0.0f;
    }
    
    
    if(tabBarShown)
    {
        if(tabBarAtBottom)
            [tabBar setFrame:CGRectMake(left, originalWebViewFrame.origin.y + originalWebViewFrame.size.height - tabBarHeight - iphonexfix, right - left, tabBarHeight)];
        
        else
            [tabBar setFrame:CGRectMake(left, originalWebViewFrame.origin.y, right - left, tabBarHeight)];
        
        NSLog(@"Screen height: %f", webViewFrame.size.height);
    }
}

- (UIColor*)colorStringToColor:(NSString*)colorStr
{
    NSArray *rgba = [colorStr componentsSeparatedByString:@","];
    return [UIColor colorWithRed:[[rgba objectAtIndex:0] intValue]/255.0f
                           green:[[rgba objectAtIndex:1] intValue]/255.0f
                            blue:[[rgba objectAtIndex:2] intValue]/255.0f
                           alpha:[[rgba objectAtIndex:3] intValue]/255.0f];
}

/**
 * Create a native tab bar at either the top or the bottom of the display.
 */
- (void)create:(CDVInvokedUrlCommand*)command
{
    if (tabBar) return;
    NSLog(@"Create TabBar");
    tabBar = [UITabBar new];
    [tabBar sizeToFit];
    tabBar.delegate = self;
    tabBar.multipleTouchEnabled   = NO;
    tabBar.autoresizesSubviews    = YES;
    tabBar.hidden                 = YES;
    tabBar.userInteractionEnabled = YES;
    tabBar.opaque = YES;
    tabBar.barStyle = UIBarStyleDefault;
    
    //[tabBar setBarTintColor:[UIColor colorWithRed:218.0/255.0 green:33.0/255.0 blue:39.0/255.0 alpha:1.0]];
    [tabBar setTintColor:[UIColor colorWithRed:218.0/255.0 green:33.0/255.0 blue:39.0/255.0 alpha:1.0]];
    //[tabBar setBackgroundColor:[UIColor colorWithRed:218.0/255.0 green:33.0/255.0 blue:39.0/255.0 alpha:1.0]];
    
    
    [tabBar setSelectedImageTintColor:[UIColor redColor]];
    
    self.webView.superview.autoresizesSubviews = YES;
    
    [self.webView.superview addSubview:tabBar];
}

-(void) init:(CDVInvokedUrlCommand*)command
{
    // Dummy function, see initWithWebView
}

/**
 * Show the tab bar after its been created.
 * @brief show the tab bar
 * @param arguments unused
 * @param options used to indicate options for where and how the tab bar should be placed
 * - \c height integer indicating the height of the tab bar (default: \c 49)
 * - \c position specifies whether the tab bar will be placed at the \c top or \c bottom of the screen (default: \c bottom)
 */
- (void)show:(CDVInvokedUrlCommand*)command
{
    if (!tabBar)
        [self create:nil];
    NSLog(@"Show TabBar");
    // if we are calling this again when its shown, reset
    if (!tabBar.hidden)
        return;
    NSLog(@"Show TabBar222");
    const id options = [command argumentAtIndex:0];
    
    if(options && options != [NSNull null])
    {
        id tabBarHeightOpt = [options objectForKey:@"height"];
        id positionOpt = [options objectForKey:@"position"];
        
        if(tabBarHeightOpt && tabBarHeightOpt != [NSNull null])
            tabBarHeight = [tabBarHeightOpt floatValue];
        
        if([positionOpt isKindOfClass:[NSString class]])
            tabBarAtBottom = ![positionOpt isEqualToString:@"top"];
    }
    NSLog(@"Show TabBar333");
    tabBar.tabBarAtBottom = tabBarAtBottom;
    
    if(tabBarHeight == 0)
        tabBarHeight = 49.0f;
    
    tabBar.hidden = NO;
    tabBar.alpha = 1;
    NSLog(@"Show TabBar444");
    [self correctWebViewFrame];
}

/**
 * Resize the tab bar (this should be called on orientation change)
 * @brief resize the tab bar on rotation
 * @param arguments unused
 * @param options unused
 */
- (void)resize:(CDVInvokedUrlCommand*)command
{
    [self correctWebViewFrame];
}

/**
 * Hide the tab bar
 * @brief hide the tab bar
 * @param arguments unused
 * @param options unused
 */
- (void)hide:(CDVInvokedUrlCommand*)command
    {
        
        if (tabBar.hidden) return;
        if (!tabBar) return;
        NSLog(@"HIDE TABBAR");
        if (!tabBar)
        [self create:nil];
        
        tabBar.alpha = 0;
        tabBar.hidden = YES;
        [self tabBarhided];
    }
    
-(void)tabBarhided
    {
        CGFloat left = self.webView.frame.origin.x;
        CGFloat right = left + self.webView.frame.size.width;
        CGFloat top = self.webView.frame.origin.y;
        CGFloat bottom = top + self.webView.frame.size.height;
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        switch (orientation)
        {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
            // No need to change width/height from original frame
            break;
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
            right = left + self.webView.frame.size.height + 20.0f;
            bottom = top + self.webView.frame.size.width - 20.0f;
            break;
            default:
            NSLog(@"Unknown orientation: %d", orientation);
            break;
        }
        
        CGRect webViewFrame = CGRectMake(left, top, right - left, bottom - top + tabBarHeight);
        
        [self.webView setFrame:webViewFrame];
    }

/**
 * Create a new tab bar item for use on a previously created tab bar.  Use ::showTabBarItems to show the new item on the tab bar.
 *
 * If the supplied image name is one of the labels listed below, then this method will construct a tab button
 * using the standard system buttons.  Note that if you use one of the system images, that the \c title you supply will be ignored.
 * - <b>Tab Buttons</b>
 *   - tabButton:More
 *   - tabButton:Favorites
 *   - tabButton:Featured
 *   - tabButton:TopRated
 *   - tabButton:Recents
 *   - tabButton:Contacts
 *   - tabButton:History
 *   - tabButton:Bookmarks
 *   - tabButton:Search
 *   - tabButton:Downloads
 *   - tabButton:MostRecent
 *   - tabButton:MostViewed
 * @brief create a tab bar item
 * @param arguments Parameters used to create the tab bar
 *  -# \c name internal name to refer to this tab by
 *  -# \c title title text to show on the tab, or null if no text should be shown
 *  -# \c image image filename or internal identifier to show, or null if now image should be shown
 *  -# \c tag unique number to be used as an internal reference to this button
 * @param options Options for customizing the individual tab item
 *  - \c badge value to display in the optional circular badge on the item; if nil or unspecified, the badge will be hidden
 */
- (void)createItem:(CDVInvokedUrlCommand*)command
{
    if (!tabBar)
        [self create:nil];
    
    const id options = [command argumentAtIndex:4];
    
    NSString  *name      = [command argumentAtIndex:0];
    NSString  *title     = [command argumentAtIndex:1];
    NSString  *imageName = [command argumentAtIndex:2];
    int tag              = [[command argumentAtIndex:3] intValue];
    
    UITabBarItem *item = nil;
    if ([imageName length] > 0)
    {
        UITabBarSystemItem systemItem = -1;
        if ([imageName isEqualToString:@"tabButton:More"])       systemItem = UITabBarSystemItemMore;
        else if ([imageName isEqualToString:@"tabButton:Favorites"])  systemItem = UITabBarSystemItemFavorites;
        else if ([imageName isEqualToString:@"tabButton:Featured"])   systemItem = UITabBarSystemItemFeatured;
        else if ([imageName isEqualToString:@"tabButton:TopRated"])   systemItem = UITabBarSystemItemTopRated;
        else if ([imageName isEqualToString:@"tabButton:Recents"])    systemItem = UITabBarSystemItemRecents;
        else if ([imageName isEqualToString:@"tabButton:Contacts"])   systemItem = UITabBarSystemItemContacts;
        else if ([imageName isEqualToString:@"tabButton:History"])    systemItem = UITabBarSystemItemHistory;
        else if ([imageName isEqualToString:@"tabButton:Bookmarks"])  systemItem = UITabBarSystemItemBookmarks;
        else if ([imageName isEqualToString:@"tabButton:Search"])     systemItem = UITabBarSystemItemSearch;
        else if ([imageName isEqualToString:@"tabButton:Downloads"])  systemItem = UITabBarSystemItemDownloads;
        else if ([imageName isEqualToString:@"tabButton:MostRecent"]) systemItem = UITabBarSystemItemMostRecent;
        else if ([imageName isEqualToString:@"tabButton:MostViewed"]) systemItem = UITabBarSystemItemMostViewed;
        if (systemItem != -1)
            item = [[UITabBarItem alloc] initWithTabBarSystemItem:systemItem tag:tag];
    }
    
    if (item == nil)
        item = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:imageName] tag:tag];
    
    if(options && options != [NSNull null])
    {
        id badgeOpt = [options objectForKey:@"badge"];
        
        if(badgeOpt && badgeOpt != [NSNull null])
            item.badgeValue = [badgeOpt stringValue];
    }
    
    [tabBarItems setObject:item forKey:name];
}


/**
 * Update an existing tab bar item to change its badge value.
 * @brief update the badge value on an existing tab bar item
 * @param arguments Parameters used to identify the tab bar item to update
 *  -# \c name internal name used to represent this item when it was created
 * @param options Options for customizing the individual tab item
 *  - \c badge value to display in the optional circular badge on the item; if nil or unspecified, the badge will be hidden
 */
- (void)updateItem:(CDVInvokedUrlCommand*)command
{
    if (!tabBar)
        [self create:nil];
    
    const NSDictionary *options = [command argumentAtIndex:1];
    
    if(!options)
    {
        NSLog(@"Missing options parameter in tabBar.updateItem");
        return;
    }
    
    NSString  *name = [command argumentAtIndex:0];
    UITabBarItem *item = [tabBarItems objectForKey:name];
    if(item)
    {
        id badgeOpt = [options objectForKey:@"badge"];
        
        if(badgeOpt && badgeOpt != [NSNull null])
            item.badgeValue = [NSString stringWithFormat:@"%@", badgeOpt];
        else
            item.badgeValue = nil;
    }
}


/**
 * Show previously created items on the tab bar
 * @brief show a list of tab bar items
 * @param arguments the item names to be shown
 * @param options dictionary of options, notable options including:
 *  - \c animate indicates that the items should animate onto the tab bar
 * @see createItem
 * @see create
 */
- (void)showItems:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Show Items");
    if (!tabBar)
        [self create:nil];
    NSLog(@"Arguments: %@", [command argumentAtIndex:0]);
    int i, count = [[command argumentAtIndex:0] count];
    NSLog(@"arguments: %d", count);
    //NSDictionary *options = nil;
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:MAX(count - 1, 1)];
    
    for(i = 0; i < count; ++i)
    {
        
        NSString *itemName = [[command argumentAtIndex:0] objectAtIndex:i];
        UITabBarItem *item = [tabBarItems objectForKey:itemName];
        if(item)
            [items addObject:item];
        else
            NSLog(@"Cannot show tab with unknown tag '%@'", itemName);
    }
    
    //BOOL animateItems = YES;
    //if(options && [options objectForKey:@"animate"])
    //animateItems = [(NSString*)[options objectForKey:@"animate"] boolValue];
    [tabBar setItems:items animated:NO];
}

/**
 * Manually select an individual tab bar item, or nil for deselecting a currently selected tab bar item.
 * @brief manually select a tab bar item
 * @param arguments the name of the tab bar item to select
 * @see createItem
 * @see showItems
 */
- (void)selectItem:(CDVInvokedUrlCommand*)command
{
    if (!tabBar)
        [self create:nil];
    
    NSString *itemName = [command argumentAtIndex:0];
    UITabBarItem *item = [tabBarItems objectForKey:itemName];
    if(item)
    {
        // Not called automatically when selectItem is called manually
        [self tabBar:tabBar didSelectItem:item];
        
        tabBar.selectedItem = item;
    }
    else
        tabBar.selectedItem = nil;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSString * jsCallBack = [NSString stringWithFormat:@"tabbar.onItemSelected(%d);", item.tag];
    NSLog(@"Item Selected with tab: %ld", (long)item.tag);
    
    UIWebView *uiwebview = nil;
    if ([self.webView isKindOfClass:[UIWebView class]]) {
        uiwebview = ((UIWebView*)self.webView);
    }
    //[uiwebview stringByEvaluatingJavaScriptFromString:jsCallBack];
    
    [self.commandDelegate evalJs:jsCallBack];
    
}

@end


@implementation UIView (NavBarCompat)

- (void)setTabBarAtBottom:(bool)tabBarAtBottom
{
    objc_setAssociatedObject(self, @"NavBarCompat_tabBarAtBottom", [NSNumber numberWithBool:tabBarAtBottom], OBJC_ASSOCIATION_COPY);
}

- (bool)tabBarAtBottom
{
    return [(objc_getAssociatedObject(self, @"NavBarCompat_tabBarAtBottom")) boolValue];
}

@end

