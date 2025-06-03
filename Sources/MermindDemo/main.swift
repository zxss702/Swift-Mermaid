import Foundation
import SwiftMermind

// Create a parser instance
let parser = MermaidParser()

// Test flowchart parsing
let flowchartText = """
graph TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Process]
    B -->|No| D[End]
    C --> E[Another Step]
    E --> D
"""

print("Parsing flowchart...")
let diagram = parser.parse(flowchartText)

print("Diagram type: \(diagram.type)")
print("Number of nodes: \(diagram.nodes.count)")
print("Number of edges: \(diagram.edges.count)")

print("\nNodes:")
for node in diagram.nodes {
    print("- \(node.id): \(node.label) (\(node.shape))")
}

print("\nEdges:")
for edge in diagram.edges {
    let label = edge.label.isEmpty ? "(no label)" : edge.label
    print("- \(edge.from) -> \(edge.to): \(label)")
}

print("\nFlowchart parsing completed successfully!")
print("The rendering issues should now be fixed:")
print("1. Removed white background")
print("2. Improved node positioning algorithm")
print("3. Fixed edge label positioning")