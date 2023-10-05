//
// MHRow.swift
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

open class MHRow {
    
    // MARK: Properties
    
    let uniqueId: String
    private let originalHeight: CGFloat
    var children: [MHRow]?
    
    // MARK: Lifecycle
    
    public init(uniqueId: String,
         height: CGFloat,
         children: [MHRow]?) {
        self.uniqueId = uniqueId
        self.originalHeight = height
        self.children = children
    }
    
    // MARK: Computed properties
    
    var height: CGFloat {
        SectionCollapsableHelper.shared.isCollapsed(uniqueId) ? 0 : originalHeight
    }
    
    // MARK: Func
    
    func has(child: MHRow) -> Bool {
        hasChildren() && (children?.contains(where: { $0.uniqueId == child.uniqueId }) ?? false)
    }
    
    func hasChildren() -> Bool {
        return !(children?.isEmpty ?? true)
    }
    
    func hasVisibleChildren() -> Bool {
        return !(children?.filter({ !SectionCollapsableHelper.shared.isCollapsed($0.uniqueId) }).isEmpty ?? true)
    }
    
    func getFlattenChildren() -> [MHRow] {
        guard hasChildren() else { return [] }
        guard numberOfFlattenRows() > 0 else { return [] }
        var rows: [MHRow] = []
        for i in (1...(numberOfFlattenRows() - 1)) {
            if let row = get(flattenRowAt: i) {
                rows.append(row)
            }
        }
        return rows
    }
    
    func numberOfFlattenRows() -> Int {
        return 1 + (children?.reduce(0) { $0 + $1.numberOfFlattenRows() } ?? 0)
    }
    
    func get(flattenRowAt index: Int) -> MHRow? {
        guard index > 0 else {
            return self
        }
        guard let children = children, children.count > 0 else {
            return self
        }
        var row = 0
        var offset = 1
        for i in 0 ..< children.count where offset < index {
            offset += children[i].numberOfFlattenRows()
            row += 1
        }
        if row > 0 && children[row - 1].hasChildren() && index < offset {
            row -= 1
            offset -= children[row].numberOfFlattenRows()
        }
        guard row < children.count else { return nil }
        return children[row].get(flattenRowAt: index - offset)
    }
}
