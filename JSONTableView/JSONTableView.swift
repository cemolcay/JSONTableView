//
//  JSONTableView.swift
//  JSONTableView
//
//  Created by cem.olcay on 18/09/2019.
//  Copyright © 2019 cemolcay. All rights reserved.
//

import UIKit
import SwiftyJSON

open class JSONTableViewCell: UIView {
  public var title = ""
  public var data = JSON()

  public var stackView = UIStackView()
  public var cellStack = UIStackView()
  public var titleLabel = UILabel()
  public var valueLabel = UILabel()
  public var expandButton = UIButton()
  public var expandStack = UIStackView()
  public var bottomLineLayer = CALayer()
  public var canExpand = false
  public var isExpanded = false {
    didSet {
      if isExpanded {
        expand()
      } else {
        collapse()
      }
    }
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  func commonInit() {
    layer.addSublayer(bottomLineLayer)
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
    stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    stackView.addArrangedSubview(cellStack)
    cellStack.translatesAutoresizingMaskIntoConstraints = false
    cellStack.heightAnchor.constraint(equalToConstant: 44).isActive = true
    cellStack.axis = .horizontal
    cellStack.spacing = 8
    let titleStack = UIStackView()
    titleStack.axis = .horizontal
    titleStack.addArrangedSubview(titleLabel)
    titleStack.addArrangedSubview(valueLabel)
    cellStack.addArrangedSubview(titleStack)
    cellStack.addArrangedSubview(expandButton)
    expandButton.translatesAutoresizingMaskIntoConstraints = false
    expandButton.widthAnchor.constraint(equalToConstant: 22).isActive = true
    expandButton.setImage(UIImage(named: "downArrow", in: Bundle(for: JSONTableView.self), compatibleWith: nil), for: .normal)
    expandButton.imageView?.contentMode = .scaleAspectFit
    expandButton.addTarget(self, action: #selector(expandButtonDidPress(sender:)), for: .touchUpInside)
    expandButton.tintColor = .lightGray

    titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    stackView.addArrangedSubview(expandStack)
    expandStack.axis = .vertical
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    bottomLineLayer.frame = CGRect(x: 16, y: frame.size.height - 0.5, width: frame.size.width - 16, height: 0.5)
    bottomLineLayer.backgroundColor = UIColor.lightGray.cgColor
  }

  open func reloadData() {
    titleLabel.font = .systemFont(ofSize: 15)
    titleLabel.text = title

    valueLabel.font = .systemFont(ofSize: 13, weight: .light)
    valueLabel.text = nil
    valueLabel.numberOfLines = 0
    valueLabel.textAlignment = .right
    valueLabel.minimumScaleFactor = 0.1

    expandButton.isHidden = true
    expandStack.arrangedSubviews.forEach({ expandStack.removeArrangedSubview($0) })
    expandStack.arrangedSubviews.forEach({ $0.removeFromSuperview() })
    expandStack.isHidden = true

    switch data.type {
    case .dictionary, .array:
      for (key, value) in data {
        let cell = JSONTableViewCell(frame: .zero)
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.title = key
        cell.data = value
        cell.reloadData()
        expandStack.addArrangedSubview(cell)
        expandButton.isHidden = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -8).isActive = true
        canExpand = true
      }
    default:
      valueLabel.text = "\(data)"
      valueLabel.translatesAutoresizingMaskIntoConstraints = false
      valueLabel.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -8).isActive = true
      canExpand = false
    }
  }

  @IBAction func expandButtonDidPress(sender: UIButton) {
    isExpanded = !isExpanded
  }

  public func expand() {
    guard canExpand else { return }
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: [],
      animations: {
        self.expandStack.isHidden = false
        self.expandStack.alpha = 1
        self.stackView.layoutIfNeeded()
        self.expandButton.transform = CGAffineTransform(rotationAngle: .pi)
      },
      completion: nil)
  }

  public func collapse() {
    guard canExpand else { return }
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0,
      options: [],
      animations: {
        self.expandStack.isHidden = true
        self.expandStack.alpha = 0
        self.stackView.layoutIfNeeded()
        self.expandButton.transform = CGAffineTransform(rotationAngle: 0)
      },
      completion: nil)
  }
}

open class JSONTableView: UIView {
  public var scrollView = UIScrollView()
  public var stackView = UIStackView()
  public var data = JSON()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  func commonInit() {
    addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    scrollView.addSubview(stackView)
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
    stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
    stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
    stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
  }

  open func reloadData() {
    stackView.arrangedSubviews.forEach({ stackView.removeArrangedSubview($0) })
    stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })

    for (key, value) in data {
      let cell = JSONTableViewCell(frame: .zero)
      stackView.addArrangedSubview(cell)
      cell.title = key
      cell.data = value
      cell.reloadData()
    }
  }

  public func expandAll() {
    func exp(cell: JSONTableViewCell) {
      cell.isExpanded = true
      cell.expandStack.arrangedSubviews
        .compactMap({ ($0 as? JSONTableViewCell) })
        .forEach({ exp(cell: $0) })
    }
    stackView.arrangedSubviews
      .compactMap({ ($0 as? JSONTableViewCell) })
      .forEach({ exp(cell: $0) })
  }

  public func collapseAll() {
    func coll(cell: JSONTableViewCell) {
      cell.isExpanded = false
      cell.expandStack.arrangedSubviews
        .compactMap({ ($0 as? JSONTableViewCell) })
        .forEach({ coll(cell: $0) })
    }
    stackView.arrangedSubviews
      .compactMap({ ($0 as? JSONTableViewCell) })
      .forEach({ coll(cell: $0) })
  }
}
