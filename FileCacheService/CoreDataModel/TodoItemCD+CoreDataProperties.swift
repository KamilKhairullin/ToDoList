//
//  TodoItemCD+CoreDataProperties.swift
//  ToDoList
//
//  Created by Kamil on 28.08.2022.
//
//

import Foundation
import CoreData

extension TodoItemCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemCD> {
        return NSFetchRequest<TodoItemCD>(entityName: "TodoItem")
    }

    @NSManaged public var id: String
    @NSManaged public var text: String
    @NSManaged public var deadline: Date?
    @NSManaged public var isDone: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var editedAt: Date?
    @NSManaged public var priority: Priority

}

extension TodoItemCD: Identifiable {

    @objc public enum Priority: Int16 {
        case important
        case ordinary
        case unimportant

        init(from todoItemPriority: TodoItem.Priority) {
            switch todoItemPriority {
            case .important:
                self = .important
            case .ordinary:
                self = .ordinary
            case .unimportant:
                self = .unimportant
            }
        }
    }
}
