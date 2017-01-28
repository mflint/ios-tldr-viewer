//
//  InfoViewController.swift
//  tldr-viewer
//
//  Created by Matthew Flint on 02/01/2016.
//  Copyright © 2016 Green Light. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    internal var viewModel: InfoViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50
        
        self.viewModel = InfoViewModel()
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: 500, height: 720)
        }
        set {
            super.preferredContentSize = newValue
        }
    }
}

// MARK: - UITableViewDataSource

extension InfoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let viewModel = self.viewModel else {
            return 0
        }
        
        return viewModel.groupViewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = self.viewModel else {
            return 0
        }
        
        return viewModel.groupViewModels[section].cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = self.viewModel!.groupViewModels[indexPath.section].cellViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.cellIdentifier, for: indexPath)
        if let baseCell = cell as? BaseCell {
            baseCell.configure(cellViewModel: cellViewModel)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel!.groupViewModels[section].groupTitle
    }
}
