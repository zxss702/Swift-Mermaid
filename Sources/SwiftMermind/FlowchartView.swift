import SwiftUI

/// A view that renders a flowchart diagram
public struct FlowchartView: View {
    private let diagram: MermaidDiagram
    private let nodeSpacing: CGFloat = 150
    private let levelSpacing: CGFloat = 100
    
    public init(diagram: MermaidDiagram) {
        self.diagram = diagram
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw edges first (so they appear behind nodes)
                ForEach(diagram.edges.indices, id: \.self) { index in
                    EdgeView(edge: diagram.edges[index], nodes: nodesWithPositions(in: geometry.size))
                }
                
                // Draw nodes
                ForEach(nodesWithPositions(in: geometry.size), id: \.id) { node in
                    NodeView(node: node)
                        .position(node.position)
                }
            }
        }
        .background(Color.clear)
    }
    
    private func nodesWithPositions(in size: CGSize) -> [Node] {
        var positionedNodes = diagram.nodes
        
        // Calculate positions for all nodes
        for i in 0..<positionedNodes.count {
            let level = calculateNodeLevel(positionedNodes[i])
            let nodesAtLevel = diagram.nodes.filter { calculateNodeLevel($0) == level }
            let indexAtLevel = nodesAtLevel.firstIndex(where: { $0.id == positionedNodes[i].id }) ?? 0
            
            // Center the layout in the available space
            let totalWidth = max(1, nodesAtLevel.count) * Int(nodeSpacing)
            let startX = (size.width - CGFloat(totalWidth)) / 2 + nodeSpacing / 2
            
            let x = startX + CGFloat(indexAtLevel) * nodeSpacing
            let y = CGFloat(level) * levelSpacing + levelSpacing / 2
            
            positionedNodes[i].position = CGPoint(x: x, y: y)
        }
        
        return positionedNodes
    }
    
    private func calculateNodeLevel(_ node: Node) -> Int {
        // Find the maximum depth from any root node to this node
        var maxLevel = 0
        let rootNodes = findRootNodes()
        
        for rootId in rootNodes {
            let level = calculateLevelFromRoot(rootId, to: node.id, visited: Set<String>())
            maxLevel = max(maxLevel, level)
        }
        
        return maxLevel
    }
    
    private func findRootNodes() -> [String] {
        let allNodeIds = Set(diagram.nodes.map { $0.id })
        let targetNodes = Set(diagram.edges.map { $0.to })
        return Array(allNodeIds.subtracting(targetNodes))
    }
    
    private func calculateLevelFromRoot(_ rootId: String, to targetId: String, visited: Set<String>) -> Int {
        if rootId == targetId {
            return 0
        }
        
        if visited.contains(rootId) {
            return -1 // Cycle detected
        }
        
        var newVisited = visited
        newVisited.insert(rootId)
        
        var maxLevel = -1
        for edge in diagram.edges where edge.from == rootId {
            let level = calculateLevelFromRoot(edge.to, to: targetId, visited: newVisited)
            if level >= 0 {
                maxLevel = max(maxLevel, level + 1)
            }
        }
        
        return maxLevel
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