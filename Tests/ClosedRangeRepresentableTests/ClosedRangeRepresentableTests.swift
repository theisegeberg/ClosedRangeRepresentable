    import XCTest
    @testable import ClosedRangeRepresentable
    
    final class ClosedRangeRepresentableTests: XCTestCase {
      
      func testRangeElementLowerHigherBound() {
        struct TestRangeElement:ClosedRangeRepresentable {
          let closedRange: ClosedRange<Int>
        }
        
        let c01 = TestRangeElement(closedRange: 0...1)
        let c23 = TestRangeElement(closedRange: 2...3)
        let c45 = TestRangeElement(closedRange: 4...5)
        
        let ranges05 = [c01,c45]
        XCTAssertEqual(ranges05.lowestBound, 0)
        XCTAssertEqual(ranges05.highestBound, 5)
        
        let ranges25 = [c23,c45]
        XCTAssertEqual(ranges25.lowestBound, 2)
        XCTAssertEqual(ranges25.highestBound, 5)
        
        let noRanges = [TestRangeElement]()
        XCTAssertNil(noRanges.lowestBound)
        
      }
      
      
      func testRangeElementCompleteContainment() {
        struct TestRangeElement:ClosedRangeRepresentable {
          let string:String
          let closedRange: ClosedRange<Int>
        }
        
        
        let a01 = TestRangeElement(string: "a", closedRange: 0...1)
        let b12 = TestRangeElement(string: "b", closedRange: 1...2)
        let c23 = TestRangeElement(string: "c", closedRange: 2...3)
        let d03 = TestRangeElement(string: "d", closedRange: 0...3)
        let e45 = TestRangeElement(string: "e", closedRange: 4...5)
        
        func helper(_ r:ClosedRange<Int>, _ c:[TestRangeElement]) -> String {
          c.elementsContainedCompletely(within: r).map(\.string).joined()
        }
        
        XCTAssertEqual(helper(0...2, [a01, b12, d03 , e45]), "ab")
        XCTAssertEqual(helper(1...4, [a01, b12, c23, d03 ,e45]), "bc")
        
        XCTAssertTrue((0...5).completelyOverlaps(0...3))
        XCTAssertFalse((0...2).completelyOverlaps(1...3))
        XCTAssertFalse((2...5).completelyOverlaps(1...3))
        XCTAssertTrue((1...1).completelyOverlaps(1...1))
        
        XCTAssertFalse((1...1).hasNoSharedValues(1...1))
        XCTAssertTrue((0...1).hasNoSharedValues(10...20))
        
        XCTAssertEqual([b12, c23, d03 ,e45].highestBound, 5)
        XCTAssertEqual([b12, c23 ,e45].lowestBound, 1)
      }
      
      func testRangeElementContainment() {
        struct TestRangeElement:ClosedRangeRepresentable {
          let string:String
          let closedRange: ClosedRange<Int>
        }
        
        let a01 = TestRangeElement(string: "a", closedRange: 0...1)
        let b12 = TestRangeElement(string: "b", closedRange: 1...2)
        let c23 = TestRangeElement(string: "c", closedRange: 2...3)
        let d03 = TestRangeElement(string: "d", closedRange: 0...3)
        let e45 = TestRangeElement(string: "e", closedRange: 4...5)
        
        func helper(_ r:ClosedRange<Int>, _ c:[TestRangeElement]) -> String {
          c.elementsOverlapping(with: r).map { (overlap, element) in
            return "\(overlap.description)-\(element.string)"
          }.joined(separator: ",")
        }
        
        XCTAssertEqual(helper(0...1, [a01, b12, c23, d03, e45]), "complete-a,lower-b,lower-d")
        XCTAssertEqual(helper(3...4, [a01, b12, c23, d03, e45]), "upper-c,upper-d,lower-e")
        XCTAssertEqual(helper(2...5, [a01, b12, c23, d03, e45]), "upper-b,complete-c,upper-d,complete-e")
        XCTAssertEqual(helper(5...7, [a01, b12, c23, d03, e45]), "upper-e")
        
    
      }
      
      func testCollapsing() {
        struct TestRangeElement:ClosedRangeRepresentable {
          let string:String
          let closedRange: ClosedRange<Int>
        }
        
        
        let a01 = TestRangeElement(string: "a", closedRange: 0...1)
        let b12 = TestRangeElement(string: "b", closedRange: 1...2)
        let c23 = TestRangeElement(string: "c", closedRange: 2...3)
        let d03 = TestRangeElement(string: "d", closedRange: 0...3)
        let e45 = TestRangeElement(string: "e", closedRange: 4...5)
        
        let ranges = [a01,b12,c23,d03,e45]
        let collapsed = ranges.collapsed
        let collapsedLength = ranges.collapsedLength
        
        XCTAssertEqual(collapsed, [0...3,4...5])
        XCTAssertEqual(collapsedLength, 4)
        
        
        let ranges2 = [7...9,0...3,1...2,6...9,1...1]
        XCTAssertEqual(ranges2.collapsed, [0...3,6...9])
        XCTAssertEqual(ranges2.collapsedLength, 6)
        
        
      }
      
    }
    
    
    
    

