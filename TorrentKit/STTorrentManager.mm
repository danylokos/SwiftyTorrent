//
//  STTorrentManager.m
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/24/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import "STTorrentManager.h"

#import "STTorrent.h"
#import "STTorrentFile.h"
#import "STMagnetURI.h"
#import "STFileEntry.h"

#import "NSData+Hex.h"

//libtorrent
#import "libtorrent/session.hpp"
#import "libtorrent/alert.hpp"
#import "libtorrent/alert_types.hpp"

#import "libtorrent/torrent_handle.hpp"
#import "libtorrent/torrent_info.hpp"
#import "libtorrent/create_torrent.hpp"
#import "libtorrent/magnet_uri.hpp"

#import "libtorrent/bencode.hpp"
#import "libtorrent/bdecode.hpp"

@interface STTorrent ()
@property (readwrite, strong, nonatomic) NSData *infoHash;
@property (readwrite, nonatomic) STTorrentState state;
@property (readwrite, strong, nonatomic) NSString *name;
@property (readwrite, nonatomic) double progress;
@property (readwrite, nonatomic) NSUInteger numberOfPeers;
@property (readwrite, nonatomic) NSUInteger numberOfSeeds;
@property (readwrite, nonatomic) NSUInteger downloadRate;
@property (readwrite, nonatomic) NSUInteger uploadRate;
@property (readwrite, nonatomic) BOOL hasMetadata;
@end

@interface STFileEntry ()
@property (readwrite, strong, nonatomic) NSString *name;
@property (readwrite, strong, nonatomic) NSString *path;
@property (readwrite, nonatomic) NSUInteger size;
@end

#pragma mark -

static char const * const STEventsQueueIdentifier = "org.kostyshyn.SwiftyTorrent.STTorrentManager.events.queue";
static char const * const STFileEntriesQueueIdentifier = "org.kostyshyn.SwiftyTorrent.STTorrentManager.files.queue";
static NSErrorDomain STErrorDomain = @"org.kostyshyn.SwiftyTorrent.STTorrentManager.error";

@interface STTorrentManager () {
    lt::session *_session;
}
@property (strong, nonatomic) NSThread *eventsThread;
@property (strong, nonatomic) dispatch_queue_t filesQueue;
@property (strong, nonatomic) NSHashTable *delegates;

- (instancetype)init;

@end

@implementation STTorrentManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static STTorrentManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[STTorrentManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _session = new lt::session();
        _session->set_alert_mask(lt::alert::all_categories);
        _filesQueue = dispatch_queue_create(STFileEntriesQueueIdentifier, DISPATCH_QUEUE_SERIAL);
        _delegates = [NSHashTable weakObjectsHashTable];
        
        // restore session
        [self restoreSession];
        
        // start alerts loop
        _eventsThread = [[NSThread alloc] initWithTarget:self selector:@selector(alertsLoop) object:nil];
        [_eventsThread setName:[NSString stringWithUTF8String:STEventsQueueIdentifier]];
        [_eventsThread setQualityOfService:NSQualityOfServiceDefault];
        [_eventsThread start];
    }
    return self;
}

- (void)dealloc {
    delete _session;
}

#pragma mark -

- (BOOL)isSessionActive {
    return YES;
}

#pragma mark -

- (void)notifyDelegatesAboutError:(NSError *)error {
    for (id<STTorrentManagerDelegate>delegate in self.delegates) {
        [delegate torrentManager:self didErrorOccur:error];
    }
}

- (NSError *)errorWithCode:(STErrorCode)code message:(NSString *)message {
    return [NSError errorWithDomain:STErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

#pragma mark - Alerts Loop

#define ALERTS_LOOP_WAIT_MILLIS 500

- (void)alertsLoop {
    auto max_wait = lt::milliseconds(ALERTS_LOOP_WAIT_MILLIS);
    while (YES) {
        auto alert_ptr = _session->wait_for_alert(max_wait);
        std::vector<lt::alert *> alerts_queue;
        if (alert_ptr != nullptr) {
            _session->pop_alerts(&alerts_queue);
        } else {
            continue;
        }
        
        for (auto it = alerts_queue.begin(); it != alerts_queue.end(); ++it) {
            auto alert = (*it);
//            NSLog(@"type:%d msg:%s", alert->type(), alert->message().c_str());
            switch (alert->type()) {
                case lt::metadata_received_alert::alert_type: {
                } break;
                    
                case lt::metadata_failed_alert::alert_type: {
                    [self metadataReceivedAlert:(lt::torrent_alert *)alert];
                } break;
                
                case lt::block_finished_alert::alert_type: {
                } break;

                case lt::add_torrent_alert::alert_type: {
                    [self torrentAddedAlert:(lt::torrent_alert *)alert];
                } break;
                    
                case lt::torrent_removed_alert::alert_type: {
                    [self torrentRemovedAlert:(lt::torrent_alert *)alert];
                } break;

                case lt::torrent_finished_alert::alert_type: {
                } break;

                case lt::torrent_paused_alert::alert_type: {
                } break;

                case lt::torrent_resumed_alert::alert_type: {
                } break;

                case lt::torrent_error_alert::alert_type: {
                } break;
                
                default: break;
            }
            
            if (dynamic_cast<lt::torrent_alert *>(alert) != nullptr) {
                auto th = ((lt::torrent_alert *)alert)->handle;
                if (!th.is_valid()) { break; }
                [self notifyDelegatesWithUpdate:th];
            }
        }
        
        alerts_queue.clear();
    }
}

- (void)notifyDelegatesWithAdd:(lt::torrent_handle)th {
    STTorrent *torrent = [self torrentFromHandle:th];
    for (id<STTorrentManagerDelegate>delegate in self.delegates) {
        [delegate torrentManager:self didAddTorrent:torrent];
    }
}

- (void)notifyDelegatesWithRemove:(lt::torrent_handle)th {
    NSData *hashData = [self hashDataFromInfoHash:th.info_hash()];
    for (id<STTorrentManagerDelegate>delegate in self.delegates) {
        [delegate torrentManager:self didRemoveTorrentWithHash:hashData];
    }
}

- (void)notifyDelegatesWithUpdate:(lt::torrent_handle)th {
    STTorrent *torrent = [self torrentFromHandle:th];
    for (id<STTorrentManagerDelegate>delegate in self.delegates) {
        [delegate torrentManager:self didReceiveUpdateForTorrent:torrent];
    }
}

- (void)metadataReceivedAlert:(lt::torrent_alert *)alert {
    auto th = alert->handle;
}

- (void)torrentAddedAlert:(lt::torrent_alert *)alert {
    auto th = alert->handle;
    [self notifyDelegatesWithAdd:th];
    if (!th.is_valid()) {
        NSLog(@"%s: torrent_handle is invalid!", __FUNCTION__);
        return;
    }

    bool has_metadata = th.status().has_metadata;
    auto torrent_info = th.torrent_file();
    auto margnet_uri = lt::make_magnet_uri(th);
    dispatch_async(self.filesQueue, ^{
        if (has_metadata) {
            [self saveTorrentFileWithInfo:torrent_info];
        } else {
            [self saveMagnetURIWithContent:margnet_uri];
        }
    });
}

- (void)torrentRemovedAlert:(lt::torrent_alert *)alert {
    auto th = alert->handle;
    [self notifyDelegatesWithRemove:th];
    if (!th.is_valid()) {
        NSLog(@"%s: torrent_handle is invalid!", __FUNCTION__);
        return;
    }

    auto torrent_info = th.torrent_file();
    auto info_hash = th.info_hash();
    dispatch_async(self.filesQueue, ^{
        [self removeTorrentFileWithInfo:torrent_info];
        [self removeMagnetURIWithHash:info_hash];
    });
}

#pragma mark -

- (NSURL *)downloadsDirectoryURL {
    return [NSURL fileURLWithPath:[self downloadsDirPath] isDirectory:YES];
}

- (NSString *)storageDirPath {
#if TARGET_OS_IOS
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
#elif TARGET_OS_TV
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
#endif
}

- (NSString *)downloadsDirPath {
    NSString *downloadsDirPath = [[self storageDirPath] stringByAppendingPathComponent:@"Downloads"];
    return downloadsDirPath;
}

- (NSString *)torrentsDirPath {
    NSString *torrentsDirPath = [[self storageDirPath] stringByAppendingPathComponent:@"torrents"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:torrentsDirPath];
    if (!fileExists) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:torrentsDirPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) { NSLog(@"%@", error); }
    }
    return torrentsDirPath;
}

- (NSString *)magnetURIsFilePath {
    return [[self torrentsDirPath] stringByAppendingPathComponent:@"magnet_links"];
}

#pragma mark -

- (void)saveTorrentFileWithInfo:(std::shared_ptr<const lt::torrent_info>)ti {
    if (ti == nullptr) { return; }
    
    lt::create_torrent new_torrent(*ti);
    std::vector<char> out_file;
    lt::bencode(std::back_inserter(out_file), new_torrent.generate());
    
    NSString *fileName = [NSString stringWithFormat:@"%s.torrent", (*ti).name().c_str()];
    NSString *filePath = [[self torrentsDirPath] stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithBytes:out_file.data() length:out_file.size()];
    BOOL success = [data writeToFile:filePath atomically:YES];
    if (!success) { NSLog(@"Can't save .torrent file"); }
}

- (void)saveMagnetURIWithContent:(std::string)uri {
    if (uri.length() < 1) { return; }
    
    NSString *magnetURI = [NSString stringWithUTF8String:uri.c_str()];
    [self appendMagnetURIToFileStore:magnetURI];
}

- (void)appendMagnetURIToFileStore:(NSString *)magnetURI {
    NSString *magnetURIsFilePath = [self magnetURIsFilePath];
    // read from existing file
    NSError *error;
    NSString *fileContent = [NSString stringWithContentsOfFile:magnetURIsFilePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if (error) { NSLog(@"%@", error); }
    
    NSMutableArray *magnetURIs = [[fileContent componentsSeparatedByString:@"\n"] mutableCopy];
    if (magnetURIs == nil) {
        magnetURIs = [[NSMutableArray alloc] init];
    }
    // remove all existing copies
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS[cd] %@)", magnetURI];
    [magnetURIs filterUsingPredicate:predicate];
    // add new uri
    [magnetURIs addObject:magnetURI];
    
    // save to file
    fileContent = [magnetURIs componentsJoinedByString:@"\n"];
    [fileContent writeToFile:magnetURIsFilePath
                  atomically:YES
                    encoding:NSUTF8StringEncoding
                       error:&error];
    if (error) { NSLog(@"%@", error); }
}

- (void)removeTorrentFileWithInfo:(std::shared_ptr<const lt::torrent_info>)ti {
    if (ti == nullptr) { return; }

    NSString *fileName = [NSString stringWithFormat:@"%s.torrent", (*ti).name().c_str()];
    NSString *filePath = [[self torrentsDirPath] stringByAppendingPathComponent:fileName];

    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (error) { NSLog(@"success: %d, %@", success, error); }
}

- (NSData *)hashDataFromInfoHash:(lt::sha1_hash)info_hash {
    return [NSData dataWithBytes:info_hash.data()
                          length:info_hash.size()];
}

- (void)removeMagnetURIWithHash:(lt::sha1_hash)info_hash {
    NSData *hashData = [self hashDataFromInfoHash:info_hash];
    [self removeFromFileStoreMagnetURIWithHash:hashData.hexString];
}

- (void)removeFromFileStoreMagnetURIWithHash:(NSString *)hashString {
    NSString *magnetURIsFilePath = [self magnetURIsFilePath];
    // read from existing file
    NSError *error;
    NSString *fileContent = [NSString stringWithContentsOfFile:magnetURIsFilePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if (error) { NSLog(@"%@", error); }
    
    NSMutableArray *magnetURIs = [[fileContent componentsSeparatedByString:@"\n"] mutableCopy];
    // remove all existing copies
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS[cd] %@)", hashString];
    [magnetURIs filterUsingPredicate:predicate];
    
    // save to file
    fileContent = [magnetURIs componentsJoinedByString:@"\n"];
    [fileContent writeToFile:magnetURIsFilePath
                  atomically:YES
                    encoding:NSUTF8StringEncoding
                       error:&error];
    if (error) { NSLog(@"%@", error); }
}

#pragma mark -

- (void)addDelegate:(id<STTorrentManagerDelegate>)delegate {
    [self.delegates addObject:delegate];
}
    
- (void)removeDelegate:(id<STTorrentManagerDelegate>)delegate {
    [self.delegates removeObject:delegate];
}

#pragma mark - Public Methods

- (void)restoreSession {
    NSString *torrentsDirPath = [self torrentsDirPath];
    NSString *marngetURIsFilePath = [self magnetURIsFilePath];
    
    NSError *error;
    // load .torrents files
    NSArray *torrentsDirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:torrentsDirPath error:&error];
    NSLog(@"%@", torrentsDirPath);
    if (error) { NSLog(@"%@", error); }
    
    torrentsDirFiles = [torrentsDirFiles filteredArrayUsingPredicate:
                        [NSPredicate predicateWithFormat:@"self ENDSWITH %@", @".torrent"]];
    for (NSString *fileName in torrentsDirFiles) {
        NSString *filePath = [torrentsDirPath stringByAppendingPathComponent:fileName];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        STTorrentFile *torrent = [[STTorrentFile alloc] initWithFileAtURL:fileURL];
        [self addTorrent:torrent];
    }
    
    // load magnet links
    NSString *magnetURIsContent = [NSString stringWithContentsOfFile:marngetURIsFilePath
                                                            encoding:NSUTF8StringEncoding
                                                               error:&error];
    if (error) { NSLog(@"%@", error); }
    
    NSArray *magnetURIs = [magnetURIsContent componentsSeparatedByString:@"\n"];
    for (NSString *magnetURIString in magnetURIs) {
        if (magnetURIString.length == 0) {
            continue;
        }
        NSURL *magnetURI = [NSURL URLWithString:magnetURIString];
        STMagnetURI *torrent = [[STMagnetURI alloc] initWithMagnetURI:magnetURI];
        [self addTorrent:torrent];
    }
}

- (BOOL)addTorrent:(id<STDownloadable>)torrent {
    lt::add_torrent_params params;
    params.save_path = [[self downloadsDirPath] UTF8String];
    try {
        [torrent configureAddTorrentParams:(void *)&params];
    } catch (...) {
        NSError *error = [self errorWithCode:STErrorCodeBadFile message:@"Failed to add torrent"];
        NSLog(@"%@", error);
        [self notifyDelegatesAboutError:error];
        return NO;
    }
    auto th = _session->add_torrent(params);
    return YES;
}

- (BOOL)removeTorrentWithInfoHash:(NSData *)infoHash deleteFiles:(BOOL)deleteFiles {
    lt::sha1_hash hash((const char *)infoHash.bytes);
    auto th = _session->find_torrent(hash);
    if (!th.is_valid()) { return NO; }
    if (deleteFiles) {
        _session->remove_torrent(th, lt::session::delete_files);
    } else {
        _session->remove_torrent(th);
    }
    return YES;
}

- (void)openURL:(NSURL *)URL {
    if (URL.isFileURL) {
        BOOL success = [URL startAccessingSecurityScopedResource];
        if (success) {
            STTorrentFile *torrent = [[STTorrentFile alloc] initWithFileAtURL:URL];
            [self addTorrent:torrent];
            [URL stopAccessingSecurityScopedResource];
        }
    } else {
        STMagnetURI *torrent = [[STMagnetURI alloc] initWithMagnetURI:URL];
        [self addTorrent:torrent];
    }
}

#pragma mark -

- (STTorrentState)stateFromTorrentSatus:(lt::torrent_status)status {
    switch (status.state) {
        case lt::torrent_status::state_t::checking_files: return STTorrentStateCheckingFiles;
        case lt::torrent_status::state_t::downloading_metadata: return STTorrentStateDownloadingMetadata;
        case lt::torrent_status::state_t::downloading: return STTorrentStateDownloading;
        case lt::torrent_status::state_t::finished: return STTorrentStateFinished;
        case lt::torrent_status::state_t::seeding: return STTorrentStateSeeding;
        case lt::torrent_status::state_t::allocating: return STTorrentStateAllocating;
        case lt::torrent_status::state_t::checking_resume_data: return STTorrentStateCheckingResumeData;
    }
}

- (STTorrent *)torrentFromHandle:(lt::torrent_handle)th {
    STTorrent *torrent = [[STTorrent alloc] init];
    auto ih = th.info_hash();
    torrent.infoHash = [NSData dataWithBytes:ih.data() length:ih.size()];
    auto ts = th.status();
    torrent.state = [self stateFromTorrentSatus:ts];
    torrent.name = [NSString stringWithUTF8String:ts.name.c_str()];
    torrent.progress = ts.progress;
    torrent.numberOfPeers = ts.num_peers;
    torrent.numberOfSeeds = ts.num_seeds;
    torrent.uploadRate = ts.upload_payload_rate;
    torrent.downloadRate = ts.download_payload_rate;
    torrent.hasMetadata = ts.has_metadata;
    return torrent;
}

- (NSArray<STTorrent *> *)torrents {
    auto handles = _session->get_torrents();
    NSMutableArray *torrents = [[NSMutableArray alloc] init];
    for (auto it = handles.begin(); it != handles.end(); ++it) {
        auto th = (*it);
        [torrents addObject:[self torrentFromHandle:th]];
    }
    return [torrents copy];
}

- (NSArray<STFileEntry *> *)filesForTorrentWithHash:(NSData *)infoHash {
    lt::sha1_hash ih = lt::sha1_hash((const char *)infoHash.bytes);
    auto th = _session->find_torrent(ih);
    if (!th.is_valid()) {
        NSLog(@"No a valid torrent with hash: %@", infoHash.hexString);
        return nil;
    }
    NSMutableArray *results = [[NSMutableArray alloc] init];
    auto ti = th.torrent_file();
    if (ti == nullptr) {
        NSLog(@"No metadata for torrent with name: %s", th.status().name.c_str());
        return nil;
    }
    auto files = ti.get()->files();
    for (int i=0; i<files.num_files(); i++) {
        auto name = std::string(files.file_name(i));
        auto path = files.file_path(i);
        auto size = files.file_size(i);
        
        STFileEntry *fileEntry = [[STFileEntry alloc] init];
        fileEntry.name = [NSString stringWithUTF8String:name.c_str()];
        fileEntry.path = [NSString stringWithUTF8String:path.c_str()];
        fileEntry.size = size;
        [results addObject:fileEntry];
    }
    return [results copy];
}

@end
