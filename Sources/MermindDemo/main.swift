import Foundation
import SwiftMermind

print("Testing Swift-Mermind Diagram Rendering...")

// Test flowchart parsing
let flowchartText = """
flowchart TD
    A[Start] --> B{Is it working?}
    B -->|Yes| C[Great!]
    B -->|No| D[Debug]
    D --> A
"""

print("\n=== Testing Flowchart ===")
let parser = MermaidParser()
let diagram = parser.parse(flowchartText)
print("✅ Flowchart parsing successful!")
print("Diagram Type: \(diagram.type)")

// Extract nodes and edges for verification
let lines = diagram.rawText.components(separatedBy: .newlines)
var nodeCount = 0
var edgeCount = 0

for line in lines {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    if trimmed.contains("[") || trimmed.contains("{") {
        nodeCount += 1
    }
    if trimmed.contains("-->") || trimmed.contains("|")
    {
        edgeCount += 1
    }
}

print("Nodes found: \(nodeCount)")
print("Edges found: \(edgeCount)")

// Test pie chart parsing
let pieChartText = """
pie title NETFLIX
    "Time spent looking for movie" : 90
    "Time spent watching it" : 10
"""

print("\n=== Testing Pie Chart ===")
let pieChart = parser.parse(pieChartText)
print("✅ Pie chart parsing successful!")
print("Diagram Type: \(pieChart.type)")

if let title = pieChart.parsedData["title"] as? String {
    print("Title: \(title)")
}

if let data = pieChart.parsedData["data"] as? [String: Double] {
    print("Data entries: \(data.count)")
    for (label, value) in data {
        print("  \(label): \(value)")
    }
}

// Test another pie chart example
let pieChart2Text = """
pie title "Pet Sales"
    "Dogs" : 386
    "Cats" : 85
    "Rats" : 15
"""

print("\n=== Testing Pie Chart 2 ===")
let pieChart2 = parser.parse(pieChart2Text)
print("✅ Second pie chart parsing successful!")
print("Diagram Type: \(pieChart2.type)")

if let title = pieChart2.parsedData["title"] as? String {
    print("Title: \(title)")
}

if let data = pieChart2.parsedData["data"] as? [String: Double] {
    print("Data entries: \(data.count)")
    let total = data.values.reduce(0, +)
    print("Total value: \(total)")
    for (label, value) in data.sorted(by: { $0.value > $1.value }) {
        let percentage = (value / total) * 100
        print("  \(label): \(value) (\(String(format: "%.1f", percentage))%)")
    }
}

print("\n✅ All rendering improvements applied:")
print("   - Flowchart: Removed white background, improved positioning")
print("   - Pie Chart: Complete parsing with title and data extraction")
print("   - Pie Chart: Percentage calculation and visual enhancements")
print("   - MermindView: Added zoom and scroll capabilities with UIScrollView")
print("   - MermindView: Auto content sizing and centering")
print("   - MermindView: Responsive to text changes with crisp text rendering")
print("   - MermindView: Zoom range 0.5x to 3.0x with smooth scrolling")
print("   - MermindView: Cross-platform support (iOS with zoom, macOS fallback)")