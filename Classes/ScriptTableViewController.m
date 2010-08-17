//
//  ScriptTableViewController.m
//  BCMobile
//
//  Created by Hayoung Jeong on 5/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScriptStorage.h"
#import "ScriptTableViewController.h"
#import "ScriptEditViewController.h"
#import "ScriptInfoViewController.h"
#import "ScriptTitleViewController.h"
#import "ConsoleViewController.h"
#import "BCWrapper.h"

@implementation ScriptTableViewController

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
  [super loadView];

  // Toolbar setup
  UIBarButtonItem *flexSpaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

  UIBarButtonItem *infoItem = [[[UIBarButtonItem alloc] initWithTitle:@"Information"
								style:UIBarButtonItemStyleBordered
							       target:self
							       action:@selector(showInfo:)] autorelease];

  UIBarButtonItem *renameItem = [[[UIBarButtonItem alloc] initWithTitle:@"Rename"
								  style:UIBarButtonItemStyleBordered
								 target:self
								 action:@selector(rename:)] autorelease];

  UIBarButtonItem *executeItem = [[[UIBarButtonItem alloc] initWithTitle:@"Execute"
								   style:UIBarButtonItemStyleBordered
								  target:self
								  action:@selector(execute:)] autorelease];

  self.toolbarItems = [NSArray arrayWithObjects:flexSpaceItem, infoItem, renameItem, executeItem, flexSpaceItem, nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  UIBarButtonItem *composeButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(compose:)] autorelease];
  
  self.navigationItem.rightBarButtonItem = composeButton;
  storage = [[ScriptStorage alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:NO
					   animated:YES];
  [self.navigationController setToolbarHidden:NO
				     animated:YES];

  [(UITableView *)self.view reloadData];
  self.navigationItem.title = [NSString stringWithFormat:@"Scripts (%d)", [[[NSUserDefaults standardUserDefaults] objectForKey:@"scripts"] count]];

  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return ((interfaceOrientation == UIInterfaceOrientationPortrait) ||
	  (interfaceOrientation == UIInterfaceOrientationLandscapeRight) ||
	  (interfaceOrientation == UIInterfaceOrientationLandscapeLeft));
}

- (void)setBC:(BCWrapper *)_bc {
  bc = [_bc retain];
}

- (BCWrapper *)bc {
  return bc;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[storage scripts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"Cell";
    
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
				   reuseIdentifier:CellIdentifier] autorelease];
  }

  NSDictionary *script = [storage scriptForIndexPath:indexPath];

  cell.textLabel.text = [script objectForKey:@"title"];
  NSDate *date = [script objectForKey:@"created"];
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  [formatter setDateStyle:NSDateFormatterShortStyle];
  
  NSString *lock = nil;
  if ([[script objectForKey:@"locked"] boolValue])
    lock = @"r-";
  else
    lock = @"rw";

  NSString *startup = nil;
  if ([[script objectForKey:@"loadOnStartup"] boolValue])
    startup = @"s";
  else
    startup = @"-";

  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@ %@", lock, startup, [formatter stringFromDate:date]];

  [formatter release];

  cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

  return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    BOOL deleted = [storage removeScript:[storage idForIndexPath:indexPath]];

    self.navigationItem.title = [NSString stringWithFormat:@"Scripts (%d)", [[storage scripts] count]];

    if (deleted)
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot remove this script"
						      message:@"This scripts is locked. To remove it you shoud unlock it."
						     delegate:nil
					    cancelButtonTitle:@"OK"
					    otherButtonTitles:nil];
      [alert show];
    }
  }   
  else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}
*/

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  ScriptEditViewController *detailViewController = [[ScriptEditViewController alloc] initWithNibName:@"ScriptEditViewController" bundle:nil];

  detailViewController.scriptID = [storage idForIndexPath:indexPath];
  [detailViewController setBC:[self bc]];

  [self.navigationController pushViewController:detailViewController
				       animated:YES];
  [detailViewController release];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
    
  // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
}


- (void)dealloc {
  [storage release];
  [bc release];
  [super dealloc];
}

#pragma mark -
#pragma mark custom functions

- (IBAction)compose:(id)sender {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setTimeStyle:NSDateFormatterNoStyle];
  [formatter setDateStyle:NSDateFormatterMediumStyle];
  
  NSString *title = [NSString stringWithFormat:@"untitled %@", [formatter stringFromDate:[NSDate date]]];
  [formatter release];

  NSDictionary *newItem = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", [NSDate date], @"created", [NSDate date], @"modified", [NSNumber numberWithBool:NO], @"loadOnStartup", @"", @"code", nil];
  NSInteger scriptID = [storage addScript:newItem];

  [(UITableView *)self.view reloadData];

  ScriptEditViewController *editViewController = [[ScriptEditViewController alloc] initWithNibName:@"ScriptEditViewController" bundle:nil];

  editViewController.scriptID = scriptID;
  [editViewController setBC:[self bc]];

  [self.navigationController pushViewController:editViewController
				       animated:YES];
}

- (IBAction)showInfo:(id)sender {
  NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

  if ([indexPath length] == 0)
    return;

  ScriptInfoViewController *detailViewController = [[ScriptInfoViewController alloc] initWithNibName:@"ScriptInfoViewController" bundle:nil];

  detailViewController.scriptID = [storage idForIndexPath:indexPath];

  [self.navigationController pushViewController:detailViewController
				       animated:YES];
  [detailViewController release];
  [(UITableView *)self.view reloadData];
}

- (IBAction)rename:(id)sender {
  NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

  if ([indexPath length] == 0)
    return;

  ScriptTitleViewController *detailViewController = [[ScriptTitleViewController alloc] initWithNibName:@"ScriptTitleViewController" bundle:nil];
  detailViewController.scriptID = [storage idForIndexPath:indexPath];

  [self.navigationController pushViewController:detailViewController
			  animated:YES];

  [detailViewController release];
}

- (IBAction)execute:(id)sender {
  NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

  if ([indexPath length] == 0)
    return;

  ConsoleViewController *detailViewController = [[ConsoleViewController alloc] initWithNibName:@"ConsoleViewController" bundle:nil];


  detailViewController.scriptID = [storage idForIndexPath:indexPath];
  [detailViewController setBC:[self bc]];

  [self.navigationController pushViewController:detailViewController
				       animated:YES];
  [detailViewController release];
}

@end

