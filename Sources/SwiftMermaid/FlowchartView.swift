import SwiftUI

/// A view that renders a flowchart diagram
public struct FlowchartView: View {
    private let diagram: MermaidDiagram
    private let minNodeSpacing: CGFloat = 20  // 减少节点间距以缩小缝隙
    private let minLevelSpacing: CGFloat = 50  // 减少层级间距以缩小缝隙
    
    public init(diagram: MermaidDiagram) {
        self.diagram = diagram
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let positionedNodes = calculateOptimalLayout(in: geometry.size)
            
            ZStack {
                // Draw edges first (so they appear behind nodes)
                ForEach(diagram.edges.indices, id: \.self) { index in
                    CurvedEdgeView(edge: diagram.edges[index], nodes: positionedNodes, edges: diagram.edges)
                }
                
                // Draw nodes
                ForEach(positionedNodes, id: \.id) { node in
                    AdaptiveNodeView(node: node)
                        .position(node.position)
                }
            }
        }
    }
    
    private func calculateOptimalLayout(in size: CGSize) -> [Node] {
        var positionedNodes = diagram.nodes
        let levels = groupNodesByLevel()
        
        // First pass: calculate node sizes
        var nodeSizes: [String: CGSize] = [:]
        for node in positionedNodes {
            nodeSizes[node.id] = calculateNodeSize(for: node)
        }
        
        // Second pass: improved layout with connection-aware positioning
        var yOffset: CGFloat = 30
        
        for (levelIndex, levelNodes) in levels.enumerated() {
            let maxHeightInLevel = levelNodes.compactMap { nodeSizes[$0.id]?.height }.max() ?? 60
            
            // 改进的水平布局算法
            let sortedNodes = sortNodesInLevel(levelNodes, levelIndex: levelIndex)
            let totalRequiredWidth = calculateRequiredWidth(for: sortedNodes, nodeSizes: nodeSizes)
            let availableWidth = size.width - 60 // 留出边距
            let spacing = max(minNodeSpacing, (availableWidth - totalRequiredWidth) / max(1, CGFloat(sortedNodes.count - 1)))
            
            let startX: CGFloat = 30
            var xOffset = startX
            
            for node in sortedNodes {
                if let index = positionedNodes.firstIndex(where: { $0.id == node.id }) {
                    let nodeSize = nodeSizes[node.id] ?? CGSize(width: 100, height: 60)
                    positionedNodes[index].position = CGPoint(
                        x: xOffset + nodeSize.width / 2,
                        y: yOffset + maxHeightInLevel / 2
                    )
                    xOffset += nodeSize.width + spacing
                }
            }
            
            yOffset += maxHeightInLevel + minLevelSpacing
        }
        
        return positionedNodes
    }
    
    // 根据连接关系对同一层级的节点进行排序
    private func sortNodesInLevel(_ nodes: [Node], levelIndex: Int) -> [Node] {
        if nodes.count <= 1 {
            return nodes
        }
        
        // 计算每个节点的连接权重
        var nodeWeights: [String: CGFloat] = [:]
        
        for node in nodes {
            var weight: CGFloat = 0
            
            // 计算入边权重
            let incomingEdges = diagram.edges.filter { $0.to == node.id }
            for edge in incomingEdges {
                if let sourceNode = diagram.nodes.first(where: { $0.id == edge.from }) {
                    let sourceLevel = calculateNodeLevel(sourceNode)
                    if sourceLevel < levelIndex {
                        weight += 1.0 / CGFloat(levelIndex - sourceLevel + 1)
                    }
                }
            }
            
            // 计算出边权重
            let outgoingEdges = diagram.edges.filter { $0.from == node.id }
            weight += CGFloat(outgoingEdges.count) * 0.5
            
            nodeWeights[node.id] = weight
        }
        
        // 按权重排序
        return nodes.sorted { node1, node2 in
            let weight1 = nodeWeights[node1.id] ?? 0
            let weight2 = nodeWeights[node2.id] ?? 0
            return weight1 > weight2
        }
    }
    
    // 计算节点所需的总宽度
    private func calculateRequiredWidth(for nodes: [Node], nodeSizes: [String: CGSize]) -> CGFloat {
        return nodes.compactMap { nodeSizes[$0.id]?.width }.reduce(0, +)
    }
    
    private func groupNodesByLevel() -> [[Node]] {
        let maxLevel = diagram.nodes.map { calculateNodeLevel($0) }.max() ?? 0
        var levels: [[Node]] = Array(repeating: [], count: maxLevel + 1)
        
        for node in diagram.nodes {
            let level = calculateNodeLevel(node)
            levels[level].append(node)
        }
        
        return levels
    }
    
    private func calculateNodeSize(for node: Node) -> CGSize {
        let text = node.label
        
        // Estimate text size based on character count and font size
        let fontSize = node.style.fontSize
        let estimatedCharWidth = fontSize * 0.6
        let estimatedLineHeight = fontSize * 1.2
        
        // Calculate approximate text dimensions
        let maxCharsPerLine = Int(200 / estimatedCharWidth)
        let lines = max(1, Int(ceil(Double(text.count) / Double(maxCharsPerLine))))
        
        let textWidth = min(200, CGFloat(text.count) * estimatedCharWidth)
        let textHeight = CGFloat(lines) * estimatedLineHeight
        
        let padding: CGFloat = 16  // 减少内边距
        let minWidth: CGFloat = node.shape == .diamond ? 100 : 70  // 减少最小宽度
        let minHeight: CGFloat = node.shape == .diamond ? 70 : 45  // 减少最小高度
        
        return CGSize(
            width: max(minWidth, textWidth + padding),
            height: max(minHeight, textHeight + padding)
        )
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

/// A view that renders a node with adaptive text wrapping
public struct AdaptiveNodeView: View {
    private let node: Node
    private let padding: CGFloat = 8  // 减少padding以匹配节点尺寸计算
    
    public init(node: Node) {
        self.node = node
    }
    
    public var body: some View {
        Text(node.label)
            .font(.system(size: node.style.fontSize, weight: node.style.fontWeight))
            .foregroundColor(node.style.textColor)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(padding)
            .frame(maxWidth: 200)
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
            return AnyShape(RoundedRectangle(cornerRadius: 4))
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
            return AnyShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

/// Legacy NodeView for compatibility
public struct NodeView: View {
    private let node: Node
    private let padding: CGFloat = 10
    
    public init(node: Node) {
        self.node = node
    }
    
    public var body: some View {
        AdaptiveNodeView(node: node)
    }
}

/// A view that renders curved edges between nodes
public struct CurvedEdgeView: View {
    private let edge: Edge
    private let nodes: [Node]
    private let edges: [Edge]  // 添加所有边的引用
    
    public init(edge: Edge, nodes: [Node], edges: [Edge] = []) {
        self.edge = edge
        self.nodes = nodes
        self.edges = edges
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let fromNode = nodes.first { $0.id == edge.from }
            let toNode = nodes.first { $0.id == edge.to }
            
            if let fromNode = fromNode, let toNode = toNode {
                let (edgeFromPoint, edgeToPoint, controlPoints) = calculateCurvedPath(from: fromNode, to: toNode)
                
                ZStack {
                    // 根据控制点决定是画直线还是曲线
                    Path { path in
                        path.move(to: edgeFromPoint)
                        if controlPoints.count >= 2 {
                            // 使用曲线
                            path.addCurve(
                                to: edgeToPoint,
                                control1: controlPoints[0],
                                control2: controlPoints[1]
                            )
                        } else {
                            // 使用直线
                            path.addLine(to: edgeToPoint)
                        }
                    }
                    .stroke(edge.style.strokeColor, lineWidth: edge.style.strokeWidth)
                    
                    // Draw the arrow
                    Group {
                        if edge.type == .arrow || edge.type == .doubleArrow {
                            let arrowAngle: Double = {
                                if controlPoints.count >= 2 {
                                    // 对于曲线，使用最后一个控制点到终点的角度
                                    let lastControl = controlPoints[1]
                                    return atan2(edgeToPoint.y - lastControl.y, edgeToPoint.x - lastControl.x)
                                } else {
                                    // 对于直线，使用从起点到终点的角度
                                    return atan2(edgeToPoint.y - edgeFromPoint.y, edgeToPoint.x - edgeFromPoint.x)
                                }
                            }()
                            
                            CurvedArrowShape(endPoint: edgeToPoint, angle: arrowAngle)
                                .fill(edge.style.strokeColor)
                        }
                    }
                    
                    // Draw the label
                    Group {
                        if !edge.label.isEmpty {
                            let midPoint = calculateMidPoint(start: edgeFromPoint, end: edgeToPoint, controlPoints: controlPoints)
                            Text(edge.label)
                                .font(.system(size: edge.style.fontSize))
                                .foregroundColor(edge.style.textColor)
                                .padding(6)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.9))
                                        .shadow(radius: 1)
                                )
                                .position(midPoint)
                        }
                    }
                }
            }
        }
    }
    
    private func calculateCurvedPath(from fromNode: Node, to toNode: Node) -> (CGPoint, CGPoint, [CGPoint]) {
        let fromCenter = fromNode.position
        let toCenter = toNode.position
        
        // Calculate direction and distance
        let dx = toCenter.x - fromCenter.x
        let dy = toCenter.y - fromCenter.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance == 0 {
            return (fromCenter, toCenter, [])
        }
        
        // 改进的边界点计算，考虑节点形状
        let fromEdge = calculateNodeEdgePoint(node: fromNode, direction: CGPoint(x: dx, y: dy), distance: distance)
        let toEdge = calculateNodeEdgePoint(node: toNode, direction: CGPoint(x: -dx, y: -dy), distance: distance)
        
        // 重新计算边缘点之间的距离和方向
        let edgeDx = toEdge.x - fromEdge.x
        let edgeDy = toEdge.y - fromEdge.y
        let edgeDistance = sqrt(edgeDx*edgeDx + edgeDy*edgeDy)
        
        // 改进的连线类型判断
        let isVerticalFlow = abs(dy) > abs(dx) * 1.5  // 主要是垂直流向
        let isHorizontalFlow = abs(dx) > abs(dy) * 1.5  // 主要是水平流向
        
        // 检查是否有其他连线可能重叠
        let hasOverlapRisk = checkForOverlapRisk(from: fromNode, to: toNode)
        
        // 检查是否为特殊情况：Yes/No分支
        let isYesNoBranch = edge.label.lowercased() == "yes" || edge.label.lowercased() == "no"
        
        // 检查是否是菱形节点的分支
        let isDiamondBranch = fromNode.shape == .diamond
        
        // 对于垂直或水平流向，且没有重叠风险，且不是Yes/No分支，使用直线
        if (isVerticalFlow || isHorizontalFlow) && !hasOverlapRisk && !isYesNoBranch && !isDiamondBranch {
            // 使用直线连接
            return (fromEdge, toEdge, [])
        } else {
            // 使用曲线连接，避免重叠
            var curveOffset: CGFloat
            var offsetMultiplier: CGFloat
            
            if isYesNoBranch {
                // 对Yes/No分支使用更大的曲率
                curveOffset = min(100, edgeDistance * 0.6)
                offsetMultiplier = 0.8
                
                // 对Yes和No分支使用不同方向的曲线
                if edge.label.lowercased() == "yes" {
                    // Yes分支向左弯曲
                    if isHorizontalFlow {
                        curveOffset = -abs(curveOffset) * 1.2  // 水平流向时增加曲率
                    } else {
                        curveOffset = -abs(curveOffset)
                    }
                } else {
                    // No分支向右弯曲
                    if isHorizontalFlow {
                        curveOffset = abs(curveOffset) * 1.2  // 水平流向时增加曲率
                    } else {
                        curveOffset = abs(curveOffset)
                    }
                }
            } else if isDiamondBranch {
                // 对菱形节点的分支使用特殊曲率
                curveOffset = min(70, edgeDistance * 0.45)
                offsetMultiplier = 0.65
                
                // 根据节点相对位置调整曲线方向
                if abs(edgeDx) > abs(edgeDy) {
                    // 水平方向占主导，垂直偏移
                    if fromNode.position.y > toNode.position.y {
                        curveOffset = -abs(curveOffset) * 1.1  // 向上偏移，增加曲率
                    } else {
                        curveOffset = abs(curveOffset) * 1.1  // 向下偏移，增加曲率
                    }
                } else {
                    // 垂直方向占主导，水平偏移
                    if fromNode.position.x > toNode.position.x {
                        curveOffset = -abs(curveOffset) * 1.1  // 向左偏移，增加曲率
                    } else {
                        curveOffset = abs(curveOffset) * 1.1  // 向右偏移，增加曲率
                    }
                }
            } else {
                // 普通边的曲率
                curveOffset = hasOverlapRisk ? min(60, edgeDistance * 0.4) : min(40, edgeDistance * 0.25)
                offsetMultiplier = hasOverlapRisk ? 0.6 : 0.4
                
                // 根据节点相对位置调整曲线方向
                if abs(edgeDx) > abs(edgeDy) {
                    // 水平方向占主导，垂直偏移
                    if fromNode.position.y > toNode.position.y {
                        curveOffset = -abs(curveOffset)  // 向上偏移
                    } else {
                        curveOffset = abs(curveOffset)  // 向下偏移
                    }
                } else {
                    // 垂直方向占主导，水平偏移
                    if fromNode.position.x > toNode.position.x {
                        curveOffset = -abs(curveOffset)  // 向左偏移
                    } else {
                        curveOffset = abs(curveOffset)  // 向右偏移
                    }
                }
            }
            
            // 计算垂直于连线方向的偏移向量
            let perpX = -edgeDy / edgeDistance * curveOffset
            let perpY = edgeDx / edgeDistance * curveOffset
            
            // 调整控制点位置，使曲线更平滑
            let controlRatio1 = isYesNoBranch ? 0.35 : 0.3
            let controlRatio2 = isYesNoBranch ? 0.35 : 0.3
            
            let control1 = CGPoint(
                x: fromEdge.x + edgeDx * controlRatio1 + perpX * offsetMultiplier,
                y: fromEdge.y + edgeDy * controlRatio1 + perpY * offsetMultiplier
            )
            
            let control2 = CGPoint(
                x: toEdge.x - edgeDx * controlRatio2 + perpX * offsetMultiplier,
                y: toEdge.y - edgeDy * controlRatio2 + perpY * offsetMultiplier
            )
            
            return (fromEdge, toEdge, [control1, control2])
        }
    }
    
    // 计算节点边界上的精确连接点
    private func calculateNodeEdgePoint(node: Node, direction: CGPoint, distance: CGFloat) -> CGPoint {
        let center = node.position
        let unitX = direction.x / distance
        let unitY = direction.y / distance
        
        // 根据节点形状计算不同的半径
        let radius = getNodeRadius(node)
        
        // 对于矩形节点，计算更精确的边界点
        if node.shape == .rectangle || node.shape == .roundedRectangle {
            // 使用估算的节点大小，根据文本长度动态调整
            let nodeWidth: CGFloat = max(70, CGFloat(node.label.count) * 8 + 20)
            let nodeHeight: CGFloat = 45
            
            // 计算射线与矩形边界的交点
            let absUnitX = abs(unitX)
            let absUnitY = abs(unitY)
            
            if absUnitX * nodeHeight > absUnitY * nodeWidth {
                // 与左右边相交
                let edgeX = center.x + (unitX > 0 ? nodeWidth/2 : -nodeWidth/2)
                let edgeY = center.y + unitY * (nodeWidth/2) / absUnitX
                return CGPoint(x: edgeX, y: edgeY)
            } else {
                // 与上下边相交
                let edgeX = center.x + unitX * (nodeHeight/2) / absUnitY
                let edgeY = center.y + (unitY > 0 ? nodeHeight/2 : -nodeHeight/2)
                return CGPoint(x: edgeX, y: edgeY)
            }
        } else if node.shape == .diamond {
            // 对于菱形，使用与实际渲染一致的尺寸计算
            // 使用与calculateNodeSize相同的逻辑
            let text = node.label
            let estimatedCharWidth: CGFloat = 8
            let estimatedLineHeight: CGFloat = 20
            let lines = max(1, text.components(separatedBy: "\n").count)
            let textWidth = min(200, CGFloat(text.count) * estimatedCharWidth)
            let textHeight = CGFloat(lines) * estimatedLineHeight
            
            let padding: CGFloat = 16
            let minWidth: CGFloat = 100
            let minHeight: CGFloat = 70
            
            let actualWidth = max(minWidth, textWidth + padding)
            let actualHeight = max(minHeight, textHeight + padding)
            
            let halfWidth = actualWidth / 2
            let halfHeight = actualHeight / 2
            
            // 计算射线与菱形边界的交点
            // 菱形的四个顶点：上(0,-1)、右(1,0)、下(0,1)、左(-1,0)
            let vertices = [
                CGPoint(x: center.x, y: center.y - halfHeight),  // 上顶点
                CGPoint(x: center.x + halfWidth, y: center.y),   // 右顶点
                CGPoint(x: center.x, y: center.y + halfHeight),  // 下顶点
                CGPoint(x: center.x - halfWidth, y: center.y)    // 左顶点
            ]
            
            // 找到最接近射线方向的边
            var bestPoint = center
            var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
            
            for i in 0..<4 {
                let p1 = vertices[i]
                let p2 = vertices[(i+1)%4]
                
                // 计算射线与边的交点
                let edgeDx: CGFloat = p2.x - p1.x
                let edgeDy: CGFloat = p2.y - p1.y
                
                // 避免除零错误
                let denominator = edgeDy * unitX - edgeDx * unitY
                if abs(denominator) > 0.001 {
                    let t = ((p1.y - center.y) * unitX - (p1.x - center.x) * unitY) / denominator
                    
                    if t >= 0 && t <= 1 {
                        let intersectionPoint = CGPoint(x: p1.x + t * edgeDx, y: p1.y + t * edgeDy)
                        let distanceToIntersection = sqrt(pow(intersectionPoint.x - center.x, 2) + pow(intersectionPoint.y - center.y, 2))
                        
                        if distanceToIntersection < minDistance {
                            bestPoint = intersectionPoint
                            minDistance = distanceToIntersection
                        }
                    }
                }
            }
            
            return bestPoint
        } else if node.shape == .circle {
            // 对于圆形节点，使用精确的圆形边界计算
            // 根据文本长度动态调整圆的半径
            let circleRadius = max(35, CGFloat(node.label.count) * 3 + 20)
            
            return CGPoint(
                x: center.x + unitX * circleRadius,
                y: center.y + unitY * circleRadius
            )
        } else if node.shape == .hexagon {
            // 对于六边形，使用特殊的计算方法
            let hexRadius = max(45, CGFloat(node.label.count) * 3.5 + 25)
            
            // 六边形的六个顶点，以中心为原点
            let angleStep = CGFloat.pi / 3  // 60度
            var vertices: [CGPoint] = []
            
            for i in 0..<6 {
                let angle = CGFloat(i) * angleStep
                let x = center.x + hexRadius * cos(angle)
                let y = center.y + hexRadius * sin(angle)
                vertices.append(CGPoint(x: x, y: y))
            }
            
            // 找到最接近射线方向的边
            var bestPoint = center
            var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
            
            for i in 0..<6 {
                let p1 = vertices[i]
                let p2 = vertices[(i+1)%6]
                
                // 计算射线与边的交点
                let edgeDx: CGFloat = p2.x - p1.x
                let edgeDy: CGFloat = p2.y - p1.y
                
                // 避免除零错误
                let denominator = edgeDy * unitX - edgeDx * unitY
                if abs(denominator) > 0.001 {
                    let t = ((p1.y - center.y) * unitX - (p1.x - center.x) * unitY) / denominator
                    
                    if t >= 0 && t <= 1 {
                        let intersectionPoint = CGPoint(x: p1.x + t * edgeDx, y: p1.y + t * edgeDy)
                        let distanceToIntersection = sqrt(pow(intersectionPoint.x - center.x, 2) + pow(intersectionPoint.y - center.y, 2))
                        
                        if distanceToIntersection < minDistance {
                            bestPoint = intersectionPoint
                            minDistance = distanceToIntersection
                        }
                    }
                }
            }
            
            return bestPoint
        } else {
            // 对于其他形状，使用圆形近似
            return CGPoint(
                x: center.x + unitX * radius,
                y: center.y + unitY * radius
            )
        }
    }
    
    // 检查是否有重叠风险
    private func checkForOverlapRisk(from fromNode: Node, to toNode: Node) -> Bool {
        // 检查是否有其他边与当前边可能重叠
        for edgeItem in edges {
            if edgeItem.from == fromNode.id && edgeItem.to == toNode.id {
                continue // 跳过当前边
            }
            
            // 检查是否有相同起点或终点的边
            if edgeItem.from == fromNode.id || edgeItem.to == toNode.id {
                return true
            }
        }
        
        return false
    }
    
    private func calculateArrowAngle(controlPoints: [CGPoint], endPoint: CGPoint) -> Double {
        if controlPoints.count >= 2 {
            // 对于曲线，使用最后一个控制点到终点的角度
            let lastControl = controlPoints[1]
            let dx = endPoint.x - lastControl.x
            let dy = endPoint.y - lastControl.y
            return atan2(dy, dx)
        } else if controlPoints.count == 1 {
            // 对于只有一个控制点的情况
            let dx = endPoint.x - controlPoints[0].x
            let dy = endPoint.y - controlPoints[0].y
            return atan2(dy, dx)
        } else {
            // 对于直线，我们需要从起点计算角度
            // 由于我们没有起点信息，这里使用一个近似值
            // 实际上，这种情况下我们应该在调用前就知道起点和终点
            return 0 // 这个值会在实际使用时被覆盖
        }
    }
    
    private func calculateMidPoint(start: CGPoint, end: CGPoint, controlPoints: [CGPoint]) -> CGPoint {
        if controlPoints.count >= 2 {
            // 对于曲线，使用贝塞尔曲线上的点
            let t: CGFloat = 0.5 // 参数t在[0, 1]范围内
            let p0 = start
            let p1 = controlPoints[0]
            let p2 = controlPoints[1]
            let p3 = end
            
            // 三次贝塞尔曲线公式
            let x = pow(1-t, 3) * p0.x + 3 * pow(1-t, 2) * t * p1.x + 3 * (1-t) * pow(t, 2) * p2.x + pow(t, 3) * p3.x
            let y = pow(1-t, 3) * p0.y + 3 * pow(1-t, 2) * t * p1.y + 3 * (1-t) * pow(t, 2) * p2.y + pow(t, 3) * p3.y
            
            return CGPoint(x: x, y: y)
        } else {
            // 对于直线，使用中点
            return CGPoint(
                x: (start.x + end.x) / 2,
                y: (start.y + end.y) / 2
            )
        }
    }
    
    private func getNodeRadius(_ node: Node) -> CGFloat {
        switch node.shape {
        case .circle:
            return 35  // 减少圆形节点半径
        case .diamond:
            return 50  // 减少菱形节点半径
        case .hexagon:
            return 45  // 减少六边形节点半径
        default:
            return 40  // 减少默认节点半径
        }
    }
}

/// Legacy EdgeView for compatibility
public struct EdgeView: View {
    private let edge: Edge
    private let nodes: [Node]
    
    public init(edge: Edge, nodes: [Node]) {
        self.edge = edge
        self.nodes = nodes
    }
    
    public var body: some View {
        CurvedEdgeView(edge: edge, nodes: nodes)
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

/// A curved arrow shape
public struct CurvedArrowShape: Shape {
    private let endPoint: CGPoint
    private let angle: Double
    private let arrowSize: CGFloat = 15  // 增加箭头大小
    
    public init(endPoint: CGPoint, angle: Double) {
        self.endPoint = endPoint
        self.angle = angle
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let arrowAngle = CGFloat(angle)
        
        // 计算箭头的三个顶点
        let arrowTip = endPoint
        
        // 箭头的两个底边点，使用更大的角度使箭头更明显
        let arrowPoint1 = CGPoint(
            x: arrowTip.x - arrowSize * cos(arrowAngle - .pi/3),
            y: arrowTip.y - arrowSize * sin(arrowAngle - .pi/3)
        )
        
        let arrowPoint2 = CGPoint(
            x: arrowTip.x - arrowSize * cos(arrowAngle + .pi/3),
            y: arrowTip.y - arrowSize * sin(arrowAngle + .pi/3)
        )
        
        // 创建一个闭合的三角形箭头
        path.move(to: arrowTip)
        path.addLine(to: arrowPoint1)
        path.addLine(to: arrowPoint2)
        path.closeSubpath()
        
        return path
    }
}

/// Legacy arrow shape for compatibility
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
