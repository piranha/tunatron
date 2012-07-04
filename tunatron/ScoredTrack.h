//
//  SearchResult.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Track;

@interface ScoredTrack : NSObject

+ withScore:(CGFloat)score andTrack:(Track *) track;

@property (weak) Track* track;
@property CGFloat score;

@end
