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
@synthesize cd = _cd;
@synthesize number = _number;
@synthesize name = _name;

@synthesize lower = _lower;

+ (id)withDictionary:(NSDictionary *)data {
    Track * new = [super new];
    new.artist = [data objectForKey:@"Artist"];
    new.year = [data objectForKey:@"Year"];
    new.album = [data objectForKey:@"Album"];
    new.cd = [data objectForKey:@"Disc Number"];
    new.number = [data objectForKey:@"Track Number"];
    new.name = [data objectForKey:@"Name"];

    new.lower = [[new repr] lowercaseString];

    return new;
}

- (NSString *)repr {
    return [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",
            self.artist,
            self.year,
            self.album,
            self.cd,
            self.number,
            self.name];
}

- (NSComparisonResult)compare:(Track *)other {
    return [[self repr] compare:[other repr]];
}

- (BOOL)matches:(NSString *)value {
    NSRange result = [self.lower rangeOfString:value];
    return result.location != NSNotFound;
}

- (NSString *)stringForColumn:(NSTableColumn *)column {
    return [self valueForKey:[column identifier]];
}

@end
