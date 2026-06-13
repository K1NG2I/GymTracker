import SwiftUI
import SwiftData

// MARK: - TemplateListView
// Tab 3: Browse, create, and manage workout templates.
// Built-in templates are shown with a badge. Users can duplicate templates.
struct TemplateListView: View {
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse)
    private var templates: [WorkoutTemplate]

    @State private var showingCreate = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if templates.isEmpty {
                    EmptyStateView.noTemplates()
                } else {
                    List {
                        ForEach(filteredTemplates) { template in
                            NavigationLink {
                                TemplateDetailView(template: template)
                            } label: {
                                TemplateRow(template: template)
                            }
                        }
                        .onDelete(perform: deleteTemplates)
                    }
                }
            }
            .navigationTitle("Templates")
            .searchable(text: $searchText, prompt: "Search templates")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreate = true
                    } label: {
                        Label("New Template", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreate) {
                CreateTemplateView()
            }
        }
    }

    private var filteredTemplates: [WorkoutTemplate] {
        if searchText.isEmpty { return templates }
        return templates.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func deleteTemplates(at offsets: IndexSet) {
        // Don't allow deleting built-in templates
        let deletable = filteredTemplates.enumerated().filter { !$0.element.isBuiltIn }
        for (_, template) in deletable where offsets.contains(where: { filteredTemplates[$0].id == template.id }) {
            template.exercises.forEach { template.modelContext?.delete($0) }
            template.modelContext?.delete(template)
        }
        try? templates.first?.modelContext?.save()
    }
}

// MARK: - TemplateRow
struct TemplateRow: View {
    let template: WorkoutTemplate

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appAccent.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "list.bullet.clipboard")
                    .foregroundStyle(Color.appAccent)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(template.name)
                        .font(.body.bold())

                    if template.isBuiltIn {
                        Text("Built-in")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue.opacity(0.15))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 8) {
                    Text("\(template.exercises.count) exercises")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !template.templateDescription.isEmpty {
                        Text(template.templateDescription)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
