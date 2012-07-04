//
//  NSString+Scoring.h
//  tunatron
//
//  Created by Alexander Solovyov on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Scoring)

- (CGFloat) scoreForAbbreviation:(NSString *)abbreviation;
- (CGFloat) scoreForAbbreviation:(NSString *)abbreviation 
                         hitMask:(NSMutableIndexSet *)mask;
- (CGFloat) scoreForAbbreviation:(NSString *)abbreviation 
                         inRange:(NSRange)searchRange 
                       fromRange:(NSRange)abbreviationRange 
                         hitMask:(NSMutableIndexSet *)mask;

@end
