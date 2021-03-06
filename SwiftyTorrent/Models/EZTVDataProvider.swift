//
//  EZTVDataProvider.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 30.06.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

//swiftlint:disable nesting

import Foundation
import Combine

protocol SearchDataItem {
    var id: String { get }
    var title: String { get }
    var sizeBytes: UInt64 { get }
    var episodeInfo: String? { get }
    var peersStatus: String { get }
    var magnetURL: URL { get }
    var details: String { get }
}

extension SearchDataItem {
    
    var size: String {
        ByteCountFormatter.string(fromByteCount: Int64(sizeBytes), countStyle: .binary)
    }

    var details: String {
        [episodeInfo, size, peersStatus]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

}

extension EZTVDataProvider.Response.Torrent: SearchDataItem {
    
    var id: String { magnetURL.absoluteString }

    var episodeInfo: String? {
        guard let s = Int(season), let e = Int(episode) else { return nil }
        return String(format: "s%02de%02d", s, e)
    }
    
    var peersStatus: String { "seeds: \(seeds), peers: \(peers)" }

}

protocol EZTVDataProviderProtocol {
    func fetchTorrents(imdbId: String, page: Int) -> AnyPublisher<[SearchDataItem], Error>
}

final class EZTVDataProvider: EZTVDataProviderProtocol {

    static let endpoint = "https://eztv.re/api/"

    private let urlSession: URLSession = URLSession.shared
    private let endpointURL = URL(string: endpoint)!
    
    func fetchTorrents(imdbId: String, page: Int) -> AnyPublisher<[SearchDataItem], Error> {
        fetchTorrents(imdbId: imdbId, limit: 20, page: page)
    }
    
    private func fetchTorrents(imdbId: String, limit: Int, page: Int) -> AnyPublisher<[SearchDataItem], Error> {
        let requestURL = URL(string: endpointURL.absoluteString +
                             "get-torrents?" +
                             "limit=\(limit)&" +
                             "page=\(page)&" +
                             "imdb_id=\(imdbId)"
        )!
        return urlSession
            .dataTaskPublisher(for: requestURL)
            .tryMap({ data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                          throw URLError(.badServerResponse)
                      }
                return data
            })
            .decode(type: Response.self, decoder: JSONDecoder())
            .map({ (response) -> [SearchDataItem] in
                print("torrentsCount: \(response.torrentsCount)")
                print("page: \(response.page)")
                print("page: \(response.limit)")
                return response.torrents
            })
            .eraseToAnyPublisher()
    }
}

extension EZTVDataProvider {
    
    struct Response: Decodable {
        
        enum CodingKeys: String, CodingKey {
            case imdbId = "imdb_id"
            case torrentsCount = "torrents_count"
            case limit
            case page
            case torrents
        }
        
        let imdbId: String
        let torrentsCount: Int
        let limit: Int
        let page: Int
        let torrents: [Torrent]
        
        var hasMorePages: Bool { page * limit < torrentsCount }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            imdbId = try container.decode(String.self, forKey: .imdbId)
            torrentsCount = try container.decode(Int.self, forKey: .torrentsCount)
            limit = try container.decode(Int.self, forKey: .limit)
            page = try container.decode(Int.self, forKey: .page)
            var itemsContainer = try container.nestedUnkeyedContainer(forKey: .torrents)
            torrents = try itemsContainer.deocdeItems(ofType: Torrent.self)
        }
        
        struct Torrent: Decodable, CustomDebugStringConvertible {
            
            enum CodingKeys: String, CodingKey {
                case id
                case hash
                case fileName = "filename"
                case episodeURL = "episode_url"
                case torrentURL = "torrent_url"
                case magnetURL = "magnet_url"
                case title
                case imdbId = "imdb_id"
                case season
                case episode
                case smallThumb = "small_screenshot"
                case largeThumb = "large_screenshot"
                case seeds
                case peers
                case releaseDate = "date_released_unix"
                case sizeBytes = "size_bytes"
            }
            
//            let id: Int
//            let hash: String
//            let fileName: String
//            let episodeURL: URL
            let torrentURL: URL
            let magnetURL: URL
            let title: String
//            let imdbId: String
            let season: String
            let episode: String
//            let smallThumb: URL
//            let largeThumb: URL
            let seeds: Int
            let peers: Int
//            let releaseDate: TimeInterval
            let sizeBytes: UInt64
            
            var debugDescription: String {
                return title
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                if let rawValue = try? container.decode(String.self, forKey: .torrentURL),
                   let encodedValue = rawValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                   let URL = URL(string: encodedValue) {
                    torrentURL = URL
                } else {
                    throw "Bad torrentURL"
                }
                magnetURL = try container.decode(URL.self, forKey: .magnetURL)
                title = try container.decode(String.self, forKey: .title)
                season = try container.decode(String.self, forKey: .season)
                episode = try container.decode(String.self, forKey: .episode)
                seeds = try container.decode(Int.self, forKey: .seeds)
                peers = try container.decode(Int.self, forKey: .peers)
                if let rawValue = try? container.decode(String.self, forKey: .sizeBytes),
                   let value = UInt64(rawValue) {
                    sizeBytes = value
                } else {
                    throw "Bad sizeBytes"
                }
            }
            
        }
    }
}

struct AnyDecodable: Decodable { }

extension UnkeyedDecodingContainer {
    
    mutating func deocdeItems<T: Decodable>(ofType type: T.Type) throws -> [T] {
        var items = [T]()
        while !isAtEnd {
            do {
                let item = try decode(type)
                items.append(item)
            } catch let error {
                print("Failed to decode item: \(error)")
                // Skip item
                _ = try decode(AnyDecodable.self)
            }
        }
        return items
    }
    
}
