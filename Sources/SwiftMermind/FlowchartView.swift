import SwiftUI

/// A view that renders a flowchart diagram
public struct FlowchartView: View {
    private let diagram: MermaidDiagram
    private let size: CGSize
    private let nodeSpacing: CGFloat = 80
    private let levelSpacing: CGFloat = 100
    
    public init(diagram: MermaidDiagram, size: CGSize) {
        self.diagram = diagram
        self.size = size
    }
    
    public var body: some View {
        ZStack {
            // Draw edges first so they appear behind nodes
            ForEach(diagram.edges) { edge in
                EdgeView(edge: edge, nodes: diagram.nodes)
            }
            
            // Draw nodes
            ForEach(diagram.nodes) { node in
                NodeView(node: node)
                    .position(calculateNodePosition(node))
            }
        }
        .frame(width: size.width, height: size.height)
    }
    
    private func calculateNodePosition(_ node: Node) -> CGPoint {
        // If the node already has a position, use it
        if node.position != .zero {
            return node.position
        }
        
        // Simple layout algorithm for demonstration
        // In a real implementation, you would use a more sophisticated layout algorithm
        let nodeIndex = diagram.nodes.firstIndex { $0.id == node.id } ?? 0
        let nodesCount = diagram.nodes.count
        
        if nodesCount <= 1 {
            return CGPoint(x: size.width / 2, y: size.height / 2)
        }
        
        // Calculate level based on incoming edges
        var level = 0
        var visited = Set<String>()
        var currentLevel = [node.id]
        
        while !currentLevel.isEmpty {
            var nextLevel = [String]()
            
            for nodeId in currentLevel {
                visited.insert(nodeId)
                
                // Find all nodes that have edges coming into this node
                for edge in diagram.edges where edge.to == nodeId && !visited.contains(edge.from) {
                    nextLevel.append(edge.from)
                }
            }
            
            if nextLevel.isEmpty {
                break
            }
            
            level += 1
            currentLevel = nextLevel
        }
        
        // Calculate horizontal position based on siblings at the same level
        var siblingsAtLevel = [String]()
        for n in diagram.nodes {
            let nodeLevel = calculateNodeLevel(n.id)
            if nodeLevel == level {
                siblingsAtLevel.append(n.id)
            }
        }
        
        let siblingIndex = siblingsAtLevel.firstIndex(of: node.id) ?? 0
        let siblingCount = siblingsAtLevel.count
        
        let x: CGFloat
        if siblingCount <= 1 {
            x = size.width / 2
        } else {
            let availableWidth = size.width - 100 // Padding on both sides
            let step = availableWidth / CGFloat(siblingCount - 1)
            x = 50 + CGFloat(siblingIndex) * step
        }
        
        let y = 50 + CGFloat(level) * levelSpacing
        
        return CGPoint(x: x, y: y)
    }
    
    private func calculateNodeLevel(_ nodeId: String) -> Int {
        var level = 0
        var visited = Set<String>()
        var currentLevel = [nodeId]
        
        while !currentLevel.isEmpty {
            var nextLevel = [String]()
            
            for id in currentLevel {
                visited.insert(id)
                
                // Find all nodes that have edges coming into this node
                for edge in diagram.edges where edge.to == id && !visited.contains(edge.from) {
                    nextLevel.append(edge.from)
                }
            }
            
            if nextLevel.isEmpty {
                break
            }
            
            level += 1
            currentLevel = nextLevel
        }
        
        return level
    }
}

/// A view that renders a node in a diagram
public struct NodeView: View {
    private let node: Node
    private let padding: CGFloat = 10
    
    public init(node: Node) {
        self.node = node
    }
    
    public var body: some View {
        Text(node.label)
            .font(.system(size: node.style.fontSize, weight: node.style.fontWeight))
            .foregroundColor(node.style.textColor)
            .padding(padding)
            .background(
                nodeShape()
                    .fill(node.style.fillColor)
                    .overlay(
                        nodeShape()
                            .stroke(node.style.strokeColor, lineWidth: node.style.strokeWidth)
                    )
            )
    }
    
    private func nodeShape() -> AnyShape {
        switch node.shape {
        case .rectangle:
            return AnyShape(Rectangle())
        case .roundedRectangle:
            return AnyShape(RoundedRectangle(cornerRadius: 8))
        case .circle:
            return AnyShape(Circle())
        case .diamond:
            return AnyShape(Diamond())
        case .hexagon:
            return AnyShape(Hexagon())
        case .parallelogram:
            return AnyShape(Parallelogram())
        case .trapezoid:
            return AnyShape(Trapezoid())
        case .database:
            return AnyShape(Database())
        case .custom:
            // For custom shapes, default to rectangle
            return AnyShape(Rectangle())
        }
    }
}

/// A view that renders an edge between nodes
public struct EdgeView: View {
    private let edge: Edge
    private let nodes: [Node]
    
    public init(edge: Edge, nodes: [Node]) {
        self.edge = edge
        self.nodes = nodes
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let fromNode = nodes.first { $0.id == edge.from }
            let toNode = nodes.first { $0.id == edge.to }
            
            if let fromNode = fromNode, let toNode = toNode {
                let fromPoint = fromNode.position
                let toPoint = toNode.position
                
                ZStack {
                    // Draw the line
                    Path { path in
                        path.move(to: fromPoint)
                        path.addLine(to: toPoint)
                    }
                    .stroke(edge.style.strokeColor, lineWidth: edge.style.strokeWidth)
                    
                    // Draw the arrow
                    if edge.type == .arrow || edge.type == .doubleArrow {
                        ArrowShape(start: fromPoint, end: toPoint)
                            .fill(edge.style.strokeColor)
                    }
                    
                    // Draw the label
                    if !edge.label.isEmpty {
                        Text(edge.label)
                            .font(.system(size: edge.style.fontSize))
                            .foregroundColor(edge.style.textColor)
                            .position(
                                CGPoint(
                                    x: (fromPoint.x + toPoint.x) / 2,
                                    y: (fromPoint.y + toPoint.y) / 2
                                )
                            )
                            .background(Color.white.opacity(0.7))
                            .padding(4)
                    }
                }
            }
        }
    }
}

// MARK: - Custom Shapes

/// A diamond shape
public struct Diamond: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let midY = rect.midY
        
        path.move(to: CGPoint(x: midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: midY))
        path.addLine(to: CGPoint(x: midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: midY))
        path.closeSubpath()
        
        return path
    }
}

/// A hexagon shape
public struct Hexagon: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let midX = rect.midX
        let midY = rect.midY
        
        let quarterWidth = width / 4
        
        path.move(to: CGPoint(x: midX - quarterWidth, y: rect.minY))
        path.addLine(to: CGPoint(x: midX + quarterWidth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: midY))
        path.addLine(to: CGPoint(x: midX + quarterWidth, y: rect.maxY))
        path.addLine(to: CGPoint(x: midX - quarterWidth, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: midY))
        path.closeSubpath()
        
        return path
    }
}

/// A parallelogram shape
public struct Parallelogram: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let skew: CGFloat = rect.width / 4
        
        path.move(to: CGPoint(x: rect.minX + skew, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - skew, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

/// A trapezoid shape
public struct Trapezoid: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset: CGFloat = rect.width / 4
        
        path.move(to: CGPoint(x: rect.minX + inset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

/// A database shape
public struct Database: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midX = rect.midX
        let quarterHeight = height / 4
        
        // Top ellipse
        path.addEllipse(in: CGRect(x: rect.minX, y: rect.minY, width: width, height: quarterHeight * 2))
        
        // Sides
        path.move(to: CGPoint(x: rect.minX, y: quarterHeight))
        path.addLine(to: CGPoint(x: rect.minX, y: height - quarterHeight))
        path.addArc(center: CGPoint(x: midX, y: height - quarterHeight),
                    radius: width / 2,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: quarterHeight))
        
        return path
    }
}

/// An arrow shape
public struct ArrowShape: Shape {
    let start: CGPoint
    let end: CGPoint
    let arrowSize: CGFloat = 10
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let dx = end.x - start.x
        let dy = end.y - start.y
        let angle = atan2(dy, dx)
        
        let endPoint = CGPoint(
            x: end.x - arrowSize * cos(angle),
            y: end.y - arrowSize * sin(angle)
        )
        
        path.move(to: endPoint)
        path.addLine(to: CGPoint(
            x: endPoint.x - arrowSize * cos(angle - .pi / 6),
            y: endPoint.y - arrowSize * sin(angle - .pi / 6)
        ))
        path.addLine(to: CGPoint(
            x: endPoint.x - arrowSize * cos(angle + .pi / 6),
            y: endPoint.y - arrowSize * sin(angle + .pi / 6)
        ))
        path.closeSubpath()
        
        return path
    }
}