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
- (BOOL *)match:(NSString *)value;
- (NSString *)stringForColumn:(NSTableColumn *)column;

@property (copy) NSString *artist;
@property (copy) NSString *year;
@property (copy) NSString *album;
@property (copy) NSString *name;

@end
