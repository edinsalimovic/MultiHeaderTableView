//
// MultiHeaderTableView.swift
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

final public class MultiHeaderTableView: UIView {
    
    // MARK: Properties
    
    internal let delegate: MultiHeaderTableViewDelegate
    internal var sections: [MHSection] = []
    internal var pointersForHeader = [IndexPath: IndexPath]()
    internal var stickyReference = [IndexPath]()
    internal var minVisibleIndexPath = IndexPath(row: 0, section: 0)
    internal var maxVisibleIndexPath = IndexPath(row: 0, section: 0)
    let mainTableView = UITableView()
    internal let stickyTableView = UITableView()
    internal lazy var stickyHeightConstraint = NSLayoutConstraint(item: stickyTableView,
                                                                  attribute: .height,
                                                                  relatedBy: .equal,
                                                                  toItem: nil,
                                                                  attribute: .notAnAttribute,
                                                                  multiplier: 1,
                                                                  constant: 0)
    
    // MARK: Lifecycle
    
    public init(delegate: MultiHeaderTableViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Func
    
    public func set(sections: [MHSection]) {
        self.sections = sections
        resetAndUpdateReferencePointers()
        mainTableView.reloadData()
        stickyTableView.reloadData()
    }
}
