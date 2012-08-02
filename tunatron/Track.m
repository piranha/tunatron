//
//  Track.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/4/12.
//  Copyright (c) 2012 Witty Bullet. All rights reserved.
//

#import "Track.h"
#import "ScoredTrack.h"

@implementation Track

@synthesize id = _id;
@synthesize artist = _artist;
@synthesize albumArtist = _albumArtist;
@synthesize year = _year;
@synthesize album = _album;
@synthesize cd = _cd;
@synthesize number = _number;
@synthesize name = _name;
@synthesize repr = _repr;

+ (id)withDictionary:(NSDictionary *)data {
    Track * new = [super new];

    new.id = [data objectForKey:@"Persistent ID"];
    new.artist = [data objectForKey:@"Artist"];
    new.albumArtist = [data objectForKey:@"Album Artist"];
    new.year = [data objectForKey:@"Year"];
    new.album = [data objectForKey:@"Album"];
    new.cd = [data objectForKey:@"Disc Number"];
    new.number = [[data objectForKey:@"Track Number"] intValue];
    new.name = [data objectForKey:@"Name"];

    if ([data objectForKey:@"Compilation"] && (new.albumArtist == nil)) {
        new.albumArtist = @"Various Artists";
    }

    new.repr = [new representation];

    return new;
}

- (NSString *)representation {
    return [NSString stringWithFormat:@"%@ %d %@ %@ %02d %@",
            self.albumArtist ? self.albumArtist : self.artist,
            self.year.intValue,
            self.album,
            self.cd,
            self.number,
            self.name];
}

- (NSString *)shortRepr {
    return [NSString stringWithFormat:@"%@ - %@ - %@",
            self.albumArtist ? self.albumArtist : self.artist,
            self.album,
            self.name];
}

- (NSComparisonResult)compare:(Track *)other {
    return [self.repr compare:other.repr];
}

- (NSString *)stringForColumn:(NSTableColumn *)column {
    return [self valueForKey:[column identifier]];
}

@end
