import SwiftUI

struct TodoListView: View {
    @StateObject private var presenter: TodoListPresenter
    @ObservedObject private var router: TodoListRouter

    init(presenter: TodoListPresenter,
         router: TodoListRouter) {
        _presenter = StateObject(wrappedValue: presenter)
        self.router = router
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                searchField
                listTodo
            }
            .navigationTitle("Задачи")
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
            .safeAreaInset(edge: .bottom) {
                footer
            }
            .onAppear {
                presenter.viewDidLoad()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .refreshable {
            presenter.viewDidLoad()
        }
    }

    private var footer: some View {
        TodoFooter(count: presenter.todos.count) {
            presenter.add()
        }
    }

    @ViewBuilder
    private var listTodo: some View {
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
                .onScrollPhaseChange { _, _ in
                    hideKeyboard()
                }
        }
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.secondary)
            TextField("Search", text: $presenter.searchText)
                .font(.system(size: 17))
                .foregroundStyle(.primary)
            Button {
                presenter.didTapVoiceRecording()
            } label: {
                Image(systemName: presenter.isRecording
                      ? "waveform"
                      : "mic.fill")
                .id(presenter.isRecording)
                .transition(.opacity)
                .foregroundStyle(
                    presenter.isRecording
                    ? .red
                    : .secondary
                )
            }
        }
        .animation(.linear(duration: 0.1), value: presenter.isRecording)
        .padding(.horizontal, 16)
        .frame(height: 42)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}
