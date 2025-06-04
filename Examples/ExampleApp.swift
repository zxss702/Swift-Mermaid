//
//  ExampleApp.swift
//  SwiftMermaid Example
//
//  This file demonstrates how to use SwiftMermaid in a real SwiftUI application.
//  Copy this code into your own project to get started quickly.
//

import SwiftUI
import SwiftMermaid

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var customDiagramText = SwiftMermaidExamples.flowchartExample
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Flowchart Tab
            NavigationView {
                VStack {
                    Text("Flowchart Example")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    mermaidView.flowchartExample()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding()
                    
                    Spacer()
                }
                .navigationTitle("Flowchart")
            }
            .tabItem {
                Image(systemName: "flowchart")
                Text("Flowchart")
            }
            .tag(0)
            
            // Sequence Diagram Tab
            NavigationView {
                VStack {
                    Text("Sequence Diagram Example")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    mermaidView.sequenceExample()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding()
                    
                    Spacer()
                }
                .navigationTitle("Sequence")
            }
            .tabItem {
                Image(systemName: "arrow.left.arrow.right")
                Text("Sequence")
            }
            .tag(1)
            
            // Pie Chart Tab
            NavigationView {
                VStack {
                    Text("Pie Chart Example")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    mermaidView.pieExample()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding()
                    
                    Spacer()
                }
                .navigationTitle("Pie Chart")
            }
            .tabItem {
                Image(systemName: "chart.pie")
                Text("Pie Chart")
            }
            .tag(2)
            
            // Custom Diagram Tab
            NavigationView {
                VStack {
                    Text("Custom Diagram")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    mermaidView(text: customDiagramText)
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Edit Diagram:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextEditor(text: $customDiagramText)
                            .font(.system(.body, design: .monospaced))
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        Button("Flowchart Example") {
                            customDiagramText = SwiftMermaidExamples.flowchartExample
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Sequence Example") {
                            customDiagramText = SwiftMermaidExamples.sequenceExample
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Pie Example") {
                            customDiagramText = SwiftMermaidExamples.pieExample
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    
                    Spacer()
                }
                .navigationTitle("Custom")
            }
            .tabItem {
                Image(systemName: "pencil.and.outline")
                Text("Custom")
            }
            .tag(3)
            
            // Gallery Tab
            NavigationView {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        DiagramCard(
                            title: "Simple Process Flow",
                            diagram: """
                            graph LR
                                A[Input] --> B[Process]
                                B --> C[Output]
                            """
                        )
                        
                        DiagramCard(
                            title: "Decision Tree",
                            diagram: """
                            graph TD
                                A[Problem] --> B{Solution exists?}
                                B -->|Yes| C[Implement]
                                B -->|No| D[Research]
                                D --> E[Design Solution]
                                E --> C
                                C --> F[Test]
                                F --> G{Works?}
                                G -->|Yes| H[Deploy]
                                G -->|No| I[Debug]
                                I --> F
                            """
                        )
                        
                        DiagramCard(
                            title: "API Communication",
                            diagram: """
                            sequenceDiagram
                                participant Client
                                participant API
                                participant Database
                                
                                Client->>API: Request data
                                API->>Database: Query
                                Database-->>API: Results
                                API-->>Client: Response
                            """
                        )
                        
                        DiagramCard(
                            title: "Project Distribution",
                            diagram: """
                            pie title Project Time Distribution
                                "Development" : 40
                                "Testing" : 25
                                "Planning" : 20
                                "Documentation" : 15
                            """
                        )
                    }
                    .padding()
                }
                .navigationTitle("Gallery")
            }
            .tabItem {
                Image(systemName: "photo.on.rectangle.angled")
                Text("Gallery")
            }
            .tag(4)
        }
    }
}

struct DiagramCard: View {
    let title: String
    let diagram: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            mermaidView(text: diagram)
                .frame(height: 200)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            
            Text("Tap to view code")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture {
            // In a real app, you might show the code in a sheet or detail view
            print("Diagram code:\n\(diagram)")
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Additional Examples

struct AdvancedExamples {
    static let complexFlowchart = """
    graph TD
        A[Start] --> B[Initialize]
        B --> C{Check Config}
        C -->|Valid| D[Load Data]
        C -->|Invalid| E[Show Error]
        D --> F[Process Data]
        F --> G{Has More?}
        G -->|Yes| H[Next Item]
        H --> F
        G -->|No| I[Generate Report]
        I --> J[Save Results]
        J --> K[Notify User]
        K --> L[End]
        E --> M[Exit]
    """
    
    static let userAuthFlow = """
    sequenceDiagram
        participant User
        participant App
        participant AuthService
        participant Database
        
        User->>App: Enter credentials
        App->>AuthService: Validate credentials
        AuthService->>Database: Check user
        Database-->>AuthService: User data
        AuthService-->>App: Auth token
        App-->>User: Login success
        
        Note over User,Database: Secure authentication flow
    """
    
    static let marketShare = """
    pie title Market Share Q4 2023
        "Company A" : 35
        "Company B" : 28
        "Company C" : 20
        "Company D" : 12
        "Others" : 5
    """
}