import SwiftUI

struct TodoListView: View {
    @StateObject private var presenter: TodoListPresenter
    @ObservedObject private var router: TodoListRouter
    @State private var searchText = ""
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    init(presenter: TodoListPresenter,
         router: TodoListRouter) {
        _presenter = StateObject(wrappedValue: presenter)
        self.router = router
    }
    
    private var footer: some View {
        TodoFooter(
            count: presenter.todos.count,
            onAdd: {
                presenter.add()
            }
        )
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.secondary)
                    TextField("Search", text: $searchText)
                        .font(.system(size: 17))
                        .foregroundStyle(.primary)
                    Button {
                            Task {
                                let allowed = await speechRecognizer.requestPermission()
                                guard allowed else { return }
                                speechRecognizer.toggleRecording()
                            }
                        } label: {
                            Image(
                                systemName: speechRecognizer.isRecording
                                    ? "waveform"
                                    : "mic.fill"
                            )
                            .foregroundStyle(
                                speechRecognizer.isRecording
                                    ? .red
                                    : .secondary
                            )
                        }
                }
                .padding(.horizontal, 16)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
                Group {
                    switch presenter.state {
                        case .loading:
                            ProgressView("Загрузка…")
                        case .empty:
                            ContentUnavailableView("Нет задач", systemImage: "checklist", description: Text("Добавьте первую задачу"))
                        case .ready:
                            List {
                                ForEach(presenter.todos) { todo in
                                    TodoRow(todo: todo,
                                            presenter: presenter)
                                        .onTapGesture { presenter.edit(todo) }
                                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                            Button { presenter.toggle(todo) } label: {
                                                Label(todo.isCompleted ? "Вернуть" : "Готово", systemImage: todo.isCompleted ? "arrow.uturn.backward" : "checkmark")
                                            }
                                            .tint(.yellow)
                                        }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) { presenter.delete(todo) } label: {
                                                Label("Удалить", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .listStyle(.plain)
                        }
                }
            }
            .navigationTitle("Задачи")
            .onChange(of: speechRecognizer.text) { _, newValue in
                searchText = newValue
            }
            .onChange(of: searchText) { _, value in presenter.search(value) }
            .navigationDestination(for: TodoListRouter.Route.self) { route in
                switch route {
                    case .create:
                        TodoDetailView(presenter: TodoDetailBuilder.build(todo: nil, router: router))
                    case .edit(let todo):
                        TodoDetailView(presenter: TodoDetailBuilder.build(todo: todo, router: router))
                }
            }
            .alert("Ошибка", isPresented: Binding(get: { presenter.errorMessage != nil }, set: { if !$0 { presenter.errorMessage = nil } })) {
                Button("OK") { presenter.errorMessage = nil }
            } message: {
                Text(presenter.errorMessage ?? "")
            }
            .overlay(alignment: .top) {
                if presenter.state == .loading && !presenter.todos.isEmpty { ProgressView().padding(.top, 4) }
            }
            .safeAreaInset(edge: .bottom) {
                footer
            }
            .onAppear {
                presenter.viewDidLoad()
            }
        }
        .task { presenter.viewDidLoad() }
        .refreshable {
            presenter.viewDidLoad()
        }
    }
}
