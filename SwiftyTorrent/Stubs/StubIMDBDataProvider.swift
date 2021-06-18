//
//  StubIMDBDataProvider.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 18.06.2021.
//  Copyright © 2021 Danylo Kostyshyn. All rights reserved.
//

import Foundation
import Combine

class StubIMDBDataProvider: IMDBDataProviderProtocol {
    
    func fetchSuggestions(_ query: String) -> AnyPublisher<String, Error> {
        return Just("stubImdbId")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

}
