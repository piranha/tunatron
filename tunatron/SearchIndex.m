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
    new.searchFields = @[@"artist", @"albumArtist", @"year", @"album", @"name"];
    new.indexes = @[[NSMutableArray arrayWithCapacity:len],
        [NSMutableArray arrayWithCapacity:len],
        [NSMutableArray arrayWithCapacity:len],
        [NSMutableArray arrayWithCapacity:len],
        [NSMutableArray arrayWithCapacity:len]];
    [new generateIndex];
    return new;
}

- (void)generateIndex {
    NSString *field;
    NSMutableArray *index;

    for (int i = 0; i < self.searchFields.count; i++) {
        field = self.searchFields[i];
        index = self.indexes[i];

        [self.tracks
         enumerateObjectsUsingBlock:^(Track *track, NSUInteger idx, BOOL *stop) {
             id val = track[field];
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
    NSUInteger tl = term.length;
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

        NSUInteger l = word.length;
        unichar needleb[l + 1];
        [word getCharacters:needleb range:NSMakeRange(0, l)];
        needleb[l] = 0;

        for (NSMutableArray *index in self.indexes) {
            for (int i = 0; i < index.count; i++) {
                NSString * term = index[i];
                if ([self term:term contains:needleb]) {
                    [found addObject:@(i)];
                }
            }
        }
    }];

    NSMutableSet *found = results[0];
    for (int i = 1; i < results.count; i++) {
        [found intersectSet:results[i]];
    }

    NSMutableArray *tracks = [NSMutableArray arrayWithCapacity:found.count];
    for (NSNumber *x in found) {
        [tracks addObject:self.tracks[x.intValue]];
    }

    [tracks
     sortUsingComparator:^NSComparisonResult(Track *t1, Track *t2) {
         return [t1 compare:t2];
     }];

    return tracks;
}

@end
