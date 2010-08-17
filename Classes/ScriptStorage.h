// -*- mode:objc -*-
//
//  ScriptStorage.h
//  BCMobile
//
//  Created by Hayoung Jeong on 6/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ScriptStorage : NSObject {

}

- (NSArray *)scripts;
- (NSDictionary *)script:(NSInteger)id;
- (BOOL)removeScript:(NSInteger)scriptID;
- (NSInteger)addScript:(NSDictionary *)script;
- (void)replaceScript:(NSDictionary *)script forid:(NSInteger)scriptID;
- (NSDictionary *)scriptForIndexPath:(NSIndexPath *)indexPath;
- (NSDictionary *)scriptForSection:(NSInteger)section row:(NSInteger)row;
- (NSInteger)idForIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)idForSection:(NSInteger)section row:(NSInteger)row;
@end
