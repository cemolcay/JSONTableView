//
//  Validation.swift
//  JSONTableView
//
//  Created by cem.olcay on 03/06/2020.
//  Copyright © 2020 cemolcay. All rights reserved.
//

import UIKit

protocol ValidatorDataType: Comparable {}
extension String: ValidatorDataType {}
extension Double: ValidatorDataType {}
extension Float: ValidatorDataType {}
extension Int: ValidatorDataType {}

public class DataValidator {
  var rules: [String: Any]

  public init(rules: [String: Any]) {
    self.rules = rules
  }

  enum Validator<T: ValidatorDataType>: CustomStringConvertible {
    case range(ClosedRange<T>)
    case one(Array<T>)
    case greaterThan(T)
    case lessThan(T)

    func isValid(value: T) -> Bool {
      switch self {
      case .range(let r):
        return r.contains(value)
      case .one(let o):
        return o.contains(value)
      case .greaterThan(let v):
        return value > v
      case .lessThan(let v):
        return value < v
      }
    }

    var description: String {
      var type = ""
      switch T.self {
      case is String.Type:
        type = "String"
      case is Double.Type:
        type = "Double"
      case is Float.Type:
        type = "Float"
      case is Int.Type:
        type = "Int"
      default:
        type = ""
      }

      switch self {
      case .range(let range):
        return "\(type)(\(range.lowerBound),\(range.upperBound)"
      case .one(let array):
        return "\(type)[\(array.map({ "\($0)" }).joined(separator: ","))]"
      case .greaterThan(let value):
        return "\(type)(>\(value))"
      case .lessThan(let value):
        return "\(type)(<\(value))"
      }
    }
  }

  public func validate(data: [String: Any]) -> [String: Any] {
    return validate(data: data, rules: rules)
  }

  func validate(data: [String: Any], rules: [String: Any]) -> [String: Any] {
    var validatedData = data

    for (key, value) in validatedData {
      if let valueData = value as? [String: Any],
        let valueRules = rules[key] as? [String: Any] {
        validatedData[key] = validate(data: valueData, rules: valueRules)
      }

      guard let validValue = rules[key] as? String else { continue }

      do {
        let oneTypePattern = "^(.*?)\\["
        let onePattern = "\\[([^()]*)\\]"
        let rangeTypePattern = "^(.*?)\\("
        let rangePattern = "\\(([^()]*)\\)"
        let patternRange = NSRange(0 ..< validValue.count)

        if let oneTypeMatch = try NSRegularExpression(pattern: oneTypePattern, options: [])
          .firstMatch(in: validValue, options: [], range: patternRange),
          let oneTypeRange = Range(oneTypeMatch.range(at: 1), in: validValue) {
          let oneType = validValue[oneTypeRange]

          if let oneArrayMatch = try NSRegularExpression(pattern: onePattern, options: [])
            .firstMatch(in: validValue, options: [], range: patternRange),
            let oneArrayRange = Range(oneArrayMatch.range(at: 1), in: validValue) {
            let oneArray = validValue[oneArrayRange].split(separator: ",")

            switch String(oneType) {
            case "String":
              guard let value = value as? String else { break }
              let validator = Validator<String>.one(oneArray.map({ String($0) }))
              let isValid = validator.isValid(value: value)
              validatedData[key] = isValid ? value : "!(\(value),\(validator))"

            case "Int":
              guard let value = value as? Double else { break }
              let validator = Validator<Int>.one(oneArray.compactMap({ Int($0) }))
              let isValid = validator.isValid(value: Int(value))
              validatedData[key] = isValid ? value : "!(\(value),\(validator))"

            case "Float":
              guard let value = value as? Double else { break }
              let validator = Validator<Float>.one(oneArray.compactMap({ Float($0) }))
              let isValid = validator.isValid(value: Float(value))
              validatedData[key] = isValid ? value : "!(\(value),\(validator))"

            case "Double":
              guard let value = value as? Double else { break }
              let validator = Validator<Double>.one(oneArray.compactMap({ Double($0) }))
              let isValid = validator.isValid(value: value)
              validatedData[key] = isValid ? value : "!(\(value),\(validator))"

            default:
              break
            }
          }
        }

        if let rangeTypeMatch = try NSRegularExpression(pattern: rangeTypePattern, options: [])
          .firstMatch(in: validValue, options: [], range: patternRange),
          let rangeTypeRange = Range(rangeTypeMatch.range(at: 1), in: validValue) {
          let rangeType = validValue[rangeTypeRange]

          if let rangeArrayMatch = try NSRegularExpression(pattern: rangePattern, options: [])
            .firstMatch(in: validValue, options: [], range: patternRange),
            let rangeArrayRange = Range(rangeArrayMatch.range(at: 1), in: validValue) {
            var rangeValue = ""
            var validatorType = ""

            if validValue[rangeArrayRange].first == ">" {
              validatorType = "greaterThan"
              rangeValue = String(validValue[rangeArrayRange].dropFirst())
            } else if validValue[rangeArrayRange].first == "<" {
              validatorType = "lessThan"
              rangeValue = String(validValue[rangeArrayRange].dropFirst())
            } else {
              validatorType = "range"
              rangeValue = String(validValue[rangeArrayRange])
            }

            switch String(rangeType) {
            case "String":
              guard let value = value as? String else { break }
              let val = rangeValue
              var isValid: Bool!
              var validator: Validator<String>!

              if validatorType == "range" {
                let arr = rangeValue.split(separator: ",").compactMap({ String($0) })
                guard arr.count == 2 else { break }
                validator = .range(arr[0]...arr[1])
              } else if validatorType == "greaterThan" {
                validator = .greaterThan(val)
              } else if validatorType == "lessThan" {
                validator = .lessThan(val)
              }

              isValid = validator.isValid(value: value)
              validatedData[key] = isValid ? val : "!(\(value),\(validator!))"

            case "Int":
              guard let value = value as? Double else { break }
              var isValid: Bool!
              var validator: Validator<Int>!

              if validatorType == "range" {
                let arr = rangeValue.split(separator: ",").compactMap({ Int($0) })
                guard arr.count == 2 else { break }
                validator = .range(arr[0]...arr[1])
              } else if validatorType == "greaterThan" {
                guard let val = Int(rangeValue) else { break }
                validator = .greaterThan(val)
              } else if validatorType == "lessThan" {
                guard let val = Int(rangeValue) else { break }
                validator = .lessThan(val)
              }

              isValid = validator.isValid(value: Int(value))
              validatedData[key] = isValid ? value : "!(\(Int(value)),\(validator!))"

            case "Float":
              guard let value = value as? Double else { break }
              var isValid: Bool!
              var validator: Validator<Float>!

              if validatorType == "range" {
                let arr = rangeValue.split(separator: ",").compactMap({ Float($0) })
                guard arr.count == 2 else { break }
                validator = .range(arr[0]...arr[1])
              } else if validatorType == "greaterThan" {
                guard let val = Float(rangeValue) else { break }
                validator = .greaterThan(val)
              } else if validatorType == "lessThan" {
                guard let val = Float(rangeValue) else { break }
                validator = .lessThan(val)
              }

              isValid = validator.isValid(value: Float(value))
              validatedData[key] = isValid ? value : "!(\(Float(value)),\(validator!))"

            case "Double":
              guard let value = value as? Double else { break }
              var isValid: Bool!
              var validator: Validator<Double>!

              if validatorType == "range" {
                let arr = rangeValue.split(separator: ",").compactMap({ Double($0) })
                guard arr.count == 2 else { break }
                validator = .range(arr[0]...arr[1])
              } else if validatorType == "greaterThan" {
                guard let val = Double(rangeValue) else { break }
                validator = .greaterThan(val)
              } else if validatorType == "lessThan" {
                guard let val = Double(rangeValue) else { break }
                validator = .lessThan(val)
              }

              isValid = validator.isValid(value: value)
              validatedData[key] = isValid ? value : "!(\(value),\(validator!))"

            default:
              break
            }
          }
        }
      } catch {
        continue
      }
    }

    return validatedData
  }
}
