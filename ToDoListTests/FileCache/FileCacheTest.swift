@testable import ToDoList
import XCTest

class FileCacheTest: XCTestCase {
    func test_addAndDelete() throws {
        let cache = FileCache()
        let task1 = TodoItem(text: "1", priority: .ordinary)
        sleep(UInt32(0.1))
        let task2 = TodoItem(text: "2", priority: .important)
        sleep(UInt32(0.1))
        let task3 = TodoItem(text: "3", priority: .unimportant)
        let task4 = TodoItem(text: "4", priority: .unimportant)
        cache.add(task1)
        cache.add(task2)
        cache.add(task3)
        cache.delete(id: task1.id)
        XCTAssertEqual(cache.todoItems.map { $0.id }, [task2.id, task3.id])
        XCTAssertNil(cache.delete(id: task4.id))
    }

    func test_todoitems() throws {
        let cache = FileCache()
        XCTAssert(cache.todoItems.isEmpty)
    }

    func test_uniqueIds() throws {
        let cache = FileCache()
        let task1 = TodoItem(id: "sAmE-1d", text: "Hellow", priority: .unimportant)
        let task2 = TodoItem(id: "sAmE-1d", text: "World", priority: .important)
        cache.add(task1)
        cache.add(task2)
        XCTAssertNil(cache.todoItems.first(where: { $0.text == task1.text }))
    }

    func test_save_jsonError() throws {
        let items: [String: Any] = ["1": true, "2": false]
        let json = try JSONSerialization.data(withJSONObject: items, options: [])
        try json.write(to: cachePath(for: "mock.json")!, options: [])
        let cache = FileCache()
        try? cache.load(from: "mock.json")
        XCTAssert(cache.todoItems.isEmpty)
    }

    func test_LoadFromPath() throws {
        let cache = FileCache()
        let task1 = TodoItem(id: "sAmE-1d", text: "Hellow", priority: .unimportant)
        cache.add(task1)
        try? cache.save(to: "saved.json")
        let cache2 = FileCache()
        try? cache2.load(from: "saved.json")
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
