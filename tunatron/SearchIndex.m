//
//  SearchIndex.m
//  tunatron
//
//  Created by Alexander Solovyov on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchIndex.h"
#import "Track.h"

@implementation SearchIndex

@synthesize tracks = _tracks;
@synthesize indexes = _indexes;
@synthesize searchFields = _searchFields;

+ (id)withTracks:(NSMutableArray *)tracks {
    SearchIndex *new = [super new];
    new.tracks = tracks;
    NSInteger len = tracks.count;
    new.searchFields = [NSArray arrayWithObjects:
                        @"artist",
                        @"albumArtist",
                        @"year",
                        @"album",
                        @"name",
                        nil];
    new.indexes = [NSArray arrayWithObjects:
                   [NSMutableArray arrayWithCapacity:len],
                   [NSMutableArray arrayWithCapacity:len],
                   [NSMutableArray arrayWithCapacity:len],
                   [NSMutableArray arrayWithCapacity:len],
                   [NSMutableArray arrayWithCapacity:len],
                   nil];
    [new generateIndex];
    return new;
}

- (void)generateIndex {
    NSString *field;
    NSMutableArray *index;

    for (int i = 0; i < self.searchFields.count; i++) {
        field = [self.searchFields objectAtIndex:i];
        index = [self.indexes objectAtIndex:i];

        [self.tracks
         enumerateObjectsUsingBlock:^(Track *track, NSUInteger idx, BOOL *stop) {
             id val = [track valueForKey:field];
             if (val == nil) {
                 [index addObject:@""];
             } else {
                 [index addObject:[NSString stringWithFormat:@"%@", val]];
             }
         }];
    }
}

- (BOOL)term:(NSString *)term contains:(NSString *)needle {
    unichar c;
    int idx = -1;
    int tl = term.length;
    int nl = needle.length;

    for (int i = 0; i < nl; i++) {
        c = [needle characterAtIndex:i];
        NSRange rng = [term
                       rangeOfString:[NSString stringWithFormat:@"%c", c]
                       options:NSCaseInsensitiveSearch | NSWidthInsensitiveSearch
                       range:NSMakeRange(idx + 1, tl - idx - 1)];
        if (rng.location == NSNotFound) {
            return NO;
        }
        idx = rng.location;
    }

    return YES;
}

- (NSArray *)search:(NSString *)needle {
    if (needle == nil || needle.length == 0) {
        return self.tracks;
    }

    NSArray *words = [needle componentsSeparatedByString:@" "];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:words.count];
    NSMutableSet *found;

    for (NSString *word in words) {
        found = [NSMutableSet new];
        [results addObject:found];

        for (NSMutableArray *index in self.indexes) {
            for (int i = 0; i < index.count; i++) {
                NSString * term = [index objectAtIndex:i];
                if ([self term:term contains:word]) {
                    [found addObject:[NSNumber numberWithInt:i]];
                }
            }
        }
    };

    found = [results objectAtIndex:0];
    for (int i = 1; i < results.count; i++) {
        [found intersectSet:[results objectAtIndex:i]];
    }

    NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:found.count];
    for (NSNumber *x in found) {
        [tracks addObject:[self.tracks objectAtIndex:x.intValue]];
    }

    return tracks;
}

@end
