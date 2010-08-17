// -*- mode:objc -*-
//
//  HelpViewController.h
//  BCMobile
//
//  Created by Hayoung Jeong on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController {
  UIWebView *webView;
}

@property (nonatomic, assign) IBOutlet UIWebView *webView;

- (IBAction)gotoTOC:(id)sender;

@end
