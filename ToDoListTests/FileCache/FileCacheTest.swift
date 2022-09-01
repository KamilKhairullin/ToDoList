@testable import ToDoList
import XCTest

class FileCacheTest: XCTestCase {
    override func setUpWithError() throws {
        let fileCache = FileCache()
        try fileCache.todoItems.forEach {
            try fileCache.delete($0.id)
        }
    }

    func test_addAndDelete() throws {
        let cache = FileCache()
        let task1 = TodoItem(text: "1", priority: .ordinary)
        sleep(UInt32(0.1))
        let task2 = TodoItem(text: "2", priority: .important)
        sleep(UInt32(0.1))
        let task3 = TodoItem(text: "3", priority: .unimportant)
        try cache.insert(task1)
        try cache.insert(task2)
        try cache.insert(task3)
        try cache.delete(task1.id)
        XCTAssertEqual(cache.todoItems.map { $0.id }, [task2.id, task3.id])
    }

    func test_todoitems() throws {
        let cache = FileCache()
        XCTAssert(cache.todoItems.isEmpty)
    }

    func test_uniqueIds() throws {
        let cache = FileCache()
        let task1 = TodoItem(id: "sAmE-1d", text: "Hellow", priority: .unimportant)
        let task2 = TodoItem(id: "sAmE-1d", text: "World", priority: .important)
        try cache.insert(task1)
        XCTAssertThrowsError(try cache.insert(task2))
    }

    func test_LoadFromPath() throws {
        let cache = FileCache()
        let task1 = TodoItem(id: "sAmE-1d", text: "Hellow", priority: .unimportant)
        try cache.insert(task1)
        let cache2 = FileCache()
        try? cache2.load()
        XCTAssert(cache.todoItems.map { $0.id } == cache2.todoItems.map { $0.id })
    }
}

extension FileCacheTest {
    private func cachePath(for file: String) -> URL? {
        guard let cachePath = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first
        else {
            print("Unable to find cache directory")
            return nil
        }
        return cachePath.appendingPathComponent(file)
    }
}
