//
//  ListViewController.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 03.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import UIKit
import Combine

class ListViewController: UIViewController {

    internal var viewModel: ListViewModelProtocol
    
    private let tableView = UITableView()
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Row> = {
        DiffableDataSource(tableView: tableView, viewModel: viewModel)
    }()
    private var cancellables = [AnyCancellable]()
    
    init(viewModel: ListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.presenter = self
        configUIKit()
    }
    
    private func configUIKit() {
        title = viewModel.title
        tabBarItem.title = viewModel.title
        tabBarItem.image = viewModel.icon
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        
        registerObservers()
        viewModel.start()
    }
    
    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.registerCell(ListCell.self)
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: [
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 0.0
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: 0.0
            ),
            tableView.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: 0.0
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: 0.0
            )
        ])
        constraints.forEach({ $0.isActive = true })
    }

    private var isInitialReload = true
    
    private func registerObservers() {
        viewModel.sectionsPublisher?
            .sink { [weak self] sections in
                guard let self = self else { return }
                self.update(with: sections, animate: !self.isInitialReload)
                if self.isInitialReload { self.isInitialReload = false }
        }.store(in: &cancellables)
        
        viewModel.rowPublisher?
            .sink { [weak self] (rowModel, indexPath) in
                self?.updateRow(at: indexPath, rowModel: rowModel)
        }.store(in: &cancellables)
    }
    
    func update(with sections: [Section], animate: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections(sections)
        sections.forEach { (section) in
            snapshot.appendItems(section.rows, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animate)
    }

}
 
extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowModel = viewModel.row(at: indexPath)
            else { fatalError("No row at indexPath: \(indexPath)") }
        rowModel.action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension ListViewController {
    
    private class DiffableDataSource: UITableViewDiffableDataSource<Section, Row> {
        
        private let viewModel: ListViewModelProtocol
        
        init(tableView: UITableView, viewModel: ListViewModelProtocol) {
            self.viewModel = viewModel
            super.init(tableView: tableView,
                cellProvider: { tableView, indexPath, row in
                    guard let rowModel = viewModel.row(at: indexPath)
                        else { fatalError("No row at indexPath: \(indexPath)") }
                    guard let cell = tableView.dequeueReusableCell(rowModel.viewType) as?
                        UITableViewCell & AnyViewModelConfigurable
                        else { fatalError("Bad viewType: \(rowModel.viewType) for rowModel: \(rowModel)") }
                    cell.configure(rowModel)
                    return cell
                }
            )
        }
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return viewModel.sections[section].title
        }
        
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }

        override func tableView(_ tableView: UITableView,
                                commit editingStyle: UITableViewCell.EditingStyle,
                                forRowAt indexPath: IndexPath) {
            viewModel.removeItem(at: indexPath)
        }
        
    }
    
}

extension ListViewController {
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func updateRow(at indexPath: IndexPath, rowModel: Row) {
        guard let cell = tableView.cellForRow(at: indexPath) as?
            UITableViewCell & AnyViewModelConfigurable
            else { return }
        cell.configure(rowModel)
    }

}

protocol ControllerPresenter {
    
    func present(_ viewController: UIViewController)
    func push(_ viewController: UIViewController)
    
}

extension ListViewController: ControllerPresenter {
    
    func present(_ viewController: UIViewController) {
        present(viewController, animated: true)
    }
    
    func push(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

}
