//
//  SearchResult.m
//  tunatron
//
//  Created by Alexander Solovyov on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScoredTrack.h"

@class Track;

@implementation ScoredTrack

@synthesize track = _track;
@synthesize score = _score;

+ (id)withScore:(CGFloat)score andTrack:(Track *)track {
    ScoredTrack * new = [super new];
    new.score = score;
    new.track = track;
    
    return new;
}

@end
