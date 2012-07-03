//
//  Song.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Song.h"

@implementation Song

@synthesize artist;
@synthesize name;

- (id)initWithArtist:(NSString *)theArtist andName:(NSString *)theName {
    self = [super init];
    self.artist = theArtist;
    self.name = theName;
    
    return self;
}

- (NSString *)stringForColumn:(NSTableColumn *)column {
    return [self valueForKey:[column identifier]];
}

@end
