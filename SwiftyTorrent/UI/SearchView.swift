//
//  SearchView.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 29.06.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI

struct SearchView: View {
    
    @ObservedObject var model: SearchViewModel
    
    #if os(iOS)
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $model.searchText, placeholder: "Seach EZTV...")
                List {
                    ForEach(model.data, id: \.title) { item in
                        SearchRow(model: item) {
                            print("select: \(item.title)")
                            self.model.select(item)
                        }
                    }
                }
            }.navigationBarTitle(Text("Search"))
        }
    }
    #elseif os(tvOS)
    var body: some View {
        NavigationView {
            VStack {
                SearchBarTV(text: $model.searchText, placeholder: "Seach EZTV...")
                List {
                    ForEach(model.data, id: \.title) { item in
                        SearchRow(model: item) {
                            print("select: \(item.title)")
                            self.model.select(item)
                        }
                    }
                }
            }.navigationBarTitle(Text("Search"))
        }
    }
    #endif

}

#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        return SearchView(model: SearchViewModel())
    }
}
#endif
