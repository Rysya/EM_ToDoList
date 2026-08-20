import SwiftUI

@main
struct EM_ToDoListApp: App {

    var body: some Scene {
        WindowGroup {
            TodoListBuilder.build()
                .preferredColorScheme(.dark)
        }
    }
}
