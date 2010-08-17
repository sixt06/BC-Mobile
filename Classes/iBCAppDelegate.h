// -*- mode:objc -*-
//
//  iBCAppDelegate.h
//  iBC
//
//  Created by Ha-young Jeong on 12/30/09.
//  Copyright Donut System LSI 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLIViewController;
@class BCWrapper;

@interface iBCAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow          *window;
  CLIViewController *CLIViewController;
  BCWrapper         *bc;
}

@property (nonatomic, retain) IBOutlet UIWindow         *window;
@property (nonatomic, retain) IBOutlet UIViewController *CLIViewController;
@property (nonatomic, retain) BCWrapper *bc;

@end

