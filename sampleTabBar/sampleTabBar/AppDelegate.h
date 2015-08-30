//
//  AppDelegate.h
//  sampleTabBar
//
//  Created by Wes Cratty on 1/2/15.
//  Copyright (c) 2015 Wes Cratty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>



//static bool askedForResults = false;


@interface NSArray (StaticArray)
+(NSMutableArray *)sharedInstance;


@end


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

