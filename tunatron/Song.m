//
//  Song.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Song.h"

@implementation Song

@synthesize artist = _artist;
@synthesize name = _name;

+ (id)newWithArtist:(NSString *)artist name:(NSString *)name {
    Song * newSong = [super new];
    newSong.artist = artist;
    newSong.name = name;
    return newSong;
}

- (NSString *)stringForColumn:(NSTableColumn *)column {
    return [self valueForKey:[column identifier]];
}

@end
