//
//  FilesViewModel.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/16/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine
import MediaKit
import TorrentKit

//protocol FilesViewModel {
//
//    var title: String { get }
//
//    var directory: Directory { get }
//
//}
//
//extension Directory: FilesViewModel {
//
//    var title: String {
//        return name
//    }
//
//    var directory: Directory {
//        return self
//    }
//
//}

final class FilesViewModel: NSObject, ListViewModelProtocol {
    
    weak var viewController: UIViewController?
    
    var title: String { return "Files" }
    var icon: UIImage? { return nil }
    var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode { .never }
    
    var sections = [SectionProtocol]()
    
    var sectionsPublisher: AnyPublisher<[SectionProtocol], Never>?
    private let sectionsSubject = PassthroughSubject<[SectionProtocol], Never>()
    
    var rowPublisher: AnyPublisher<(RowProtocol, IndexPath), Never>?
    private let rowSubject = PassthroughSubject<(RowProtocol, IndexPath), Never>()

    init(directory: Directory) {
        super.init()
        let dirRows = directory.allSubDirectories.map({ file in
            ListViewModel.Row(file: file, action: {
                let filesVM = FilesViewModel(directory: file)
                filesVM.viewController = self.viewController
                let controller = ListViewController(viewModel: filesVM)
                self.viewController?.navigationController?.pushViewController(controller, animated: true)
            })
        })
        let fileRows = directory.allFiles.map({ file in
            ListViewModel.Row(file: file, action: {
                var controller: UIViewController!
                if file.isVideo() {
                    controller = VLCPlayerViewController(previewItem: file)
                } else {
//                    controller = QuickLookViewController(previewItem: file)
                }
                self.viewController?.present(controller, animated: true, completion: nil)
            })
        })
        self.sections = [ListViewModel.Section(id: "sec0", title: nil, rows: dirRows + fileRows)]
        self.sectionsPublisher = sectionsSubject.eraseToAnyPublisher()
    }
    
    func removeItem(at indexPath: IndexPath) { }
    
//    func contextMenuConfig(at indexPath: IndexPath) -> UIContextMenuConfiguration? {
//        return nil
//    }
    
    func start() {
        sectionsSubject.send(sections)
    }

}

extension ListViewModel.Row {
    
    private static var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter
    }()

    init(file: FileProtocol, action: RowAction? = nil) {
        self.id = file.name
        self.title = file.name
        if let action = action {
            self.rowType = .navigation(action)
        }
    }
    
}
