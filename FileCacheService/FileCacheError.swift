import Foundation

public enum FileCacheError: String, Error {
    case invalidCachePath = "Error: Invalid cache path."
    case selfNotExist = "Error: Found nil while unwrapping FileCacheService entity."
    case deleteFailed = "Error: Failed to remove item from list."
    case unparsableData = "Error: Failed to parse data after serialization."
    case itemNotExist = "Error: Item not exist"
}
