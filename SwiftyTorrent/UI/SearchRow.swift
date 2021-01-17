//
//  SearchRow.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 30.06.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI

struct SearchRow: View {
    
    var model: SearchDataItem
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                Text(model.title)
                    .font(Font.headline)
                    .bold()
                Spacer(minLength: 5)
                Text("\(model.size), \(model.status)")
                    .font(Font.subheadline)
            }
        }
    }
    
}
