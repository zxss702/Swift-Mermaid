import SwiftUI

// MARK: - Class Diagram View

/// A view that renders a class diagram
public struct ClassDiagramView: View {
    private let diagram: MermaidDiagram
    private let size: CGSize
    
    public init(diagram: MermaidDiagram, size: CGSize) {
        self.diagram = diagram
        self.size = size
    }
    
    public var body: some View {
        VStack {
            Text("Class Diagram")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Coming Soon")
                .font(.caption)
                .foregroundColor(.gray)
            
            ScrollView {
                Text(diagram.rawText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(width: size.width, height: size.height)
        .padding()
    }
}

// MARK: - State Diagram View

/// A view that renders a state diagram
public struct StateDiagramView: View {
    private let diagram: MermaidDiagram
    private let size: CGSize
    
    public init(diagram: MermaidDiagram, size: CGSize) {
        self.diagram = diagram
        self.size = size
    }
    
    public var body: some View {
        VStack {
            Text("State Diagram")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Coming Soon")
                .font(.caption)
                .foregroundColor(.gray)
            
            ScrollView {
                Text(diagram.rawText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(width: size.width, height: size.height)
        .padding()
    }
}

// MARK: - Gantt Chart View

/// A view that renders a Gantt chart
public struct GanttChartView: View {
    private let diagram: MermaidDiagram
    private let size: CGSize
    
    public init(diagram: MermaidDiagram, size: CGSize) {
        self.diagram = diagram
        self.size = size
    }
    
    public var body: some View {
        VStack {
            Text("Gantt Chart")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Coming Soon")
                .font(.caption)
                .foregroundColor(.gray)
            
            ScrollView {
                Text(diagram.rawText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(width: size.width, height: size.height)
        .padding()
    }
}

// MARK: - Pie Chart View

/// A view that renders a pie chart
public struct PieChartView: View {
    private let diagram: MermaidDiagram
    private let size: CGSize
    
    public init(diagram: MermaidDiagram, size: CGSize) {
        self.diagram = diagram
        self.size = size
    }
    
    public var body: some View {
        let pieData = extractPieData()
        
        VStack {
            Text("Pie Chart")
                .font(.title2)
                .fontWeight(.bold)
            
            if !pieData.isEmpty {
                ZStack {
                    ForEach(0..<pieData.count, id: \.self) { index in
                        PieSlice(
                            startAngle: calculateStartAngle(index: index, data: pieData),
                            endAngle: calculateEndAngle(index: index, data: pieData)
                        )
                        .fill(pieColors[index % pieColors.count])
                    }
                }
                .frame(width: min(size.width, size.height) * 0.6)
                
                // Legend
                VStack(alignment: .leading) {
                    ForEach(0..<pieData.count, id: \.self) { index in
                        HStack {
                            Rectangle()
                                .fill(pieColors[index % pieColors.count])
                                .frame(width: 16, height: 16)
                            
                            Text("\(pieData[index].label): \(pieData[index].value, specifier: "%.1f")")
                                .font(.caption)
                        }
                    }
                }
            } else {
                Text("No data to display")
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size.width, height: size.height)
        .padding()
    }
    
    private let pieColors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .cyan
    ]
    
    private struct PieData {
        let label: String
        let value: Double
    }
    
    private func extractPieData() -> [PieData] {
        let lines = diagram.rawText.components(separatedBy: .newlines)
        var data: [PieData] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Look for lines with quotes and colons
            if trimmedLine.contains(":") && (trimmedLine.contains("\"") || trimmedLine.contains("'")) {
                let parts = trimmedLine.components(separatedBy: ":")
                if parts.count >= 2 {
                    let label = parts[0].trimmingCharacters(in: CharacterSet(charactersIn: "\" '"))
                    let valueString = parts[1].trimmingCharacters(in: .whitespaces)
                    
                    if let value = Double(valueString) {
                        data.append(PieData(label: label, value: value))
                    }
                }
            }
        }
        
        return data
    }
    
    private func calculateStartAngle(index: Int, data: [PieData]) -> Angle {
        let total = data.reduce(0) { $0 + $1.value }
        let previousSum = data.prefix(index).reduce(0) { $0 + $1.value }
        return .degrees(previousSum / total * 360 - 90)
    }
    
    private func calculateEndAngle(index: Int, data: [PieData]) -> Angle {
        let total = data.reduce(0) { $0 + $1.value }
        let currentSum = data.prefix(index + 1).reduce(0) { $0 + $1.value }
        return .degrees(currentSum / total * 360 - 90)
    }
}

/// A pie slice shape
public struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Git Graph View

/// A view that renders a Git graph
public struct GitGraphView: View {
    private let diagram: MermaidDiagram
    private let size: CGSize
    
    public init(diagram: MermaidDiagram, size: CGSize) {
        self.diagram = diagram
        self.size = size
    }
    
    public var body: some View {
        VStack {
            Text("Git Graph")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Coming Soon")
                .font(.caption)
                .foregroundColor(.gray)
            
            ScrollView {
                Text(diagram.rawText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(width: size.width, height: size.height)
        .padding()
    }
}

// MARK: - ER Diagram View

/// A view that renders an ER diagram
public struct ERDiagramView: View {
    private let diagram: MermaidDiagram
    private let size: CGSize
    
    public init(diagram: MermaidDiagram, size: CGSize) {
        self.diagram = diagram
        self.size = size
    }
    
    public var body: some View {
        VStack {
            Text("ER Diagram")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Coming Soon")
                .font(.caption)
                .foregroundColor(.gray)
            
            ScrollView {
                Text(diagram.rawText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(width: size.width, height: size.height)
        .padding()
    }
}

// MARK: - User Journey View

/// A view that renders a user journey diagram
public struct UserJourneyView: View {
    private let diagram: MermaidDiagram
    private let size: CGSize
    
    public init(diagram: MermaidDiagram, size: CGSize) {
        self.diagram = diagram
        self.size = size
    }
    
    public var body: some View {
        VStack {
            Text("User Journey")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Coming Soon")
                .font(.caption)
                .foregroundColor(.gray)
            
            ScrollView {
                Text(diagram.rawText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .frame(width: size.width, height: size.height)
        .padding()
    }
}