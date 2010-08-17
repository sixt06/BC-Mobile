//
//  HelpViewController.m
//  BCMobile
//
//  Created by Hayoung Jeong on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController

@synthesize webView;

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.title = @"Help";

  UIBarButtonItem *tocButton = [[UIBarButtonItem alloc] initWithTitle:@"TOC"
								style:UIBarButtonItemStylePlain
							       target:self
							       action:@selector(gotoTOC:)];

  self.navigationItem.rightBarButtonItem = tocButton;

  NSURL *html = [[NSBundle mainBundle] URLForResource:@"help"
					withExtension:@"html"];

  [self.webView loadRequest:[NSURLRequest requestWithURL:html]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
	  (interfaceOrientation == UIInterfaceOrientationLandscapeRight) ||
	  (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
  [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:NO
					   animated:YES];
  [self.navigationController setToolbarHidden:YES
				     animated:YES];

  [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark action method

- (IBAction)gotoTOC:(id)sender {
  NSURL *baseURL = [[NSBundle mainBundle] URLForResource:@"help"
					   withExtension:@"html"];

  NSURL *html = [NSURL URLWithString:@"#TOC"
		       relativeToURL:baseURL];

  [self.webView loadRequest:[NSURLRequest requestWithURL:html]];
}

#pragma mark -
#pragma mark UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  NSURL *url = [request URL];
  if (![[url scheme] isEqual:@"file"]) {
    [[UIApplication sharedApplication] openURL:url];
    return NO;
  }

  return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  // report the error inside the webview
  NSString* errorString = [NSString stringWithFormat:@"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
				    error.localizedDescription];
  [self.webView loadHTMLString:errorString baseURL:nil];
}

@end
