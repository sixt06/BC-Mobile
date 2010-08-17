//
//  ScriptStorage.m
//  BCMobile
//
//  Created by Hayoung Jeong on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScriptStorage.h"

@implementation ScriptStorage

- (NSArray *)scripts {
  return [[NSUserDefaults standardUserDefaults] objectForKey:@"scripts"];
}

- (BOOL)removeScript:(NSInteger)scriptID {
  if ([[[self script:scriptID] objectForKey:@"locked"] boolValue])
    return NO;

  NSMutableArray *scripts = [NSMutableArray arrayWithArray:[self scripts]];
  [scripts removeObjectAtIndex:scriptID];
  [[NSUserDefaults standardUserDefaults] setObject:scripts forKey:@"scripts"];
  [[NSUserDefaults standardUserDefaults] synchronize];

  return YES;
}

- (NSInteger)addScript:(NSDictionary *)script {
  NSMutableArray *scripts = [NSMutableArray arrayWithArray:[self scripts]];
  [scripts addObject:script];
  [[NSUserDefaults standardUserDefaults] setObject:scripts forKey:@"scripts"];
  [[NSUserDefaults standardUserDefaults] synchronize];

  return [[self scripts] count] - 1;
}

- (void)replaceScript:(NSDictionary *)script forid:(NSInteger)scriptID {
  NSMutableArray *scripts = [NSMutableArray arrayWithArray:[self scripts]];

  [scripts removeObjectAtIndex:scriptID];
  [scripts insertObject:script atIndex:scriptID];

  [[NSUserDefaults standardUserDefaults] setObject:scripts forKey:@"scripts"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)script:(NSInteger)id {
  return [[self scripts] objectAtIndex:id];
}

- (NSDictionary *)scriptForIndexPath:(NSIndexPath *)indexPath {
  return [self scriptForSection:[indexPath section] row:[indexPath row]];
}

- (NSDictionary *)scriptForSection:(NSInteger)section row:(NSInteger)row {
  NSInteger index = [self idForSection:section row:row];
  return [[self scripts] objectAtIndex:index];
}

- (NSInteger)idForIndexPath:(NSIndexPath *)indexPath {
  return [self idForSection:[indexPath section] row:[indexPath row]];
}

- (NSInteger)idForSection:(NSInteger)section row:(NSInteger)row {
  return row;
}

@end
