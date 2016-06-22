import Foundation

/// This is a very simple wrapper of a dict of type `[String: AdapterFactory]`.
///
/// Use it as a normal dict.
class AdapterFactoryManager {
    private var factoryDict: [String: AdapterFactory]

    subscript(index: String) -> AdapterFactory? {
        get {
            if index == "direct" {
                return DirectAdapterFactory()
            }
            return factoryDict[index]
        }
        set { factoryDict[index] = newValue }
    }

    /**
     Initialize a new factory manager.

     - parameter factoryDict: The factory dict.
     */
    init(factoryDict: [String: AdapterFactory]) {
        self.factoryDict = factoryDict
    }
}
