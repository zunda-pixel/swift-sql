import Foundation
import SQLModelMacro

public protocol Database {
  func select<Value: Model & Identifiable>(id: Value.ID) async throws -> Value
  func insert<Value: Model & Codable>(_ value: Value) async throws
  func update<Value: Model & Codable & Identifiable>(_ value: Value) async throws
  func delete<Value: Model & Identifiable>(_ type: Value.Type, _ id: Value.ID) async throws
}
