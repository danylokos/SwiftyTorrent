//
//  STTorrentManager.h
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/24/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STDownloadable.h"
#import "STTorrentManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, STErrorCode) {
    STErrorCodeBadFile,
    STErrorCodeUndefined
} NS_SWIFT_NAME(STErrorCode);

@class STTorrentManager, STTorrent, STFileEntry;

NS_SWIFT_NAME(TorrentManagerDelegate)
@protocol STTorrentManagerDelegate <NSObject>

- (void)torrentManager:(STTorrentManager *)manager didAddTorrent:(STTorrent *)torrent;

- (void)torrentManager:(STTorrentManager *)manager didRemoveTorrentWithHash:(NSData *)hashData;

- (void)torrentManager:(STTorrentManager *)manager didReceiveUpdateForTorrent:(STTorrent *)torrent;

- (void)torrentManager:(STTorrentManager *)manager didErrorOccur:(NSError *)error;

@end

NS_SWIFT_NAME(TorrentManager)
@interface STTorrentManager : NSObject <STTorrentManagerProtocol>
@property (readonly, nonatomic, getter=isSessionActive) BOOL sessionActive;

+ (instancetype)sharedInstance
NS_SWIFT_NAME(shared());

- (instancetype)init
NS_UNAVAILABLE;

- (void)addDelegate:(id<STTorrentManagerDelegate>)delegate
NS_SWIFT_NAME(addDelegate(_:));

- (void)removeDelegate:(id<STTorrentManagerDelegate>)delegate
NS_SWIFT_NAME(removeDelegate(_:));

- (void)restoreSession;

- (BOOL)addTorrent:(id<STDownloadable>)torrent
NS_SWIFT_NAME(add(_:));

- (BOOL)removeTorrentWithInfoHash:(NSData *)infoHash deleteFiles:(BOOL)deleteFiles;

- (BOOL)removeAllTorrentsWithFiles:(BOOL)deleteFiles;

- (NSArray<STTorrent *> *)torrents;

- (void)openURL:(NSURL *)URL;

- (NSArray<STFileEntry *> *)filesForTorrentWithHash:(NSData *)infoHash;

- (NSURL *)downloadsDirectoryURL;

@end

NS_ASSUME_NONNULL_END
