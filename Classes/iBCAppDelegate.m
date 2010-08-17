//
//  iBCAppDelegate.m
//  iBC
//
//  Created by Ha-young Jeong on 12/30/09.
//  Copyright Donut System LSI 2009. All rights reserved.
//

#import "iBCAppDelegate.h"
#import "CLIViewController.h"
#import "BCWrapper.h"

@implementation iBCAppDelegate

@synthesize window;
@synthesize CLIViewController;
@synthesize bc;

+ (void)initialize {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *appDefaults = [[NSMutableDictionary alloc] init];

  // default script
  NSArray *scriptList = [NSArray arrayWithObjects:@"scientific_constants.bc", @"extensions.bc", nil];
  NSMutableArray *scripts = [[NSMutableArray alloc] init];

  for (id script in scriptList) {
    NSString *code = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:script ofType:nil] encoding:NSASCIIStringEncoding error:nil];

    [scripts addObject:[NSDictionary dictionaryWithObjectsAndKeys:script, @"title", [NSDate date], @"created", [NSDate date], @"modified", code, @"code", [NSNumber numberWithBool:YES], @"loadOnStartup", [NSNumber numberWithBool:YES], @"looked", nil]];
  }

  [appDefaults setObject:scripts forKey:@"scripts"];
  [scripts release];

  // verbose mode
  [appDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"ignoreWarning"];
  [appDefaults setObject:[NSNumber numberWithInt:10] forKey:@"scale"];
  [appDefaults setObject:[NSNumber numberWithInt:10] forKey:@"ibase"];
  [appDefaults setObject:[NSNumber numberWithInt:10] forKey:@"obase"];

  [defaults registerDefaults:appDefaults];
  [appDefaults release];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
  self.bc = [[BCWrapper alloc] init];

  self.CLIViewController = [[CLIViewController alloc] initWithNibName:@"CLIViewController" bundle:nil];
  [(CLIViewController *)self.CLIViewController setBC:bc];

  UINavigationController *main = [[UINavigationController alloc] initWithRootViewController:self.CLIViewController];

  [window addSubview:main.view];

  CGAffineTransform myTransform = CGAffineTransformMakeTranslation(0.0, 20.0);
  [self.CLIViewController.view setTransform:myTransform];

  [window makeKeyAndVisible];
}

- (void)dealloc {
  [CLIViewController release];
  [bc release];

  [window release];
  [super dealloc];
}

@end
