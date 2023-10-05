//
// HelperMultiHeaderTableView.swift
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

extension MultiHeaderTableView {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainTableView {
            if let minIndexPath = mainTableView.indexPathsForVisibleRows?.min(), minIndexPath != minVisibleIndexPath {
                minVisibleIndexPath = minIndexPath
            }
            if let maxIndexPath = mainTableView.indexPathsForVisibleRows?.max(), maxIndexPath != maxVisibleIndexPath {
                maxVisibleIndexPath = maxIndexPath
            }
            updateStickyContent()
        }
    }
    
    internal func resetAndUpdateReferencePointers() {
        pointersForHeader.removeAll()
        for (index, section) in sections.enumerated() where (section.rows.reduce(false) { $0 || $1.hasChildren() }) {
            for i in 0 ..< section.numberOfFlattenRows() where (section.get(flattenRowAt: i)?.hasChildren() ?? false) {
                let anchorPoint = IndexPath(row: i, section: index)
                guard let row = section.get(flattenRowAt: i) else { return }
                let to = i + row.numberOfFlattenRows() - 1
                let toAnchorPoint = IndexPath(row: to, section: index)
                pointersForHeader[anchorPoint] = toAnchorPoint
            }
        }
    }
    
    private func updateStickyContent() {
        var temp = [IndexPath]()
        var indexPathsToStick = [IndexPath]()
        
        for range in pointersForHeader where isWithinVisibleRange(from: range.key, to: range.value) {
            indexPathsToStick.append(range.key)
        }
        indexPathsToStick.sort()
        var stickyTableViewHeight: CGFloat = 0.0
        
        for indexPath in indexPathsToStick where
        isWithinVisibleView(for: indexPath,
                            stickyTableViewHeight: stickyTableViewHeight) &&
        check(indexPath: indexPath,
              isChildOf: temp.last) {
            stickyTableViewHeight += findCellHeight(for: indexPath)
            temp.append(indexPath)
        }
        stickyReference = temp
        stickyTableView.reloadData()
        
        if stickyReference.count > 0,
           let endAnchor = pointersForHeader[stickyReference[stickyReference.count - 1]],
           let rect = findRect(for: endAnchor) {
            let lastCell = stickyTableView.cellForRow(at: IndexPath(row: stickyReference.count - 1, section: 0))
            let offset = rect.maxY - mainTableView.contentOffset.y - stickyTableViewHeight
            if offset < 0, let lastStickyIndexPath = stickyReference.last, findCellHeight(for: lastStickyIndexPath) + offset > 0 {
                lastCell?.frame.origin.y = stickyTableViewHeight - findCellHeight(for: lastStickyIndexPath) + offset
                stickyTableViewHeight += offset
                
                if endAnchor.row + 1 == tableView(mainTableView, numberOfRowsInSection: endAnchor.section) {
                    lastCell?.separatorInset = UIEdgeInsets.zero
                    lastCell?.layoutMargins = UIEdgeInsets.zero
                }
            }
        }
        stickyHeightConstraint.constant = stickyTableViewHeight
    }
    
    private func findCellHeight(for indexPath: IndexPath) -> CGFloat {
        sections[indexPath.section].get(flattenRowAt: indexPath.row)?.height ?? 0
    }
    
    private func isWithinVisibleRange(from: IndexPath, to: IndexPath) -> Bool {
        return to >= minVisibleIndexPath && from < maxVisibleIndexPath
    }
    
    private func isWithinVisibleView(for indexPath: IndexPath, stickyTableViewHeight: CGFloat) -> Bool {
        guard let endAnchor = pointersForHeader[indexPath] else {
            return false
        }
        guard let rect = findRect(for: indexPath) else {
            if let endRect = findRect(for: endAnchor) {
                return endRect.maxY - mainTableView.contentOffset.y > stickyTableViewHeight // ending anchor frame still present
            }
            return indexPath <= minVisibleIndexPath && endAnchor >= minVisibleIndexPath
        }
        let shouldPresent = rect.origin.y < (mainTableView.contentOffset.y + stickyTableViewHeight)
        if shouldPresent, let endRect = findRect(for: endAnchor) {
            return endRect.maxY - mainTableView.contentOffset.y > stickyTableViewHeight
        }
        return shouldPresent
    }
    
    private func check(indexPath child: IndexPath, isChildOf parent: IndexPath?) -> Bool {
        guard let parent = parent else {
            return true
        }
        guard parent.section == child.section else {
            return false
        }
        guard let parentRow = sections[parent.section].get(flattenRowAt: parent.row) else { return false }
        guard let childRow = sections[child.section].get(flattenRowAt: child.row) else { return false }
        return parentRow.has(child: childRow)
    }
    
    private func findRect(for indexPath: IndexPath) -> CGRect? {
        return mainTableView.cellForRow(at: indexPath)?.frame
    }
    
    internal func findNextRowThatHasChildren(indexPath: IndexPath) -> IndexPath? {
        let flattenRows = sections[indexPath.section].numberOfFlattenRows() - 1
        let rangeFromClickedToEndOfSection: ClosedRange = (indexPath.row + 1)...flattenRows
        var nextRowIndexThatHasChildren: Int?
        for i in rangeFromClickedToEndOfSection where (sections[indexPath.section].get(flattenRowAt: i)?.hasVisibleChildren() ?? false) {
            nextRowIndexThatHasChildren = i
            break
        }
        if let nextRowIndexThatHasChildren {
            return IndexPath(row: nextRowIndexThatHasChildren, section: indexPath.section)
        }
        if indexPath.section < sections.count - 1 {
            return IndexPath(row: 0, section: indexPath.section + 1)
        }
        return nil
    }
    
    internal func findRow(tableView: UITableView, indexPath: IndexPath) -> MHRow? {
        let useIndexPath = getIndexPathForTable(tableView, indexPath: indexPath)
        guard useIndexPath.section < sections.count else { return nil }
        return sections[useIndexPath.section].get(flattenRowAt: useIndexPath.row)
    }
    
    internal func getIndexPathForTable(_ tableView: UITableView, indexPath: IndexPath) -> IndexPath {
        tableView == self.mainTableView ? indexPath : (stickyReference[indexPath.row])
    }
    
    internal func expandCollapseRow(_ row: MHRow) {
        guard delegate.areSectionsExpandable else { return }
        guard !row.getFlattenChildren().isEmpty else { return }
        let needToCollapse = row.hasVisibleChildren()
        let childrenUniqueIds = row.getFlattenChildren().map { $0.uniqueId }
        SectionCollapsableHelper.shared.collapseOrExpand(childrenUniqueIds, collapse: needToCollapse)
    }
    
    internal func moveToNextSection(_ indexPathMainTable: IndexPath) {
        guard delegate.shouldMoveToNextSection else { return }
        guard let nextIndexPathHeader = findNextRowThatHasChildren(indexPath: indexPathMainTable) else { return }
        UIView.performWithoutAnimation {
            mainTableView.reloadData()
            mainTableView.setNeedsLayout()
            mainTableView.layoutIfNeeded()
        }
        mainTableView.scrollToRow(at: nextIndexPathHeader, at: .top, animated: false)
        mainTableView.setNeedsLayout()
        mainTableView.layoutIfNeeded()
        let cellRect = mainTableView.rectForRow(at: nextIndexPathHeader)
        let lastCellRectStickyTableView = stickyTableView.rectForRow(at: IndexPath(row: stickyTableView.numberOfRows(inSection: 0) - 1,
                                                                                section: 0))
        let stickyTableViewHeight = stickyHeightConstraint.constant
        let calculatedStickyTableViewHeight = stickyTableViewHeight - lastCellRectStickyTableView.height
        mainTableView.setContentOffset(CGPoint(x: 0,
                                               y: cellRect.origin.y - calculatedStickyTableViewHeight - 1),
                                       animated: false)
        mainTableView.setContentOffset(CGPoint(x: 0,
                                               y: cellRect.origin.y - calculatedStickyTableViewHeight + 1),
                                       animated: false)
    }
}
