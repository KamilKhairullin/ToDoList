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
        cache.addTask(task1)
        cache.addTask(task2)
        cache.addTask(task3)
        _ = cache.deleteTask(id: task1.id)
        XCTAssertEqual(cache.todoItems.map { $0.id }, [task2.id, task3.id])
        XCTAssertNil(cache.deleteTask(id: task4.id))
    }

    func test_todoitems() throws {
        let cache = FileCache()
        XCTAssert(cache.todoItems.isEmpty)
    }

    func test_uniqueIds() throws {
        let cache = FileCache()
        let task1 = TodoItem(id: "sAmE-1d", text: "Hellow", priority: .unimportant)
        let task2 = TodoItem(id: "sAmE-1d", text: "World", priority: .important)
        cache.addTask(task1)
        cache.addTask(task2)
        XCTAssertNil(cache.todoItems.first(where: { $0.text == task1.text }))
    }

    func test_save_jsonError() throws {
        let items: [String: Any] = ["1": true, "2": false]
        let json = try JSONSerialization.data(withJSONObject: items, options: [])
        try json.write(to: getCachePath(for: "mock.json")!, options: [])
        let cache = FileCache()
        cache.load(from: "mock.json")
        XCTAssert(cache.todoItems.isEmpty)
    }

    func test_LoadFromPath() throws {
        let cache = FileCache()
        let task1 = TodoItem(id: "sAmE-1d", text: "Hellow", priority: .unimportant)
        cache.addTask(task1)
        cache.load(from: "/")
        XCTAssert(cache.todoItems.map { $0.id } == [task1.id])
    }
}

extension FileCacheTest {
    private func getCachePath(for file: String) -> URL? {
        guard let cachePath = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first
        else {
            print("Unable to find cache directory")
            return nil
        }
        print(cachePath.appendingPathComponent(file))
        return cachePath.appendingPathComponent(file)
    }
}
