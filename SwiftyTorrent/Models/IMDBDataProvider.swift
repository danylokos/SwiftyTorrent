//
//  IMDBDataProvider.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 30.06.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import Combine

extension String: Error { }

final class IMDBDataProvider {
    
    static let shared = IMDBDataProvider()
    
    private let urlSession: URLSession = URLSession.shared
    private let endpointURL = URL(string: "https://sg.media-imdb.com/")!
    
    func fetchSuggestions(_ query: String) -> AnyPublisher<String, Error> {
        let query = query.lowercased()
        let prefix = String(query.prefix(1))
        let requestURL = endpointURL.appendingPathComponent("suggests/\(prefix)/\(query).json")
        return urlSession
            .dataTaskPublisher(for: requestURL)
            .tryMap({ data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                }
                return data
            })
            .tryMap({ (data) -> Data in
                //json-np
                var value = String(bytes: data, encoding: .utf8)!
                if let idx = value.firstIndex(of: "(") {
                    value.removeSubrange(value.startIndex..<idx)
                    value = String(value.dropFirst())
                    value = String(value.dropLast())
                }
                return value.data(using: .utf8)!
            })
            .decode(type: Response.self, decoder: JSONDecoder())
            .tryMap({ imdbResponse -> String in
                guard var imdbId = imdbResponse.data.first?.id else {
                    throw "IMDB show not found."
                }
                imdbId = String(imdbId.dropFirst(2)) // remove "tt"
                return imdbId
            })
            .eraseToAnyPublisher()
    }
    
}

extension IMDBDataProvider {
    
    struct Response: Decodable {
        
        //swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case version = "v"
            case query = "q"
            case data = "d"
        }
        
        let version: Int
        let query: String
        let data: [DataItem]
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            version = try values.decode(Int.self, forKey: .version)
            query = try values.decode(String.self, forKey: .query)
            data = try values.decode([DataItem].self, forKey: .data)
        }
        
        //swiftlint:disable:next nesting
        struct DataItem: Decodable {
            
            //swiftlint:disable:next nesting
            enum CodingKeys: String, CodingKey {
                case label = "l"
                case id = "id"
            }
            
            let label: String
            let id: String
            
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                label = try values.decode(String.self, forKey: .label)
                id = try values.decode(String.self, forKey: .id)
            }
            
        }
        
    }
    
}
