import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A SwiftUI view that renders Mermaid diagrams with zoom and scroll capabilities
public struct mermaidView: View {
    private let scrollable: Bool
    private let text: String
    private let parser: MermaidParser
    
    private let topIns: CGFloat
    private let bottomIns: CGFloat
    private let leftIns: CGFloat
    private let rightIns: CGFloat
    
    
    public init(scrollable: Bool = false, text: String, topIns: CGFloat = 0, bottomIns: CGFloat = 0, leftIns: CGFloat = 0, rightIns: CGFloat = 0) {
        self.scrollable = scrollable
        self.text = text
        self.topIns = topIns
        self.bottomIns = bottomIns
        self.leftIns = leftIns
        self.rightIns = rightIns
        self.parser = MermaidParser()
    }
    
    public var body: some View {
        if scrollable {
            #if canImport(UIKit)
            ZoomableScrollView(text: text, parser: parser)
            #else
            // Fallback for macOS without UIKit
            createDiagramView()
            #endif
        } else {
            createDiagramView()
        }
    }
    
    private func createDiagramView() -> some View {
        GeometryReader { geometry in
            let diagram = parser.parse(text)
            
            switch diagram.type {
            case .flowchart:
                FlowchartView(diagram: diagram)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .sequenceDiagram:
                SequenceDiagramView(diagram: diagram, size: geometry.size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .classDiagram:
                ClassDiagramView(diagram: diagram, size: geometry.size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .stateDiagram:
                StateDiagramView(diagram: diagram, size: geometry.size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .gantt:
                GanttChartView(diagram: diagram, size: geometry.size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .timeline:
                TimelineView(diagram: diagram)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .pie:
                PieChartView(diagram: diagram, size: geometry.size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .gitGraph:
                GitGraphView(diagram: diagram, size: geometry.size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .erDiagram:
                ERDiagramView(diagram: diagram, size: geometry.size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .userJourney:
                UserJourneyView(diagram: diagram, size: geometry.size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .unknown:
                Text("Unsupported diagram type")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.clear)
    }
}

#if canImport(UIKit)
/// A zoomable and scrollable container for Mermaid diagrams using UIScrollView
struct ZoomableScrollView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ZoomableScrollViewController
    
    let text: String
    let parser: MermaidParser
    let maxScaler: CGFloat = 3.0
    let minScaler: CGFloat = 0
    
    var topIns: CGFloat = 0
    var bottomIns: CGFloat = 0
    var leftIns: CGFloat = 0
    var rightIns: CGFloat = 0
    
    var scrollToCenter: Bool = true
    
    func makeUIViewController(context: Context) -> ZoomableScrollViewController {
        ZoomableScrollViewController(rootView: self)
    }
    
    func updateUIViewController(_ uiViewController: ZoomableScrollViewController, context: Context) {
        uiViewController.contentSize =  uiViewController.calculateOptimalSize(for: text, parser: parser)
        uiViewController.hostingView.rootView = AnyView(createDiagramViewWithSize(uiViewController.contentSize))
        uiViewController.scrollView.contentSize = uiViewController.contentSize
        
        DispatchQueue.main.async {
            uiViewController.viewWillLayoutSubviews()
        }
    }
    
    func createDiagramViewWithSize(_ size: CGSize) -> some View {
        let diagram = parser.parse(text)
        
        return Group {
            switch diagram.type {
            case .flowchart:
                FlowchartView(diagram: diagram)
                    .frame(width: size.width, height: size.height)
            case .sequenceDiagram:
                SequenceDiagramView(diagram: diagram, size: size)
                    .frame(width: size.width, height: size.height)
            case .classDiagram:
                ClassDiagramView(diagram: diagram, size: size)
                    .frame(width: size.width, height: size.height)
            case .stateDiagram:
                StateDiagramView(diagram: diagram, size: size)
                    .frame(width: size.width, height: size.height)
            case .gantt:
                GanttChartView(diagram: diagram, size: size)
                    .frame(width: size.width, height: size.height)
            case .timeline:
                TimelineView(diagram: diagram)
                    .frame(width: size.width, height: size.height)
            case .pie:
                PieChartView(diagram: diagram, size: size)
                    .frame(width: size.width, height: size.height)
            case .gitGraph:
                GitGraphView(diagram: diagram, size: size)
                    .frame(width: size.width, height: size.height)
            case .erDiagram:
                ERDiagramView(diagram: diagram, size: size)
                    .frame(width: size.width, height: size.height)
            case .userJourney:
                UserJourneyView(diagram: diagram, size: size)
                    .frame(width: size.width, height: size.height)
            case .unknown:
                Text("Unsupported diagram type")
                    .foregroundColor(.red)
                    .frame(width: size.width, height: size.height)
            }
        }
    }
}

class ZoomableScrollViewController: UIViewController, UIScrollViewDelegate {
    let rootView: ZoomableScrollView
    var hostingView: UIHostingController<AnyView>
    var scrollView: UIScrollView = UIScrollView()
    var contentSize: CGSize = CGSize(width: 400, height: 300)
    
    init(rootView: ZoomableScrollView) {
        self.rootView = rootView
        self.hostingView = UIHostingController(rootView: AnyView(rootView.createDiagramViewWithSize(self.contentSize)))
        super.init(nibName: nil, bundle: nil)
        // 计算内容的最佳尺寸
        self.contentSize = self.calculateOptimalSize(for: rootView.text, parser: rootView.parser)
        hostingView.view.isUserInteractionEnabled = true
       
    }
    
    func calculateOptimalSize(for text: String, parser: MermaidParser) -> CGSize {
        let diagram = parser.parse(text)
        
        switch diagram.type {
        case .flowchart:
            return calculateFlowchartSize(diagram: diagram)
            
        case .sequenceDiagram:
            return calculateSequenceDiagramSize(diagram: diagram)
            
        case .classDiagram:
            return calculateClassDiagramSize(diagram: diagram)
            
        case .gitGraph:
            return calculateGitGraphSize(diagram: diagram)
            
        case .pie:
            // 饼图通常是正方形
            return CGSize(width: 400, height: 400)
            
        case .gantt:
            return calculateGanttSize(diagram: diagram)
            
        case .timeline:
            return calculateTimelineSize(diagram: diagram)
            
        case .stateDiagram:
            return calculateStateDiagramSize(diagram: diagram)
            
        default:
            // 默认尺寸
            return CGSize(width: 800, height: 600)
        }
    }
    
    private func calculateFlowchartSize(diagram: MermaidDiagram) -> CGSize {
        let nodeSpacing: CGFloat = 20  // 与FlowchartView中的minNodeSpacing保持一致
        let levelSpacing: CGFloat = 50  // 与FlowchartView中的minLevelSpacing保持一致
        let padding: CGFloat = 60  // 增加padding以确保内容完全显示
        
        // 计算层级结构
        var levels: [Int: [Node]] = [:]
        for node in diagram.nodes {
            let level = calculateNodeLevel(node, diagram: diagram)
            if levels[level] == nil {
                levels[level] = []
            }
            levels[level]?.append(node)
        }
        
        // 计算所需宽度（基于最宽的层级，考虑节点实际大小）
        let maxNodesInLevel = levels.values.map { $0.count }.max() ?? 1
        let estimatedNodeWidth: CGFloat = 140  // 增加估算的节点宽度
        let requiredWidth = CGFloat(maxNodesInLevel) * estimatedNodeWidth + CGFloat(maxNodesInLevel - 1) * nodeSpacing + padding * 2
        
        // 计算所需高度（基于层级数量，考虑节点实际高度）
        let levelCount = levels.keys.count
        let estimatedNodeHeight: CGFloat = 70  // 增加估算的节点高度
        let requiredHeight = CGFloat(levelCount) * estimatedNodeHeight + CGFloat(levelCount - 1) * levelSpacing + padding * 2
        
        return CGSize(
            width: requiredWidth,
            height: requiredHeight
        )
    }
    
    private func calculateSequenceDiagramSize(diagram: MermaidDiagram) -> CGSize {
        let participantSpacing: CGFloat = 150
        let messageSpacing: CGFloat = 50
        let baseHeight: CGFloat = 200
        let padding: CGFloat = 100
        
        // 获取参与者数量
        let participants = diagram.parsedData["participants"] as? [String] ?? []
        let participantCount = max(2, participants.count)
        
        // 获取消息数量
        let messages = diagram.parsedData["messages"] as? [Any] ?? []
        let messageCount = messages.count
        
        // 获取注释数量
        let notes = diagram.parsedData["notes"] as? [Any] ?? []
        let noteCount = notes.count
        
        // 计算宽度
        let requiredWidth = CGFloat(participantCount - 1) * participantSpacing + padding * 2
        
        // 计算高度
        let messageHeight = CGFloat(messageCount) * messageSpacing
        let noteHeight = CGFloat(noteCount) * 30
        let requiredHeight = baseHeight + messageHeight + noteHeight + padding
        
        return CGSize(
            width: requiredWidth,
            height: requiredHeight
        )
    }
    
    private func calculateClassDiagramSize(diagram: MermaidDiagram) -> CGSize {
        let spacing: CGFloat = 80
        let padding: CGFloat = 100
        let classesPerRow = 3
        
        // 从 parsedData 中获取类的信息
        guard let classes = diagram.parsedData["classes"] as? [ClassEntity], !classes.isEmpty else {
            return CGSize(width: 800, height: 600)
        }
        
        // 计算每个类的实际尺寸
        var maxClassWidth: CGFloat = 120
        var totalHeight: CGFloat = 0
        
        for classEntity in classes {
            // 计算类名宽度
            let nameWidth = CGFloat(classEntity.name.count * 8) + 16
            
            // 计算属性宽度
            let attributeWidths = classEntity.attributes.map { attribute in
                CGFloat("\(attribute.visibility.symbol)\(attribute.type) \(attribute.name)".count * 7)
            }
            
            // 计算方法宽度
            let methodWidths = classEntity.methods.map { method in
                CGFloat("\(method.visibility.symbol)\(method.name)()".count * 7)
            }
            
            // 找到最大宽度
            let classWidth = ([nameWidth] + attributeWidths + methodWidths).max() ?? 120
            maxClassWidth = max(maxClassWidth, classWidth + 16)
            
            // 计算类的高度
            let headerHeight: CGFloat = 30
            let attributesHeight = classEntity.attributes.isEmpty ? 0 : CGFloat(classEntity.attributes.count) * 20 + 8
            let methodsHeight = classEntity.methods.isEmpty ? 0 : CGFloat(classEntity.methods.count) * 20 + 8
            let separatorHeight: CGFloat = (classEntity.attributes.isEmpty ? 0 : 1) + (classEntity.methods.isEmpty ? 0 : 1)
            
            let classHeight = headerHeight + attributesHeight + methodsHeight + separatorHeight
            totalHeight = max(totalHeight, classHeight)
        }
        
        // 计算布局
        let cols = min(classesPerRow, classes.count)
        let rows = Int(ceil(Double(classes.count) / Double(cols)))
        
        let requiredWidth = CGFloat(cols) * (maxClassWidth + spacing) - spacing + padding * 2
        let requiredHeight = CGFloat(rows) * (totalHeight + spacing) - spacing + padding * 2
        
        return CGSize(
            width: requiredWidth,
            height: requiredHeight
        )
    }
    
    private func calculateGitGraphSize(diagram: MermaidDiagram) -> CGSize {
        let commitSpacing: CGFloat = 100
        let branchSpacing: CGFloat = 80
        let padding: CGFloat = 100
        
        let commitCount = diagram.nodes.count
        if commitCount == 0 {
            return CGSize(width: 800, height: 400)
        }
        
        // 估算分支数量（简化计算）
        let branchCount = max(1, diagram.edges.map { [$0.from, $0.to] }.flatMap { $0 }.count / 3)
        
        let requiredWidth = CGFloat(commitCount) * commitSpacing + padding * 2
        let requiredHeight = CGFloat(branchCount) * branchSpacing + padding * 2
        
        return CGSize(
            width: requiredWidth,
            height: requiredHeight
        )
    }
    
    private func calculateGanttSize(diagram: MermaidDiagram) -> CGSize {
        let taskSpacing: CGFloat = 100
        let taskHeight: CGFloat = 40
        let padding: CGFloat = 100
        
        // 从 parsedData 中获取任务信息，或使用节点数量作为备选
        let tasks = diagram.parsedData["tasks"] as? [Any] ?? []
        let taskCount = max(tasks.count, diagram.nodes.count)
        
        if taskCount == 0 {
            return CGSize(width: 800, height: 400)
        }
        
        // 甘特图需要更多水平空间来显示时间轴
        let requiredWidth = max(600, CGFloat(taskCount) * taskSpacing + padding * 2)
        let requiredHeight = CGFloat(taskCount) * taskHeight + padding * 2
        
        return CGSize(
            width: requiredWidth,
            height: requiredHeight
        )
    }
    
    private func getTextSize(_ content: String, font: FontSize) -> CGSize {
        NSAttributedString(string: content, attributes: [.font: UIFont.custom(size: font)]).size()
    }
    private func calculateTimelineSize(diagram: MermaidDiagram) -> CGSize {
        // 从 parsedData 中获取时间线信息
        guard let timelineEvents = diagram.parsedData["events"] as? [TimelineEvent] else {
            return CGSize(width: 30, height: 30)
        }
        
        if timelineEvents.isEmpty {
            return CGSize(width: 60, height: 30)
        }
        
        // 获取标题
        let title = (diagram.parsedData["title"] as? String) ?? ""
        
        // 按时期分组事件
        var grouped: [String: [String]] = [:]
        var periodOrder: [String] = []
        
        for event in timelineEvents {
            if grouped[event.period] == nil {
                grouped[event.period] = []
                periodOrder.append(event.period)
            }
            grouped[event.period]?.append(event.event)
        }
        
        let groupedEvents = periodOrder.map { period in
            (period: period, events: grouped[period] ?? [])
        }
        
        let verticalSpacing: CGFloat = 16 
        let horizontalPadding: CGFloat = 24

        // 计算宽度：基于实际内容需求

        var totalWidth: CGFloat = horizontalPadding
        for group in groupedEvents {
            // 计算时期标题宽度
            let periodTitleWidth = getTextSize(group.period, font: .headline).width + 24 // 简化计算
            let maxEventWidth = group.events.map { getTextSize($0, font: .body).width }.max() ?? 100
            totalWidth += max(periodTitleWidth, maxEventWidth) + 42
        }
        
        // 计算高度：更精确的计算
        var totalHeight: CGFloat = verticalSpacing + 4 // 顶部间距
        
        // 标题高度（简化计算）
        if !title.isEmpty {
            totalHeight += getTextSize(title, font: .title2).height + 12 // 减少标题下方间距
        }
        
        // 计算最高的时期高度
        var maxPeriodHeight: CGFloat = 0
        
        for group in groupedEvents {
            var periodHeight: CGFloat = 0
            
            // 时期标题高度（简化）
            periodHeight += getTextSize(group.period, font: .headline).height + 20
            
            // 事件高度（更紧凑）
            group.events.forEach {
                periodHeight += getTextSize($0, font: .body).height + 8
            }
            periodHeight -= 8
            
            maxPeriodHeight = max(maxPeriodHeight, periodHeight)
        }
        
        totalHeight += maxPeriodHeight + verticalSpacing // 底部间距
        
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    private func calculateStateDiagramSize(diagram: MermaidDiagram) -> CGSize {
        // 从 parsedData 中获取状态图信息
        guard let stateDiagram = diagram.parsedData["stateDiagram"] as? StateDiagram else {
            return CGSize(width: 1000, height: 800) // 默认较大尺寸
        }
        
        let stateSpacing: CGFloat = 150 // 状态之间的间距
        let stateHeight: CGFloat = 80 // 状态高度
        let stateWidth: CGFloat = 120 // 状态宽度
        let padding: CGFloat = 150 // 边距
        
        // 获取状态数量
        let stateCount = stateDiagram.states.count
        if stateCount == 0 {
            return CGSize(width: 1000, height: 800)
        }
        
        // 计算嵌套状态（复合状态）的数量 - 暂时设为0，因为当前StateEntity没有isComposite属性
        let nestedStateCount = 0
        
        // 获取转换数量
        let transitionCount = stateDiagram.transitions.count
        
        // 估算图表的复杂度
        let complexity = Double(max(stateCount, 1)) * (1 + Double(nestedStateCount) * 0.5)
        
        // 根据状态图的方向调整宽高比
        let isHorizontal = diagram.rawText.contains("direction LR") || diagram.rawText.contains("direction RL")
        
        // 计算所需的宽度和高度
        var requiredWidth: CGFloat
        var requiredHeight: CGFloat
        
        if isHorizontal {
            // 水平方向的状态图
            let columns = ceil(sqrt(Double(stateCount)) * 1.5)
            let rows = ceil(Double(stateCount) / columns)
            
            requiredWidth = CGFloat(columns) * (stateWidth + stateSpacing) + padding * 2
            requiredHeight = CGFloat(rows) * (stateHeight + stateSpacing) + padding * 2
            
            // 考虑转换线的空间
            requiredWidth += CGFloat(transitionCount) * 10
        } else {
            // 垂直方向的状态图
            let rows = ceil(sqrt(Double(stateCount)) * 1.5)
            let columns = ceil(Double(stateCount) / rows)
            
            requiredWidth = CGFloat(columns) * (stateWidth + stateSpacing) + padding * 2
            requiredHeight = CGFloat(rows) * (stateHeight + stateSpacing) + padding * 2
            
            // 考虑转换线的空间
            requiredHeight += CGFloat(transitionCount) * 10
        }
        
        // 为复杂状态图提供更多空间
        let complexityFactor = CGFloat(1.0 + min(complexity * 0.1, 2.0))
        requiredWidth *= complexityFactor
        requiredHeight *= complexityFactor
        
        // 确保最小尺寸
        return CGSize(
            width: requiredWidth,
            height: requiredHeight
        )
    }
    
    private func calculateNodeLevel(_ node: Node, diagram: MermaidDiagram) -> Int {
        // 找到所有根节点（没有入边的节点）
        let allNodeIds = Set(diagram.nodes.map { $0.id })
        let targetNodes = Set(diagram.edges.map { $0.to })
        let rootNodes = Array(allNodeIds.subtracting(targetNodes))
        
        // 计算从任意根节点到当前节点的最大深度
        var maxLevel = 0
        for rootId in rootNodes {
            let level = calculateLevelFromRoot(rootId, to: node.id, diagram: diagram, visited: Set<String>())
            maxLevel = max(maxLevel, level)
        }
        
        return maxLevel
    }
    
    private func calculateLevelFromRoot(_ rootId: String, to targetId: String, diagram: MermaidDiagram, visited: Set<String>) -> Int {
        if rootId == targetId {
            return 0
        }
        
        if visited.contains(rootId) {
            return -1 // 检测到循环
        }
        
        var newVisited = visited
        newVisited.insert(rootId)
        
        var maxLevel = -1
        for edge in diagram.edges where edge.from == rootId {
            let level = calculateLevelFromRoot(edge.to, to: targetId, diagram: diagram, visited: newVisited)
            if level >= 0 {
                maxLevel = max(maxLevel, level + 1)
            }
        }
        
        return maxLevel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        
        // 设置 ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isDirectionalLockEnabled = false
        scrollView.delegate = self
        
        if rootView.minScaler != 0 {
            scrollView.maximumZoomScale = rootView.maxScaler
            scrollView.minimumZoomScale = rootView.minScaler
        }
        
        hostingView.view.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
        
        scrollView.addSubview(hostingView.view)
        hostingView.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 使用固定的内容尺寸，避免 GeometryReader 冲突
        NSLayoutConstraint.activate([
            hostingView.view.widthAnchor.constraint(equalToConstant: contentSize.width),
            hostingView.view.heightAnchor.constraint(equalToConstant: contentSize.height),
            hostingView.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostingView.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor)
        ])
        
        // 设置 scrollView 的 contentSize
        scrollView.contentSize = contentSize
        
        scrollView.contentInset.top = rootView.topIns
        scrollView.contentInset.bottom = rootView.bottomIns
        scrollView.contentInset.left = rootView.leftIns
        scrollView.contentInset.right = rootView.rightIns
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if rootView.minScaler == 0 {
            let minScaler = min(
                (view.bounds.width - rootView.leftIns - rootView.rightIns) / contentSize.width,
                (view.bounds.height - rootView.topIns - rootView.bottomIns) / contentSize.height
            )
            
            if scrollView.minimumZoomScale != minScaler {
                scrollView.minimumZoomScale = minScaler
                scrollView.maximumZoomScale = scrollView.minimumZoomScale + rootView.maxScaler
                scrollView.zoomScale = scrollView.minimumZoomScale
            }
        }
        
        scrollViewDidZoom(scrollView)
        
        if rootView.scrollToCenter {
            scrollView.zoomScale = min(
                (view.bounds.width - rootView.leftIns - rootView.rightIns) / contentSize.width,
                (view.bounds.height - rootView.topIns - rootView.bottomIns) / contentSize.height
            )
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if rootView.minScaler == 0 {
            let minScaler = min(
                (view.bounds.width - rootView.leftIns - rootView.rightIns) / contentSize.width,
                (view.bounds.height - rootView.topIns - rootView.bottomIns) / contentSize.height
            )
            
            if scrollView.minimumZoomScale != minScaler {
                scrollView.minimumZoomScale = minScaler
                scrollView.maximumZoomScale = scrollView.minimumZoomScale + rootView.maxScaler
                
                if scrollView.zoomScale < minScaler {
                    if rootView.scrollToCenter {
                        scrollView.zoomScale = min(
                            (view.bounds.width - rootView.leftIns - rootView.rightIns) / contentSize.width,
                            (view.bounds.height - rootView.topIns - rootView.bottomIns) / contentSize.height
                        )
                    } else {
                        scrollView.zoomScale = scrollView.minimumZoomScale
                    }
                }
            }
        }
        
        scrollViewDidZoom(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return hostingView.view
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let scaledContentSize = CGSize(
            width: contentSize.width * scrollView.zoomScale,
            height: contentSize.height * scrollView.zoomScale
        )
        
        scrollView.contentInset.left = max(
            (view.bounds.width - scaledContentSize.width) / 2,
            rootView.leftIns
        )
        scrollView.contentInset.top = max(
            (view.bounds.height - scaledContentSize.height) / 2,
            rootView.topIns
        )
    }
}
#endif

#Preview {
    mermaidView(scrollable: true, text: """
    graph TD
        A[Start] --> B{Is it?}
        B -->|Yes| C[OK]
        B -->|No| D[End]
    """)
    .frame(width: 400, height: 300)
}
