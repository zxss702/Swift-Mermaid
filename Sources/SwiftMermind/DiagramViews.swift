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
                                // Add percentage labels on slices
                                Text("\(calculatePercentage(index: index, data: pieData), specifier: "%.1f")%")
                                    .font(.system(size: layout.labelFontSize))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 0)
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
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Text("\(pieData[index].value, specifier: "%.0f") (\(calculatePercentage(index: index, data: pieData), specifier: "%.1f")%)")
                                        .font(.system(size: layout.legendFontSize - 2))
                                        .foregroundColor(.secondary)
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
    
    // 中式传统深色配色方案（半透明低饱和度）
    private let chineseTraditionalColors: [Color] = [
        Color(red: 0.45, green: 0.20, blue: 0.18).opacity(0.85), // 深朱红
        Color(red: 0.15, green: 0.25, blue: 0.45).opacity(0.85), // 深靛青
        Color(red: 0.18, green: 0.35, blue: 0.18).opacity(0.85), // 深竹绿
        Color(red: 0.55, green: 0.40, blue: 0.25).opacity(0.85), // 深杏黄
        Color(red: 0.35, green: 0.25, blue: 0.45).opacity(0.85), // 深紫檀
        Color(red: 0.50, green: 0.25, blue: 0.35).opacity(0.85), // 深胭脂
        Color(red: 0.25, green: 0.45, blue: 0.40).opacity(0.85), // 深青瓷
        Color(red: 0.50, green: 0.45, blue: 0.20).opacity(0.85), // 深明黄
        Color(red: 0.40, green: 0.25, blue: 0.15).opacity(0.85), // 深赭石
        Color(red: 0.20, green: 0.25, blue: 0.35).opacity(0.85), // 深藏青
        Color(red: 0.45, green: 0.25, blue: 0.25).opacity(0.85), // 深枣红
        Color(red: 0.30, green: 0.35, blue: 0.40).opacity(0.85)  // 深青灰
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
        
        // 根据数据项数量调整布局
        let legendItemHeight: CGFloat = dataCount <= 4 ? 40 : (dataCount <= 8 ? 35 : 30)
        let totalLegendHeight = CGFloat(dataCount) * legendItemHeight
        
        // 确保饼图直径明显大于图例高度，增加倍数到1.5
        let minPieSize = max(totalLegendHeight * 1.5, 250)
        let maxPieSize = min(availableHeight * 0.85, availableWidth * 0.6) // 增加饼图占比
        let pieSize = min(max(minPieSize, 250), maxPieSize)
        
        // 计算图例区域宽度，给饼图更多空间
        let legendMaxWidth = max(availableWidth - pieSize - 50, 120)
        
        return PieLayoutConfig(
            pieSize: pieSize,
            spacing: 25, // 减少间距给饼图更多空间
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