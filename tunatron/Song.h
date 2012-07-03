//
//  Song.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject

+ newWithArtist:(NSString *)artist name:(NSString *)name;
- (id)initWithArtist:(NSString *)artist andName:(NSString *)name;
- (NSString *)stringForColumn:(NSTableColumn *)column;

@property (copy) NSString *artist;
@property (copy) NSString *name;

@end
