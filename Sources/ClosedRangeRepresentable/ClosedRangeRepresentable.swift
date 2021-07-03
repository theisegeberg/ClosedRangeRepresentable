import Foundation

public protocol ClosedRangeRepresentable {
  associatedtype Bound:Comparable
  var closedRange:ClosedRange<Bound> { get }
}

public extension ClosedRangeRepresentable where Bound:AdditiveArithmetic {
  var length:Bound {
    self.closedRange.upperBound - self.closedRange.lowerBound
  }
}


public extension ClosedRangeRepresentable where Bound:FloatingPoint {
  func progress(for progressValue:Bound) -> Bound {
    let result = (self.length - progressValue) / self.length
    if result < 0 { return 0 }
    if result > 1 { return 1 }
    return result
  }
}


public enum Overlap:Equatable,CustomStringConvertible {
  
  public var description: String {
    switch self {
      case .complete:
        return "complete"
      case .none:
        return "none"
      case .partial(bound: .lower):
        return "lower"
      case .partial(bound: .upper):
        return "upper"
    }
  }
  
  public enum Bound:Equatable {
    case lower
    case upper
  }
  
  case partial(bound: Bound)
  case complete
  case none
}

public extension ClosedRange {
  
  /// Returns a boolean value whether the range completely overlaps another range.
  /// - Parameter other: The other range that is tested.
  /// - Returns: True if Self completely overlaps the other rane.
  func completelyOverlaps(_ other:Self) -> Bool {
    (other.lowerBound >= self.lowerBound && other.upperBound <= self.upperBound)
  }
  
  /// Returns a boolean value whether the range completely overlaps another range.
  /// - Parameter other: The other range that is tested.
  /// - Returns: True if Self completely overlaps the other rane.
  func hasNoSharedValues(_ other:Self) -> Bool {
    (other.upperBound < self.lowerBound || other.lowerBound > self.upperBound)
  }
  
  func overlap(_ other:Self<Bound>) -> Overlap {
    if self.completelyOverlaps(other) {
      return .complete
    }
    if self.hasNoSharedValues(other) {
      return .none
    }
    if other.lowerBound >= self.lowerBound {
      return .partial(bound: .lower)
    }
    return .partial(bound: .upper)
  }
}

public extension RandomAccessCollection where Element:ClosedRangeRepresentable {
  
  var lowestBound:Element.Bound? {
    self.sorted {
      $0.closedRange.lowerBound < $1.closedRange.lowerBound
    }
    .first?
    .closedRange
    .lowerBound
  }
  
  var highestBound:Element.Bound? {
    self.sorted {
      $0.closedRange.upperBound < $1.closedRange.upperBound
    }
    .last?
    .closedRange
    .upperBound
  }
  
  func elementsContainedCompletely(within outerSpan:ClosedRange<Element.Bound>) -> [Self.Element] {
    self.filter { outerSpan.completelyOverlaps($0.closedRange) }
  }
  
  func elementsContained(within outerSpan:ClosedRange<Element.Bound>) -> [(Overlap,Self.Element)] {
    
    self.compactMap {
      let overlap = outerSpan.overlap($0.closedRange)
      guard overlap != .none else {
        return nil
      }
      return (overlap, $0)
    }
  }
}
