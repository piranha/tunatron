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
                 [index addObject:[[NSString stringWithFormat:@"%@", val]
                                   lowercaseString]];
             }
         }];
    }
}

- (BOOL)term:(NSString *)term contains:(unichar *)needleb {
    int idx = -1;
    int tl = term.length;
    int j;
    BOOL found;

    unichar termb[tl + 1];
    [term getCharacters:termb range:NSMakeRange(0, tl)];
    termb[tl] = 0;

    for (unichar *c = needleb; *c; c++) {
        found = NO;
        for (j = idx + 1; termb[j]; j++) {
            if (*c == termb[j]) {
                idx = j;
                found = YES;
                break;
            }
        }
        if (!found) {
            return NO;
        }
    }
    return YES;
}

- (NSArray *)search:(NSString *)needle {
    if (needle == nil || needle.length == 0) {
        return self.tracks;
    }

    NSArray *words = [[needle lowercaseString] componentsSeparatedByString:@" "];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:words.count];

    [words enumerateObjectsUsingBlock:^(NSString *word, NSUInteger idx, BOOL *stop) {
        NSMutableSet *found = [NSMutableSet new];
        [results addObject:found];

        int l = word.length;
        unichar needleb[l + 1];
        [word getCharacters:needleb range:NSMakeRange(0, l)];
        needleb[l] = 0;

        for (NSMutableArray *index in self.indexes) {
            for (int i = 0; i < index.count; i++) {
                NSString * term = [index objectAtIndex:i];
                if ([self term:term contains:needleb]) {
                    [found addObject:[NSNumber numberWithInt:i]];
                }
            }
        }
    }];

    NSMutableSet *found = [results objectAtIndex:0];
    for (int i = 1; i < results.count; i++) {
        [found intersectSet:[results objectAtIndex:i]];
    }

    NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:found.count];
    for (NSNumber *x in found) {
        [tracks addObject:[self.tracks objectAtIndex:x.intValue]];
    }

    [tracks
     sortUsingComparator:^NSComparisonResult(Track *t1, Track *t2) {
         return [t1 compare:t2];
     }];

    return tracks;
}

@end
