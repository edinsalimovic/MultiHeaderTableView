//
// MultiHeaderTableViewDataSourceDelegate.swift
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

extension MultiHeaderTableView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard tableView == self.mainTableView else { return 1 }
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView == mainTableView ? sections[section].numberOfFlattenRows() : stickyReference.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = findRow(tableView: tableView, indexPath: indexPath) else { return UITableViewCell() }
        return delegate.cellForRowAt(tableView: tableView, indexPath: indexPath, row: item)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = findRow(tableView: tableView, indexPath: indexPath) else { return }
        let indexPathMainTable = getIndexPathForTable(tableView, indexPath: indexPath)
        delegate.didSelectRowAt(row: row, indexPath: indexPathMainTable)
        expandCollapseRow(row)
        if tableView == self.mainTableView {
            UIView.performWithoutAnimation {
                mainTableView.reloadData()
                resetAndUpdateReferencePointers()
            }
            return
        }
        moveToNextSection(indexPathMainTable)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        getHeightForRow(tableView, indexPath)
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        getHeightForRow(tableView, indexPath)
    }
    
    private func getHeightForRow(_ tableView: UITableView, _ indexPath: IndexPath) -> CGFloat {
        findRow(tableView: tableView, indexPath: indexPath)?.height ?? 0
    }
}
