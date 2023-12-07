import XCTest
@testable import SwiftSQL
import SwiftSyntax
import MacroTesting
import SQLModelMacro

final class SwiftSQLTests: XCTestCase {
  func testModelMacro() {
    assertMacro(["Model": SQLModelMacro.self]) {
      """
      @Model
      struct Person {
        var neme: Int
        @ModelIgnored var name1: Int
        var name2: Int { self.neme }
        var name3 = true
        var name4 = ""
        var name5 = 1
        var name6 = 1.0
      }
      """
    } expansion: {
      """
      struct Person {
        @Field
        var neme: Int
        @ModelIgnored var name1: Int
        var name2: Int { self.neme }
        @Field
        var name3 = true
        @Field
        var name4 = ""
        @Field
        var name5 = 1
        @Field
        var name6 = 1.0

        static public let fields: [PartialKeyPath<Person>: any Fiedable.Type] = [\\.neme: Int.self, \\.name3: Bool.self, \\.name4: String.self, \\.name5: Int.self, \\.name6: Double.self]
      }
      """
    }
  }
}
