//
//  STTorrent.m
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/25/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import "STTorrent.h"

#import "STFileEntry.h"
#import "STTorrentManager.h"

#import "NSData+Hex.h"

@interface STTorrent ()
@property (readwrite, strong, nonatomic) NSData *infoHash;
@property (readwrite, strong, nonatomic) NSString *name;
@property (readwrite, nonatomic) STTorrentState state;
@property (readwrite, nonatomic) double progress;
@property (readwrite, nonatomic) NSUInteger numberOfPeers;
@property (readwrite, nonatomic) NSUInteger numberOfSeeds;
@property (readwrite, nonatomic) NSUInteger downloadRate;
@property (readwrite, nonatomic) NSUInteger uploadRate;
@property (readwrite, nonatomic) BOOL hasMetadata;
@end

@implementation STTorrent

- (NSString *)infoHashString {
    return [self.infoHash hexString];
}

@end
