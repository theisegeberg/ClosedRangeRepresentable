import Foundation

public protocol ClosedRangeRepresentable {
  associatedtype Bound:Comparable
  var closedRange:ClosedRange<Bound> { get }
}

public extension ClosedRange where Bound:AdditiveArithmetic {
  var length:Bound {
    self.upperBound - self.lowerBound
  }
}

extension ClosedRange:ClosedRangeRepresentable {
  public var closedRange: ClosedRange<Bound> {
    return self
  }
}

public extension ClosedRangeRepresentable where Bound:AdditiveArithmetic {
  var length:Bound {
    self.closedRange.length
  }
}

public extension ClosedRangeRepresentable where Bound:FloatingPoint {
  func progress(for progressValue:Bound) -> Bound {
    let result = (progressValue - self.closedRange.lowerBound) / self.length
    if result < 0 { return 0 }
    if result > 1 { return 1 }
    return result
  }
}


/// Type representing overlaps between ranges
public enum Overlap:Equatable,CustomStringConvertible {
  
  /// A string representation of an overlap
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
  
  /// Bound, can be upper or lower
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
  
  /// Finds the way the two ranges overlap with reference to the caller.
  /// - Parameter other: The other range to test against.
  /// - Returns: The type of overlap that occurs.
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
  
  /// The lowest bound in the collection
  var lowestBound:Element.Bound? {
    self.sorted {
      $0.closedRange.lowerBound < $1.closedRange.lowerBound
    }
    .first?
    .closedRange
    .lowerBound
  }
  
  /// The highest upper bound in the collection
  var highestBound:Element.Bound? {
    self.sorted {
      $0.closedRange.upperBound < $1.closedRange.upperBound
    }
    .last?
    .closedRange
    .upperBound
  }
  
  /// Returns elements that are completely contained within a given outer span
  /// - Parameter outerSpan: A closed range to test with.
  /// - Returns: An array of elements that are contained within the outerSpan.
  func elementsContainedCompletely(within outerSpan:ClosedRange<Element.Bound>) -> [Self.Element] {
    self.filter { outerSpan.completelyOverlaps($0.closedRange) }
  }
  
  /// A function that finds elements that are partially or completely overlapped by a given closed range.
  /// - Parameter outerSpan: A closed range to test with.
  /// - Returns: An array of tuples containing the type of overlap and the element that was found.
  func elementsOverlapping(with outerSpan:ClosedRange<Element.Bound>) -> [(Overlap,Self.Element)] {
    self.compactMap {
      let overlap = outerSpan.overlap($0.closedRange)
      guard overlap != .none else {
        return nil
      }
      return (overlap, $0)
    }
  }
  
  /// Method for finding elements that contain a certain value.
  /// - Parameter value: The value to test against.
  /// - Returns: Elements that contain the value.
  func elementsContaining(_ value:Element.Bound) -> [Self.Element] {
    self.filter { element in
      element.closedRange.contains(value)
    }
  }
  
  /// True if any of the ranges contains the bound.
  /// - Parameter value: value to test with.
  /// - Returns: True if the ranges contain the value, false if it doesn't..
  func contains(_ value:Element.Bound) -> Bool {
    for element in self {
      if element.closedRange.contains(value) {
        return true
      }
    }
    return false
  }
  
  /// Collapses all ranges into a set of non-overlapping ranges
  var collapsed:[ClosedRange<Self.Element.Bound>] {
    return self.sorted { a, b in
      a.closedRange.lowerBound < b.closedRange.lowerBound
    }.reduce([ClosedRange<Self.Element.Bound>]()) { partialResult, nextElement in
      var copy = partialResult
      guard let previousElement = copy.popLast() else {
        return [nextElement.closedRange]
      }
      
      if nextElement.closedRange.lowerBound <= previousElement.upperBound {
        
        if nextElement.closedRange.upperBound <= previousElement.closedRange.upperBound {
          return copy + [previousElement]
        }
        
        return copy + [previousElement.lowerBound...nextElement.closedRange.upperBound]
      }
      return copy + [previousElement,nextElement.closedRange]
    }
  }
  
}


public extension RandomAccessCollection where Element:ClosedRangeRepresentable, Element.Bound:AdditiveArithmetic {
  
  /// The total length of all the ranges without overlaps
  var collapsedLength:Element.Bound {
    self.collapsed.reduce(Element.Bound.zero) { partialResult, element in
      partialResult + element.length
    }
  }
}


