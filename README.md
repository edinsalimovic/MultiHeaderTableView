[![NSoft logo](./NSoftLogo.svg)](https://www.nsoft.com/)

# MultiHeaderTableView

<img src="/example.gif" width="200"/>

A simple library written in Swift.

- [Usage](#usage)
- [Examples](#examples)
- [Installation](#installation)
- [Requirements](#requirements)
- [License](#license)

<br>

## Usage

[MultiHeaderTableView](https://github.com/edinsalimovic/MultiHeaderTableView/blob/main/Sources/MultiHeaderTableView/MultiHeaderTableView.swift) provides a method to set the data:

```swift
public func set(sections: [MHSection])
```
[MHSection](https://github.com/edinsalimovic/MultiHeaderTableView/blob/main/Sources/MultiHeaderTableView/MultiHeaderTableView.swift).

---


MultiHeaderTableView provides the [MultiHeaderTableViewDelegate](https://github.com/edinsalimovic/MultiHeaderTableView/blob/main/Sources/MultiHeaderTableView/Model/MHSection.swift).

```swift
public protocol MultiHeaderTableViewDelegate {
    var cells: [UITableViewCell.Type] { get }
    func cellForRowAt(tableView: UITableView, indexPath: IndexPath, row: MHRow) -> UITableViewCell
    func didSelectRowAt(row: MHRow, indexPath: IndexPath)
    var areSectionsExpandable: Bool { get }
    var shouldMoveToNextSection: Bool { get }
}
```

You need to provide:

1. **cells** your table view cells.
2. **areSectionsExpandable** This field will be used to enable the functionality to hide/show cells when the end user clicks on the header. When you click on the header, all sub rows will be hidden/showed.
3. **shouldMoveToNextSection** This field will be used to enable the functionality to move the table view to the next available heading.
4. **cellForRowAt** Implement this method to provide the cell for a row at a certain index path. [Example](https://github.com/edinsalimovic/MultiHeaderTableView/blob/main/MultiHeaderTableViewDemo/MultiHeaderTableViewDemo/ViewController.swift).
5. **didSelectRowAt** This function will be invoked when the user did select a row at a certain index path.

<br>

## Examples

You can find the **Demo** 📁 `MultiHeaderTableViewDemo`.

<br>

## Installation

**Swift Package Manager**\
File > Add Package Dependencies...\
Add https://github.com/edinsalimovic/MultiHeaderTableView.git

<br>

## Requirements

- iOS 8.0+

<br>

## License

MultiHeaderTableView is released under the MIT license. [See LICENSE](https://github.com/edinsalimovic/MultiHeaderTableView/blob/main/LICENSE) for details.

