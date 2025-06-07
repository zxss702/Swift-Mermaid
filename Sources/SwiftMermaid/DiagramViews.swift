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
        GeometryReader { geometry in
            ZStack {
                // Draw relationships first (so they appear behind classes)
                ForEach(relationships.indices, id: \.self) { index in
                    ClassRelationshipView(
                        relationship: relationships[index],
                        classes: classes
                    )
                }
                
                // Draw classes
                ForEach(classes, id: \.name) { classEntity in
                    ClassEntityView(classEntity: classEntity)
                        .position(classEntity.position)
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }
    
    private var classes: [ClassEntity] {
        return (diagram.parsedData["classes"] as? [ClassEntity]) ?? []
    }
    
    private var relationships: [ClassRelationship] {
        return (diagram.parsedData["relationships"] as? [ClassRelationship]) ?? []
    }
}

/// A view that renders a single class entity
public struct ClassEntityView: View {
    private let classEntity: ClassEntity
    private let padding: CGFloat = 8
    private let headerHeight: CGFloat = 30
    private let memberHeight: CGFloat = 20
    
    public init(classEntity: ClassEntity) {
        self.classEntity = classEntity
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Class name header
            Text(classEntity.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: headerHeight)
                .background(Color.blue.opacity(0.1))
            
            // Separator line
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
            
            // Attributes section
            if !classEntity.attributes.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(classEntity.attributes.indices, id: \.self) { index in
                        ClassAttributeView(attribute: classEntity.attributes[index])
                    }
                }
                .padding(.horizontal, padding)
                .padding(.vertical, 4)
                
                // Separator line
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 1)
            }
            
            // Methods section
            if !classEntity.methods.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(classEntity.methods.indices, id: \.self) { index in
                        ClassMethodView(method: classEntity.methods[index])
                    }
                }
                .padding(.horizontal, padding)
                .padding(.vertical, 4)
            }
        }
        .background(Color.white)
        .overlay(
            Rectangle()
                .stroke(Color.black, lineWidth: 1)
        )
        .frame(width: calculateWidth(), height: calculateHeight())
    }
    
    private func calculateWidth() -> CGFloat {
        let minWidth: CGFloat = 120
        let nameWidth = CGFloat(classEntity.name.count * 8) + padding * 2
        
        let attributeWidths = classEntity.attributes.map { attribute in
            CGFloat("\(attribute.visibility.symbol)\(attribute.type) \(attribute.name)".count * 7)
        }
        
        let methodWidths = classEntity.methods.map { method in
            CGFloat("\(method.visibility.symbol)\(method.name)()".count * 7)
        }
        
        let maxContentWidth = ([nameWidth] + attributeWidths + methodWidths).max() ?? minWidth
        return max(minWidth, maxContentWidth + padding * 2)
    }
    
    private func calculateHeight() -> CGFloat {
        let headerHeight = self.headerHeight
        let attributesHeight = classEntity.attributes.isEmpty ? 0 : CGFloat(classEntity.attributes.count) * memberHeight + 8
        let methodsHeight = classEntity.methods.isEmpty ? 0 : CGFloat(classEntity.methods.count) * memberHeight + 8
        let separatorHeight: CGFloat = (classEntity.attributes.isEmpty ? 0 : 1) + (classEntity.methods.isEmpty ? 0 : 1)
        
        return headerHeight + attributesHeight + methodsHeight + separatorHeight
    }
}

/// A view that renders a class attribute
public struct ClassAttributeView: View {
    private let attribute: ClassAttribute
    
    public init(attribute: ClassAttribute) {
        self.attribute = attribute
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Text(attribute.visibility.symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(visibilityColor)
            
            Text("\(attribute.type) \(attribute.name)")
                .font(.system(size: 12))
                .foregroundColor(.black)
            
            Spacer()
        }
        .frame(height: 16)
    }
    
    private var visibilityColor: Color {
        switch attribute.visibility {
        case .public_: return .green
        case .private_: return .red
        case .protected: return .orange
        case .package: return .blue
        }
    }
}

/// A view that renders a class method
public struct ClassMethodView: View {
    private let method: ClassMethod
    
    public init(method: ClassMethod) {
        self.method = method
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Text(method.visibility.symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(visibilityColor)
            
            Text("\(method.name)()")
                .font(.system(size: 12))
                .foregroundColor(.black)
            
            Spacer()
        }
        .frame(height: 16)
    }
    
    private var visibilityColor: Color {
        switch method.visibility {
        case .public_: return .green
        case .private_: return .red
        case .protected: return .orange
        case .package: return .blue
        }
    }
}

/// A view that renders a relationship between classes
public struct ClassRelationshipView: View {
    private let relationship: ClassRelationship
    private let classes: [ClassEntity]
    
    public init(relationship: ClassRelationship, classes: [ClassEntity]) {
        self.relationship = relationship
        self.classes = classes
    }
    
    public var body: some View {
        if let fromClass = classes.first(where: { $0.name == relationship.from }),
           let toClass = classes.first(where: { $0.name == relationship.to }) {
            
            Path { path in
                path.move(to: fromClass.position)
                path.addLine(to: toClass.position)
            }
            .stroke(relationshipColor, lineWidth: relationshipLineWidth)
            .overlay(
                relationshipArrow(from: fromClass.position, to: toClass.position)
            )
        }
    }
    
    private var relationshipColor: Color {
        switch relationship.type {
        case .inheritance: return .blue
        case .composition: return .red
        case .aggregation: return .orange
        case .association: return .black
        case .dependency: return .gray
        case .realization: return .purple
        }
    }
    
    private var relationshipLineWidth: CGFloat {
        switch relationship.type {
        case .dependency: return 1
        default: return 2
        }
    }
    
    private func relationshipArrow(from: CGPoint, to: CGPoint) -> some View {
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 10
        let arrowAngle: CGFloat = .pi / 6
        
        return Path { path in
            // Arrow head
            let arrowPoint1 = CGPoint(
                x: to.x - arrowLength * cos(angle - arrowAngle),
                y: to.y - arrowLength * sin(angle - arrowAngle)
            )
            let arrowPoint2 = CGPoint(
                x: to.x - arrowLength * cos(angle + arrowAngle),
                y: to.y - arrowLength * sin(angle + arrowAngle)
            )
            
            switch relationship.type {
            case .inheritance:
                // Triangle arrow for inheritance
                path.move(to: to)
                path.addLine(to: arrowPoint1)
                path.addLine(to: arrowPoint2)
                path.closeSubpath()
            default:
                // Simple arrow
                path.move(to: to)
                path.addLine(to: arrowPoint1)
                path.move(to: to)
                path.addLine(to: arrowPoint2)
            }
        }
        .stroke(relationshipColor, lineWidth: relationshipLineWidth)
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
        if let stateDiagramData = diagram.parsedData["stateDiagram"] as? StateDiagram {
            Canvas { context, canvasSize in
                drawStateDiagram(context: context, stateDiagram: stateDiagramData, canvasSize: canvasSize)
            }
            .frame(width: size.width, height: size.height)
        } else {
            VStack {
                Text("State Diagram")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Failed to parse diagram")
                    .font(.caption)
                    .foregroundColor(.red)
                
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
    
    private func drawStateDiagram(context: GraphicsContext, stateDiagram: StateDiagram, canvasSize: CGSize) {
        // Draw transitions first (so they appear behind states)
        for transition in stateDiagram.transitions {
            drawTransition(context: context, transition: transition, states: stateDiagram.states)
        }
        
        // Draw states
        for state in stateDiagram.states {
            drawState(context: context, state: state)
        }
    }
    
    private func drawState(context: GraphicsContext, state: StateEntity) {
        let stateSize = CGSize(width: 120, height: 60)
        let rect = CGRect(
            x: state.position.x - stateSize.width / 2,
            y: state.position.y - stateSize.height / 2,
            width: stateSize.width,
            height: stateSize.height
        )
        
        // Determine state color and shape based on type
        if state.id == "[*]" {
            // Draw start/end state as a filled circle
            let circleRect = CGRect(
                x: state.position.x - 10,
                y: state.position.y - 10,
                width: 20,
                height: 20
            )
            context.fill(Path(ellipseIn: circleRect), with: .color(.black))
        } else {
            // Draw regular state as rounded rectangle
            let path = Path(roundedRect: rect, cornerRadius: 8)
            
            // Fill background
            context.fill(path, with: .color(.blue.opacity(0.1)))
            
            // Draw border
            context.stroke(path, with: .color(.blue), lineWidth: 2)
            
            // Draw state text
            let displayText = state.description ?? state.id
            let textRect = CGRect(
                x: rect.minX + 4,
                y: rect.minY + 4,
                width: rect.width - 8,
                height: rect.height - 8
            )
            
            context.draw(
                Text(displayText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary),
                in: textRect
            )
        }
    }
    
    private func drawTransition(context: GraphicsContext, transition: StateTransition, states: [StateEntity]) {
        guard let fromState = states.first(where: { $0.id == transition.from }),
              let toState = states.first(where: { $0.id == transition.to }) else {
            return
        }
        
        let startPoint = fromState.position
        let endPoint = toState.position
        
        // Calculate arrow path
        let path = createArrowPath(from: startPoint, to: endPoint)
        
        // Draw arrow
        context.stroke(path, with: .color(.gray), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        
        // Draw transition label if present
        if let label = transition.label, !label.isEmpty {
            let midPoint = CGPoint(
                x: (startPoint.x + endPoint.x) / 2,
                y: (startPoint.y + endPoint.y) / 2 - 10
            )
            
            context.draw(
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary),
                at: midPoint
            )
        }
    }
    
    private func createArrowPath(from startPoint: CGPoint, to endPoint: CGPoint) -> Path {
        var path = Path()
        
        // Calculate direction vector
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let length = sqrt(dx * dx + dy * dy)
        
        if length == 0 { return path }
        
        // Normalize direction
        let unitX = dx / length
        let unitY = dy / length
        
        // Adjust start and end points to account for state boundaries
        let stateRadius: CGFloat = 40
        let adjustedStart = CGPoint(
            x: startPoint.x + unitX * stateRadius,
            y: startPoint.y + unitY * stateRadius
        )
        let adjustedEnd = CGPoint(
            x: endPoint.x - unitX * stateRadius,
            y: endPoint.y - unitY * stateRadius
        )
        
        // Draw main line
        path.move(to: adjustedStart)
        path.addLine(to: adjustedEnd)
        
        // Draw arrowhead
        let arrowLength: CGFloat = 10
        let arrowAngle: CGFloat = .pi / 6
        
        let arrowPoint1 = CGPoint(
            x: adjustedEnd.x - arrowLength * cos(atan2(dy, dx) - arrowAngle),
            y: adjustedEnd.y - arrowLength * sin(atan2(dy, dx) - arrowAngle)
        )
        
        let arrowPoint2 = CGPoint(
            x: adjustedEnd.x - arrowLength * cos(atan2(dy, dx) + arrowAngle),
            y: adjustedEnd.y - arrowLength * sin(atan2(dy, dx) + arrowAngle)
        )
        
        path.move(to: adjustedEnd)
        path.addLine(to: arrowPoint1)
        path.move(to: adjustedEnd)
        path.addLine(to: arrowPoint2)
        
        return path
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
        let title = extractTitle()
        
        VStack(spacing: 20) {
            // Title
            if !title.isEmpty {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            
            if !pieData.isEmpty {
                let layout = calculateOptimalLayout(pieData: pieData)
                
                HStack(spacing: layout.spacing) {
                    // Pie Chart
                    ZStack {
                        ForEach(0..<pieData.count, id: \.self) { index in
                            PieSlice(
                                startAngle: calculateStartAngle(index: index, data: pieData),
                                endAngle: calculateEndAngle(index: index, data: pieData)
                            )
                            .fill(chineseTraditionalColors[index % chineseTraditionalColors.count])
                            .overlay(
                                // Add percentage labels on slices with complementary colors
                                Text("\(calculatePercentage(index: index, data: pieData), specifier: "%.1f")%")
                                    .font(.system(size: layout.labelFontSize))
                                    .fontWeight(.semibold)
                                    .foregroundColor(complementaryTextColors[index % complementaryTextColors.count])
                                    .shadow(color: .white.opacity(0.8), radius: 1, x: 0, y: 0)
                                    .position(calculateLabelPosition(index: index, data: pieData, in: CGRect(x: 0, y: 0, width: layout.pieSize, height: layout.pieSize)))
                            )
                        }
                    }
                    .frame(width: layout.pieSize, height: layout.pieSize)
                    
                    // Legend
                    VStack(alignment: .leading, spacing: layout.legendSpacing) {
                        ForEach(0..<pieData.count, id: \.self) { index in
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(chineseTraditionalColors[index % chineseTraditionalColors.count])
                                    .frame(width: layout.legendIconSize, height: layout.legendIconSize)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pieData[index].label)
                                        .font(.system(size: layout.legendFontSize))
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("\(pieData[index].value, specifier: "%.0f") (\(calculatePercentage(index: index, data: pieData), specifier: "%.1f")%)")
                                        .font(.system(size: layout.legendFontSize - 2))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: layout.legendMaxWidth)
                }
            } else {
                VStack {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No data to display")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .padding()
    }
    
    // 中式传统浅色配色方案（高亮度低饱和度）
    private let chineseTraditionalColors: [Color] = [
        Color(red: 0.95, green: 0.85, blue: 0.83), // 浅朱红
        Color(red: 0.83, green: 0.88, blue: 0.95), // 浅靛青
        Color(red: 0.85, green: 0.93, blue: 0.85), // 浅竹绿
        Color(red: 0.98, green: 0.93, blue: 0.83), // 浅杏黄
        Color(red: 0.93, green: 0.88, blue: 0.95), // 浅紫檀
        Color(red: 0.96, green: 0.88, blue: 0.91), // 浅胭脂
        Color(red: 0.88, green: 0.95, blue: 0.93), // 浅青瓷
        Color(red: 0.96, green: 0.95, blue: 0.83), // 浅明黄
        Color(red: 0.93, green: 0.88, blue: 0.83), // 浅赭石
        Color(red: 0.85, green: 0.88, blue: 0.93), // 浅藏青
        Color(red: 0.95, green: 0.88, blue: 0.88), // 浅枣红
        Color(red: 0.90, green: 0.93, blue: 0.95)  // 浅青灰
    ]
    
    // 对应的互补色（用于文字显示）
    private let complementaryTextColors: [Color] = [
        Color(red: 0.45, green: 0.20, blue: 0.18), // 深朱红（对应浅朱红）
        Color(red: 0.15, green: 0.25, blue: 0.45), // 深靛青（对应浅靛青）
        Color(red: 0.18, green: 0.35, blue: 0.18), // 深竹绿（对应浅竹绿）
        Color(red: 0.55, green: 0.40, blue: 0.25), // 深杏黄（对应浅杏黄）
        Color(red: 0.35, green: 0.25, blue: 0.45), // 深紫檀（对应浅紫檀）
        Color(red: 0.50, green: 0.25, blue: 0.35), // 深胭脂（对应浅胭脂）
        Color(red: 0.25, green: 0.45, blue: 0.40), // 深青瓷（对应浅青瓷）
        Color(red: 0.50, green: 0.45, blue: 0.20), // 深明黄（对应浅明黄）
        Color(red: 0.40, green: 0.25, blue: 0.15), // 深赭石（对应浅赭石）
        Color(red: 0.20, green: 0.25, blue: 0.35), // 深藏青（对应浅藏青）
        Color(red: 0.45, green: 0.25, blue: 0.25), // 深枣红（对应浅枣红）
        Color(red: 0.30, green: 0.35, blue: 0.40)  // 深青灰（对应浅青灰）
    ]
    
    // 布局配置结构
    private struct PieLayoutConfig {
        let pieSize: CGFloat
        let spacing: CGFloat
        let legendSpacing: CGFloat
        let legendIconSize: CGFloat
        let legendFontSize: CGFloat
        let labelFontSize: CGFloat
        let legendMaxWidth: CGFloat
    }
    
    private struct PieData {
        let label: String
        let value: Double
    }
    
    private func extractTitle() -> String {
        if let title = diagram.parsedData["title"] as? String {
            return title
        }
        return ""
    }
    
    private func extractPieData() -> [PieData] {
        // Try to get data from parsed data first
        if let dataDict = diagram.parsedData["data"] as? [String: Double] {
            return dataDict.map { PieData(label: $0.key, value: $0.value) }
                          .sorted { $0.value > $1.value } // Sort by value descending
        }
        
        // Fallback to parsing raw text
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
        
        return data.sorted { $0.value > $1.value }
    }
    
    private func calculatePercentage(index: Int, data: [PieData]) -> Double {
        let total = data.reduce(0) { $0 + $1.value }
        return total > 0 ? (data[index].value / total * 100) : 0
    }
    
    // 计算最优布局配置
    private func calculateOptimalLayout(pieData: [PieData]) -> PieLayoutConfig {
        let dataCount = pieData.count
        let availableWidth = size.width - 40 // 减去padding
        let availableHeight = size.height - 80 // 减去padding和标题空间
        
        // 计算饼图大小，给图例留出更多空间
        let minPieSize: CGFloat = 200
        let maxPieSize = min(availableHeight * 0.85, availableWidth * 0.45) // 减少饼图占比，给图例更多空间
        let pieSize = min(max(minPieSize, 200), maxPieSize)
        
        // 大幅增加图例区域宽度，确保标签能在一行显示
        let legendMaxWidth = max(availableWidth - pieSize - 30, 200) // 增加最小宽度到200
        
        return PieLayoutConfig(
            pieSize: pieSize,
            spacing: 20, // 减少间距
            legendSpacing: dataCount <= 4 ? 12 : (dataCount <= 8 ? 10 : 8),
            legendIconSize: dataCount <= 4 ? 18 : (dataCount <= 8 ? 16 : 14),
            legendFontSize: dataCount <= 4 ? 14 : (dataCount <= 8 ? 13 : 12),
            labelFontSize: pieSize > 300 ? 14 : (pieSize > 250 ? 12 : 11), // 调整标签字体
            legendMaxWidth: legendMaxWidth
        )
    }
    
    private func calculateLabelPosition(index: Int, data: [PieData], in rect: CGRect) -> CGPoint {
        let total = data.reduce(0) { $0 + $1.value }
        let startAngle = data.prefix(index).reduce(0) { $0 + $1.value } / total * 360 - 90
        let endAngle = data.prefix(index + 1).reduce(0) { $0 + $1.value } / total * 360 - 90
        let midAngle = (startAngle + endAngle) / 2
        
        // 根据扇形大小调整标签位置
        let percentage = calculatePercentage(index: index, data: data)
        let radiusRatio = percentage > 10 ? 0.7 : 0.8 // 小扇形的标签放得更靠外
        let radius = min(rect.width, rect.height) / 2 * radiusRatio
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        let x = center.x + radius * cos(midAngle * .pi / 180)
        let y = center.y + radius * sin(midAngle * .pi / 180)
        
        return CGPoint(x: x, y: y)
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

// MARK: - Timeline View

/// A view that renders a timeline diagram
public struct TimelineView: View {
    private let diagram: MermaidDiagram
    
    public init(diagram: MermaidDiagram) {
        self.diagram = diagram
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            if !title.isEmpty {
                Text(title)
                    .font(.custom(size: .title2))
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
            }
                
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 2)
            
            // Timeline
            HStack(alignment: .top, spacing: 0) {
                ForEach(groupedEvents.indices, id: \.self) { index in
                    TimelinePeriodView(
                        period: groupedEvents[index].period,
                        events: groupedEvents[index].events,
                        isLast: index == groupedEvents.count - 1
                    )
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 16)
    }
    
    private var title: String {
        return (diagram.parsedData["title"] as? String) ?? ""
    }
    
    private var events: [TimelineEvent] {
        return (diagram.parsedData["events"] as? [TimelineEvent]) ?? []
    }
    
    private var groupedEvents: [(period: String, events: [String])] {
        var grouped: [String: [String]] = [:]
        var order: [String] = []
        
        for event in events {
            if grouped[event.period] == nil {
                grouped[event.period] = []
                order.append(event.period)
            }
            grouped[event.period]?.append(event.event)
        }
        
        return order.map { period in
            (period: period, events: grouped[period] ?? [])
        }
    }
}

/// A view that renders a single period in the timeline
public struct TimelinePeriodView: View {
    let period: String
    let events: [String]
    let isLast: Bool
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Period header
            Text(period)
                .font(.custom(size: .headline))
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .padding(.leading, 4)
            // Events
            VStack(alignment: .leading, spacing: 8) {
                ForEach(events.indices, id: \.self) { index in
                    HStack(alignment: .top, spacing: 8) {
                        // Event bullet
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                        
                        // Event text
                        Text(events[index])
                            .font(.custom(size: .body))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 8 + 2)
           
        }
        .padding(.top, 2)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 2)
                .padding(.bottom, 4)
        }
        .padding(.trailing, 16)
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
