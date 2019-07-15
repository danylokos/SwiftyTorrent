//
//  STTorrentManager.h
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/24/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STDownloadable.h"

NS_ASSUME_NONNULL_BEGIN

@class STTorrentManager, STTorrent, STFile;

NS_SWIFT_NAME(TorrentManagerDelegate)
@protocol STTorrentManagerDelegate <NSObject>

- (void)torrentManagerDidReceiveUpdate:(STTorrentManager *)manager;

@end

NS_SWIFT_NAME(TorrentManager)
@interface STTorrentManager : NSObject
@property (readonly, nonatomic, getter=isSessionActive) BOOL sessionActive;

+ (instancetype)sharedInstance
NS_SWIFT_NAME(shared());

- (instancetype)init
NS_UNAVAILABLE;

- (void)addDelegate:(id<STTorrentManagerDelegate>)delegate
NS_SWIFT_NAME(addDelegate(_:));

- (void)removeDelegate:(id<STTorrentManagerDelegate>)delegate
NS_SWIFT_NAME(removeDelegate(_:));

- (void)test;

- (void)restoreSession;

- (BOOL)addTorrent:(id<STDownloadable>)torrent
NS_SWIFT_NAME(add(_:));

- (BOOL)removeTorrentWithInfoHash:(NSData *)infoHash
NS_SWIFT_NAME(remove(_:));

- (NSArray<STTorrent *> *)torrents;

- (void)openURL:(NSURL *)URL;

- (NSArray<STFile *> *)filesForTorrentWithHash:(NSData *)infoHash;

@end

NS_ASSUME_NONNULL_END
