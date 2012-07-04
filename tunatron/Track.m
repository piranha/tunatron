//
//  Track.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Track.h"

@implementation Track

@synthesize artist = _artist;
@synthesize year = _year;
@synthesize album = _album;
@synthesize name = _name;

+ (id)withDictionary:(NSDictionary *)data {
    Track * the = [super new];
    the.artist = [data objectForKey:@"Artist"];
    the.year = [data objectForKey:@"Year"];
    the.album = [data objectForKey:@"Album"];
    the.name = [data objectForKey:@"Name"];

    return the;
}

- (NSComparisonResult)compare:(Track *)other {
    return [self.artist compare:other.artist];
}

- (BOOL *)match:(NSString *)value {
    return FALSE;
}

- (NSString *)stringForColumn:(NSTableColumn *)column {
    return [self valueForKey:[column identifier]];
}

@end
