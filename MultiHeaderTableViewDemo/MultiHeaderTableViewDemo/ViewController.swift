//
// ViewController.swift
//
// Copyright (c) 2023 NSoft
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import MultiHeaderTableView

class ViewController: UIViewController {
    
    // MARK: Properties
    
    private lazy var multiHeaderTableView = MultiHeaderTableView(delegate: self)
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        let rows: [MHRow] = (0...10).map { MainHeaderViewModel(title: "Main header: #\($0)") }
        let sections = rows.map { MHSection(rows: [$0]) }
        multiHeaderTableView.set(sections: sections)
    }
    
    // MARK: Setup
    
    private func layout() {
        [multiHeaderTableView].forEach(view.addSubview)
        multiHeaderTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: multiHeaderTableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: multiHeaderTableView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: multiHeaderTableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: multiHeaderTableView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        ])
    }
}

// MARK: MultiHeaderTableViewDelegate

extension ViewController: MultiHeaderTableViewDelegate {
    var cells: [UITableViewCell.Type] {
        [MainHeaderCell.self, SubHeaderCell.self, ItemCell.self]
    }
    
    func cellForRowAt(tableView: UITableView, indexPath: IndexPath, row: MHRow) -> UITableViewCell {
        switch row {
        case let mainHeader as MainHeaderViewModel:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainHeaderCell.self), for: indexPath) as? MainHeaderCell
            cell?.set(title: mainHeader.title)
            return cell ?? UITableViewCell()
        case let subHeader as SubHeaderViewModel:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SubHeaderCell.self), for: indexPath) as? SubHeaderCell
            cell?.set(title: subHeader.title)
            return cell ?? UITableViewCell()
        case let item as ItemViewModel:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemCell.self), for: indexPath) as? ItemCell
            cell?.set(name: item.name)
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    func didSelectRowAt(row: MHRow, indexPath: IndexPath) {
        print("Selected row: \(row) - IndexPath: \(indexPath)")
    }
    
    var areSectionsExpandable: Bool {
        true
    }
    
    var shouldMoveToNextSection: Bool {
        true
    }
}

