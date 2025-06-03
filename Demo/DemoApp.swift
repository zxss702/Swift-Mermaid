//
//  DemoApp.swift
//  SwiftMermind Demo
//
//  A simple demo application to showcase SwiftMermind functionality
//  To use this demo:
//  1. Create a new SwiftUI project in Xcode
//  2. Add SwiftMermind as a package dependency
//  3. Replace the default ContentView with this code
//

import SwiftUI
import SwiftMermind

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoContentView()
        }
    }
}

struct DemoContentView: View {
    @State private var selectedExample = 0
    
    let examples = [
        ("Simple Flowchart", """
        graph TD
            A[Start] --> B{Decision}
            B -->|Yes| C[Process]
            B -->|No| D[End]
            C --> D
        """),
        
        ("Complex Process", """
        graph LR
            A[User Input] --> B[Validate]
            B --> C{Valid?}
            C -->|Yes| D[Save Data]
            C -->|No| E[Show Error]
            D --> F[Send Email]
            E --> A
            F --> G[Log Activity]
            G --> H[End]
        """),
        
        ("Sequence Diagram", """
        sequenceDiagram
            participant User
            participant App
            participant Server
            participant Database
            
            User->>App: Login Request
            App->>Server: Authenticate
            Server->>Database: Check Credentials
            Database-->>Server: User Data
            Server-->>App: Auth Token
            App-->>User: Login Success
        """),
        
        ("Pie Chart", """
        pie title Development Time Distribution
            "Coding" : 45
            "Testing" : 25
            "Planning" : 15
            "Documentation" : 10
            "Meetings" : 5
        """)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title
                Text("SwiftMermind Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Example Picker
                Picker("Select Example", selection: $selectedExample) {
                    ForEach(0..<examples.count, id: \.self) { index in
                        Text(examples[index].0).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Diagram View
                VStack {
                    Text(examples[selectedExample].0)
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    mermindView(text: examples[selectedExample].1)
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                }
                
                // Code Display
                VStack(alignment: .leading) {
                    Text("Mermaid Code:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        Text(examples[selectedExample].1)
                            .font(.system(.caption, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Footer
                Text("Built with SwiftMermind")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    DemoContentView()
}

// MARK: - Additional Demo Views

struct InteractiveDemoView: View {
    @State private var diagramText = SwiftMermindExamples.flowchartExample
    @State private var showingCodeEditor = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Interactive Demo")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Edit Code") {
                    showingCodeEditor = true
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            mermindView(text: diagramText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .padding()
        }
        .sheet(isPresented: $showingCodeEditor) {
            CodeEditorView(text: $diagramText)
        }
    }
}

struct CodeEditorView: View {
    @Binding var text: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $text)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Edit Diagram")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}