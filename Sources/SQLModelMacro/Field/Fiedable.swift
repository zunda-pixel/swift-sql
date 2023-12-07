import Foundation

public protocol Fiedable { }

extension String: Fiedable { }
extension Int: Fiedable { }
extension Double: Fiedable { }
extension URL: Fiedable { }
extension UUID: Fiedable { }
extension Bool: Fiedable { }
