import Foundation

public enum FileCacheError: String, Error {
    case invalidCachePath = "Error: Invalid cache path."
    case saveFailed = "Error: Saving data to file failed."
    case selfNotExist = "Error: Found nil while unwrapping FileCacheService entity."
    case deleteFailed = "Error: Failed to remove item from list."
    case unparsableData = "Error: Failed to parse data after serialization."
}
