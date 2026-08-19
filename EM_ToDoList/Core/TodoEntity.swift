import CoreData

@objc(TodoEntity)
final class TodoEntity: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var title: String?
    @NSManaged var todoDescription: String?
    @NSManaged var createdAt: Date?
    @NSManaged var isCompleted: Bool
}
