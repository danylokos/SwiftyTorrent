//
//  STTorrent.h
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/25/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STTorrentState.h"

NS_ASSUME_NONNULL_BEGIN

@class STFileEntry;

NS_SWIFT_NAME(Torrent)
@interface STTorrent : NSObject
@property (readonly, strong, nonatomic) NSData *infoHash;
@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, nonatomic) STTorrentState state;
@property (readonly, nonatomic) double progress;
@property (readonly, nonatomic) NSUInteger numberOfPeers;
@property (readonly, nonatomic) NSUInteger numberOfSeeds;
@property (readonly, nonatomic) NSUInteger downloadRate;
@property (readonly, nonatomic) NSUInteger uploadRate;
@property (readonly, nonatomic) BOOL hasMetadata;

#ifdef DEBUG
+ (instancetype)randomStubTorrent;
#endif

@end
NS_ASSUME_NONNULL_END
