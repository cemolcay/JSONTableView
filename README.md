JSONTableView
===

Display your [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) data on an expandable list view. The view itself is not a `UITableView` subclass, everything is created with `UIStackView`s, so it's not memory friendly for big json files. I created it for debugging my json data in a quick and dirty way. Contributions are welcomed for making it better!

Demo
---

![alt tag](https://raw.githubusercontent.com/cemolcay/JSONTableView/master/demo.gif)

Install
---

``` ruby
pod 'JSONTableView'
```

Usage
---

* Create an instance of `JSONTableView` either programmaticaly or in your storyboard.

``` swift
@IBOutlet weak var tableView: JSONTableView?
```

* Pass a SwiftyJSON's `JSON` type data object to your JSONTableView instance's `data` property and call `reloadData()`

``` swift
let data = JSON(...)
tableView?.data = data
tableView?.reloadData()
```

* You may expand/collapse all possible expandable cells with

``` swift
tableView?.expandAll()
tableView?.collapseAll()
```