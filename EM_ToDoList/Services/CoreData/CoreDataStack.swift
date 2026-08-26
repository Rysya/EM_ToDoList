import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "TodoEntity"
        entity.managedObjectClassName = NSStringFromClass(TodoEntity.self)

        func attribute(_ name: String, _ type: NSAttributeType, optional: Bool = false) -> NSAttributeDescription {
            let result = NSAttributeDescription()
            result.name = name
            result.attributeType = type
            result.isOptional = optional
            return result
        }

        entity.properties = [
            attribute("id", .integer64AttributeType),
            attribute("title", .stringAttributeType, optional: true),
            attribute("todoDescription", .stringAttributeType, optional: true),
            attribute("createdAt", .dateAttributeType, optional: true),
            attribute("isCompleted", .booleanAttributeType)
        ]
        model.entities = [entity]

        persistentContainer = NSPersistentContainer(name: "TodoModel", managedObjectModel: model)
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores { _, error in
            if let error { fatalError("Core Data store failed: \(error)") }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
}
