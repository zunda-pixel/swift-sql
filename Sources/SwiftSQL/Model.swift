public protocol Model {
  static var scheme: String { get }
}

extension Model {
  static var scheme: String { String(describing: Self.self) }
}
