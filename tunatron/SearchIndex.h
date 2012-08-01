//
//  SearchIndex.h
//  tunatron
//
//  Created by Alexander Solovyov on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchIndex : NSObject

+ withTracks:(NSMutableArray *)tracks;

- (NSArray *)search:(NSString *)needle;

@property (weak) NSMutableArray *tracks;
@property (strong) NSArray *indexes;
@property (strong) NSArray *searchFields;

@end
