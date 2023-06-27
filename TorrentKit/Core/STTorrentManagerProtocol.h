//
//  STTorrentManagerProtocol.h
//  TorrentKit
//
//  Created by Danylo Kostyshyn on 17.06.2021.
//  Copyright © 2021 Danylo Kostyshyn. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class STTorrent, STFileEntry;
@protocol STTorrentManagerDelegate;

NS_SWIFT_NAME(TorrentManagerProtocol)
@protocol STTorrentManagerProtocol
@property (readonly, nonatomic, getter=isSessionActive) BOOL sessionActive;

- (void)addDelegate:(id<STTorrentManagerDelegate>)delegate
NS_SWIFT_NAME(addDelegate(_:));

- (void)removeDelegate:(id<STTorrentManagerDelegate>)delegate
NS_SWIFT_NAME(removeDelegate(_:));

- (void)restoreSession;

- (BOOL)addTorrent:(id<STDownloadable>)torrent
NS_SWIFT_NAME(add(_:));

- (BOOL)removeTorrentWithInfoHash:(NSData *)infoHash deleteFiles:(BOOL)deleteFiles;

- (BOOL)pauseTorrentWithInfoHash:(NSData *)infoHash;

- (BOOL)resumeTorrentWithInfoHash:(NSData *)infoHash;

- (BOOL)removeAllTorrentsWithFiles:(BOOL)deleteFiles;

- (NSArray<STTorrent *> *)torrents;

- (void)openURL:(NSURL *)URL;

- (NSArray<STFileEntry *> *)filesForTorrentWithHash:(NSData *)infoHash;

- (NSURL *)downloadsDirectoryURL;

@end

NS_ASSUME_NONNULL_END
