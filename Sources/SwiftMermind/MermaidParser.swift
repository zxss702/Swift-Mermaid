import Foundation

/// Represents the type of Mermaid diagram
public enum DiagramType {
    case flowchart
    case sequenceDiagram
    case classDiagram
    case stateDiagram
    case gantt
    case pie
    case gitGraph
    case erDiagram
    case userJourney
    case unknown
}

/// Represents a parsed Mermaid diagram
public struct MermaidDiagram {
    public let type: DiagramType
    public let nodes: [Node]
    public let edges: [Edge]
    public let rawText: String
    public let parsedData: [String: Any]
    
    public init(type: DiagramType, nodes: [Node] = [], edges: [Edge] = [], rawText: String, parsedData: [String: Any] = [:]) {
        self.type = type
        self.nodes = nodes
        self.edges = edges
        self.rawText = rawText
        self.parsedData = parsedData
    }
}

/// Represents a node in a diagram
public struct Node: Identifiable {
    public let id: String
    public let label: String
    public let shape: NodeShape
    public let position: CGPoint
    public let style: NodeStyle
    
    public init(id: String, label: String, shape: NodeShape = .rectangle, position: CGPoint = .zero, style: NodeStyle = NodeStyle()) {
        self.id = id
        self.label = label
        self.shape = shape
        self.position = position
        self.style = style
    }
}

/// Represents the shape of a node
public enum NodeShape {
    case rectangle
    case roundedRectangle
    case circle
    case diamond
    case hexagon
    case parallelogram
    case trapezoid
    case database
    case custom(String)
}

/// Represents the style of a node
public struct NodeStyle {
    public let fillColor: Color
    public let strokeColor: Color
    public let strokeWidth: CGFloat
    public let textColor: Color
    public let fontSize: CGFloat
    public let fontWeight: Font.Weight
    
    public init(
        fillColor: Color = .white,
        strokeColor: Color = .black,
        strokeWidth: CGFloat = 1.0,
        textColor: Color = .black,
        fontSize: CGFloat = 14.0,
        fontWeight: Font.Weight = .regular
    ) {
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.textColor = textColor
        self.fontSize = fontSize
        self.fontWeight = fontWeight
    }
}

/// Represents an edge (connection) between nodes
public struct Edge: Identifiable {
    public let id: UUID
    public let from: String
    public let to: String
    public let label: String
    public let style: EdgeStyle
    public let type: EdgeType
    
    public init(
        id: UUID = UUID(),
        from: String,
        to: String,
        label: String = "",
        style: EdgeStyle = EdgeStyle(),
        type: EdgeType = .solid
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.label = label
        self.style = style
        self.type = type
    }
}

/// Represents the style of an edge
public struct EdgeStyle {
    public let strokeColor: Color
    public let strokeWidth: CGFloat
    public let textColor: Color
    public let fontSize: CGFloat
    
    public init(
        strokeColor: Color = .black,
        strokeWidth: CGFloat = 1.0,
        textColor: Color = .black,
        fontSize: CGFloat = 12.0
    ) {
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.textColor = textColor
        self.fontSize = fontSize
    }
}

/// Represents the type of edge
public enum EdgeType: Equatable {
    case solid
    case dashed
    case dotted
    case arrow
    case doubleArrow
    case custom(String)
    
    public static func == (lhs: EdgeType, rhs: EdgeType) -> Bool {
        switch (lhs, rhs) {
        case (.solid, .solid), (.dashed, .dashed), (.dotted, .dotted), (.arrow, .arrow), (.doubleArrow, .doubleArrow):
            return true
        case (.custom(let lhsValue), .custom(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

/// Parser for Mermaid diagram syntax
public class MermaidParser {
    public init() {}
    
    /// Parse Mermaid diagram text into a structured representation
    /// - Parameter text: The Mermaid diagram text
    /// - Returns: A structured representation of the diagram
    public func parse(_ text: String) -> MermaidDiagram {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = trimmedText.components(separatedBy: .newlines)
        
        guard let firstLine = lines.first?.trimmingCharacters(in: .whitespaces) else {
            return MermaidDiagram(type: .unknown, rawText: text)
        }
        
        let diagramType = determineDiagramType(firstLine)
        
        switch diagramType {
        case .flowchart:
            return parseFlowchart(text)
        case .sequenceDiagram:
            return parseSequenceDiagram(text)
        case .classDiagram:
            return parseClassDiagram(text)
        case .stateDiagram:
            return parseStateDiagram(text)
        case .gantt:
            return parseGantt(text)
        case .pie:
            return parsePieChart(text)
        case .gitGraph:
            return parseGitGraph(text)
        case .erDiagram:
            return parseERDiagram(text)
        case .userJourney:
            return parseUserJourney(text)
        case .unknown:
            return MermaidDiagram(type: .unknown, rawText: text)
        }
    }
    
    private func determineDiagramType(_ firstLine: String) -> DiagramType {
        let lowercasedLine = firstLine.lowercased()
        
        if lowercasedLine.hasPrefix("graph") || lowercasedLine.hasPrefix("flowchart") {
            return .flowchart
        } else if lowercasedLine.hasPrefix("sequencediagram") {
            return .sequenceDiagram
        } else if lowercasedLine.hasPrefix("classdiagram") {
            return .classDiagram
        } else if lowercasedLine.hasPrefix("statediagram") {
            return .stateDiagram
        } else if lowercasedLine.hasPrefix("gantt") {
            return .gantt
        } else if lowercasedLine.hasPrefix("pie") {
            return .pie
        } else if lowercasedLine.hasPrefix("gitgraph") {
            return .gitGraph
        } else if lowercasedLine.hasPrefix("erdiagram") {
            return .erDiagram
        } else if lowercasedLine.hasPrefix("journey") {
            return .userJourney
        } else {
            return .unknown
        }
    }
    
    // MARK: - Diagram-specific parsers
    
    private func parseFlowchart(_ text: String) -> MermaidDiagram {
        var nodes: [Node] = []
        var edges: [Edge] = []
        var nodeIds = Set<String>()
        
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines and graph declaration
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("graph") || trimmedLine.hasPrefix("flowchart") {
                continue
            }
            
            // Parse nodes and edges from the line
            parseFlowchartLine(trimmedLine, nodes: &nodes, edges: &edges, nodeIds: &nodeIds)
        }
        
        return MermaidDiagram(type: .flowchart, nodes: nodes, edges: edges, rawText: text)
    }
    
    private func parseFlowchartLine(_ line: String, nodes: inout [Node], edges: inout [Edge], nodeIds: inout Set<String>) {
        // Handle different arrow types
        let arrowPatterns = ["-->", "--->", "-.->", "==>", "-.->"]
        
        for arrowPattern in arrowPatterns {
            if line.contains(arrowPattern) {
                let parts = line.components(separatedBy: arrowPattern)
                if parts.count >= 2 {
                    let fromPart = parts[0].trimmingCharacters(in: .whitespaces)
                    let toPart = parts[1].trimmingCharacters(in: .whitespaces)
                    
                    // Extract node info from left side
                    let (fromId, fromLabel, fromShape) = extractNodeInfo(fromPart)
                    
                    // Extract node info and edge label from right side
                    let (toId, toLabel, toShape, edgeLabel) = extractNodeInfoWithEdgeLabel(toPart)
                    
                    // Add nodes if not already added
                    if !nodeIds.contains(fromId) {
                        nodes.append(Node(id: fromId, label: fromLabel, shape: fromShape))
                        nodeIds.insert(fromId)
                    }
                    
                    if !nodeIds.contains(toId) {
                        nodes.append(Node(id: toId, label: toLabel, shape: toShape))
                        nodeIds.insert(toId)
                    }
                    
                    // Add edge
                    edges.append(Edge(from: fromId, to: toId, label: edgeLabel))
                    
                    return // Found an arrow, processed the line
                }
            }
        }
    }
    
    private func extractNodeInfo(_ nodeString: String) -> (id: String, label: String, shape: NodeShape) {
        let trimmed = nodeString.trimmingCharacters(in: .whitespaces)
        
        // Check for different node shapes
        if let match = trimmed.range(of: #"([A-Za-z0-9_]+)\[([^\]]+)\]"#, options: .regularExpression) {
            let matchString = String(trimmed[match])
            let components = matchString.components(separatedBy: "[")
            if components.count >= 2 {
                let id = components[0]
                let label = components[1].replacingOccurrences(of: "]", with: "")
                return (id, label, .rectangle)
            }
        }
        
        if let match = trimmed.range(of: #"([A-Za-z0-9_]+)\(([^\)]+)\)"#, options: .regularExpression) {
            let matchString = String(trimmed[match])
            let components = matchString.components(separatedBy: "(")
            if components.count >= 2 {
                let id = components[0]
                let label = components[1].replacingOccurrences(of: ")", with: "")
                return (id, label, .roundedRectangle)
            }
        }
        
        if let match = trimmed.range(of: #"([A-Za-z0-9_]+)\{([^\}]+)\}"#, options: .regularExpression) {
            let matchString = String(trimmed[match])
            let components = matchString.components(separatedBy: "{")
            if components.count >= 2 {
                let id = components[0]
                let label = components[1].replacingOccurrences(of: "}", with: "")
                return (id, label, .diamond)
            }
        }
        
        // Default case - just an ID
        return (trimmed, trimmed, .rectangle)
    }
    
    private func extractNodeInfoWithEdgeLabel(_ nodeString: String) -> (id: String, label: String, shape: NodeShape, edgeLabel: String) {
        var workingString = nodeString.trimmingCharacters(in: .whitespaces)
        var edgeLabel = ""
        
        // Check for edge label in format |label|
        if let labelMatch = workingString.range(of: #"\|([^\|]+)\|"#, options: .regularExpression) {
            let labelString = String(workingString[labelMatch])
            edgeLabel = labelString.replacingOccurrences(of: "|", with: "")
            workingString = workingString.replacingOccurrences(of: labelString, with: "").trimmingCharacters(in: .whitespaces)
        }
        
        let (id, label, shape) = extractNodeInfo(workingString)
        return (id, label, shape, edgeLabel)
    }
    
    private func parseSequenceDiagram(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .sequenceDiagram, rawText: text)
    }
    
    private func parseClassDiagram(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .classDiagram, rawText: text)
    }
    
    private func parseStateDiagram(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .stateDiagram, rawText: text)
    }
    
    private func parseGantt(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .gantt, rawText: text)
    }
    
    private func parsePieChart(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .pie, rawText: text)
    }
    
    private func parseGitGraph(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .gitGraph, rawText: text)
    }
    
    private func parseERDiagram(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .erDiagram, rawText: text)
    }
    
    private func parseUserJourney(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .userJourney, rawText: text)
    }
}

// Add SwiftUI Color extension for convenience
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}