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

- (id)initWithArtist:(NSString *)artist andName:(NSString *)name {
    if (!(self = [super init])) return self;

    self.artist = artist;
    self.name = name;
    return self;
}

- (NSString *)stringForColumn:(NSTableColumn *)column {
    return [self valueForKey:[column identifier]];
}

@end
