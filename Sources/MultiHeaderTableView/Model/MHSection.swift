//
// MHSection.swift
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

import Foundation

final public class MHSection {
    
    // MARK: Properties
    
    let rows: [MHRow]
    
    // MARK: Lifecycle
    
    public init(rows: [MHRow]) {
        self.rows = rows
    }
    
    // MARK: Func
    
    func numberOfFlattenRows() -> Int {
        rows.reduce(0) { $0 + $1.numberOfFlattenRows() }
    }
    
    func get(flattenRowAt index: Int) -> MHRow? {
        var row = 0
        var offset = 0
        for i in 1 ..< rows.count where offset < index {
            offset += rows[i - 1].numberOfFlattenRows()
            row += 1
        }
        if row > 0 && index < offset {
            row -= 1
            offset -= rows[row].numberOfFlattenRows()
        }
        guard row < rows.count else { return nil }
        return rows[row].get(flattenRowAt: index - offset)
    }
}
