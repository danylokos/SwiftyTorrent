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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(model.items, id: \.title) { item in
                    SearchRow(model: item) {
                        print("select: \(item.title)")
                        model.select(item)
                    }.onAppear(perform: {
                        model.loadMoreIfNeeded(currentItem: item)
                    })
                }
                if model.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Loading...")
                        Spacer()
                    }
                }
            }
            .listStyle(PlainListStyle())
            .searchable("Search...", text: $model.searchText)
            .navigationBarTitle("Search")
        }
    }

}

#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        return SearchView(model: SearchViewModel())
    }
}
#endif
