//
//  STFileEntry.m
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/15/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import "STFileEntry.h"

@interface STFileEntry ()
@property (readwrite, strong, nonatomic) NSString *name;
@property (readwrite, strong, nonatomic) NSString *path;
@property (readwrite, nonatomic) NSUInteger size;
@end

@implementation STFileEntry

@end
