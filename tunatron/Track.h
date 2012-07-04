//
//  Track.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject

+ withDictionary:(NSDictionary *)data;
- (NSComparisonResult)compare:(Track *)other;
- (BOOL)matches:(NSString *)value;
- (NSString *)stringForColumn:(NSTableColumn *)column;

@property (copy) NSString *artist;
@property (copy) NSString *year;
@property (copy) NSString *album;
@property (copy) NSString *cd;
@property (copy) NSString *number;
@property (copy) NSString *name;

@property (copy) NSString *lower;

@end
