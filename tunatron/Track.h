//
//  Track.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/4/12.
//  Copyright (c) 2012 Witty Bullet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ScoredTrack;

@interface Track : NSObject

+ withDictionary:(NSDictionary *)data;
- (NSComparisonResult)compare:(Track *)other;
- (BOOL)matches:(NSString *)value;
- (CGFloat)score:(NSString *)abbreviation;
- (ScoredTrack *)scoredTrack:(NSString *)abbreviation;
- (NSString *)stringForColumn:(NSTableColumn *)column;

@property (copy) NSString *id;
@property (copy) NSString *artist;
@property (copy) NSString *albumArtist;
@property (copy) NSString *year;
@property (copy) NSString *album;
@property (copy) NSString *cd;
@property int number;
@property (copy) NSString *name;

@property (copy) NSString *repr;
@property (copy) NSString *lower;

@end
