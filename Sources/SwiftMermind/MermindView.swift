import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A SwiftUI view that renders Mermaid diagrams with zoom and scroll capabilities
public struct mermindView: View {
    private let text: String
    private let parser: MermaidParser
    
    public init(text: String) {
        self.text = text
        self.parser = MermaidParser()
    }
    
    public var body: some View {
        #if canImport(UIKit)
        ZoomableScrollView(text: text, parser: parser)
        #else
        // Fallback for macOS without UIKit
        GeometryReader { geometry in
            let diagram = parser.parse(text)
            
            switch diagram.type {
            case .flowchart:
                FlowchartView(diagram: diagram)
            case .sequenceDiagram:
                SequenceDiagramView(diagram: diagram, size: geometry.size)
            case .classDiagram:
                ClassDiagramView(diagram: diagram, size: geometry.size)
            case .stateDiagram:
                StateDiagramView(diagram: diagram, size: geometry.size)
            case .gantt:
                GanttChartView(diagram: diagram, size: geometry.size)
            case .pie:
                PieChartView(diagram: diagram, size: geometry.size)
            case .gitGraph:
                GitGraphView(diagram: diagram, size: geometry.size)
            case .erDiagram:
                ERDiagramView(diagram: diagram, size: geometry.size)
            case .userJourney:
                UserJourneyView(diagram: diagram, size: geometry.size)
            case .unknown:
                Text("Unsupported diagram type")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        #endif
    }
}

#if canImport(UIKit)
/// A zoomable and scrollable container for Mermaid diagrams using UIScrollView
struct ZoomableScrollView: UIViewRepresentable {
    let text: String
    let parser: MermaidParser
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.backgroundColor = UIColor.clear
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        
        // Create the content view
        let hostingController = UIHostingController(rootView: AnyView(createDiagramView()))
        hostingController.view.backgroundColor = UIColor.clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the hosting controller's view to scroll view
        scrollView.addSubview(hostingController.view)
        
        // Store the hosting controller in the coordinator
        context.coordinator.hostingController = hostingController
        context.coordinator.scrollView = scrollView
        
        // Initial setup
        DispatchQueue.main.async {
            context.coordinator.updateContentSize()
        }
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // Update the diagram when text changes
        let newDiagramView = AnyView(createDiagramView())
        context.coordinator.hostingController?.rootView = newDiagramView
        
        // Reset zoom and recalculate content size
        scrollView.zoomScale = 1.0
        DispatchQueue.main.async {
            context.coordinator.updateContentSize()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func createDiagramView() -> some View {
        GeometryReader { geometry in
            let diagram = parser.parse(text)
            
            switch diagram.type {
            case .flowchart:
                FlowchartView(diagram: diagram)
            case .sequenceDiagram:
                SequenceDiagramView(diagram: diagram, size: geometry.size)
            case .classDiagram:
                ClassDiagramView(diagram: diagram, size: geometry.size)
            case .stateDiagram:
                StateDiagramView(diagram: diagram, size: geometry.size)
            case .gantt:
                GanttChartView(diagram: diagram, size: geometry.size)
            case .pie:
                PieChartView(diagram: diagram, size: geometry.size)
            case .gitGraph:
                GitGraphView(diagram: diagram, size: geometry.size)
            case .erDiagram:
                ERDiagramView(diagram: diagram, size: geometry.size)
            case .userJourney:
                UserJourneyView(diagram: diagram, size: geometry.size)
            case .unknown:
                Text("Unsupported diagram type")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.clear)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<AnyView>?
        var scrollView: UIScrollView?
        private var isInitialSetup = true
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController?.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // Update content scale for crisp rendering during zoom
            if let hostingView = hostingController?.view {
                hostingView.layer.contentsScale = UIScreen.main.scale * scrollView.zoomScale
            }
            // 缩放时重新居中内容
            centerContent()
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            // Ensure text remains crisp after zooming
            if let hostingView = hostingController?.view {
                hostingView.layer.shouldRasterize = false
                // Force re-render at the new scale for crisp text
                hostingView.layer.contentsScale = UIScreen.main.scale * scale
                hostingView.setNeedsDisplay()
            }
        }
        
        func updateContentSize() {
            guard let scrollView = scrollView,
                  let hostingView = hostingController?.view else { return }
            
            // 获取当前滚动视图的实际大小
            let scrollViewSize = scrollView.bounds.size
            guard scrollViewSize.width > 0 && scrollViewSize.height > 0 else {
                // 如果滚动视图还没有大小，延迟执行
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateContentSize()
                }
                return
            }
            
            // 为SwiftUI视图提供更大的空间来计算其理想大小，确保不会截断内容
            let proposedSize = CGSize(width: Int.max,
                                    height: Int.max)
            
            // 临时设置一个大的frame来让SwiftUI计算其内容大小
            hostingView.frame = CGRect(origin: .zero, size: proposedSize)
            hostingView.setNeedsLayout()
            hostingView.layoutIfNeeded()
            
            // 使用systemLayoutSizeFitting获取内容的实际大小
            let fittingSize = hostingView.systemLayoutSizeFitting(
                proposedSize,
                withHorizontalFittingPriority: .fittingSizeLevel,
                verticalFittingPriority: .fittingSizeLevel
            )
            
            // 使用实际计算出的大小，添加一些边距确保内容完整显示
            let contentWidth = max(fittingSize.width + 40, scrollViewSize.width)
            let contentHeight = max(fittingSize.height + 40, scrollViewSize.height)
            let contentSize = CGSize(width: contentWidth, height: contentHeight)
            
            // 设置最终的frame和contentSize
            hostingView.frame = CGRect(origin: .zero, size: contentSize)
            scrollView.contentSize = contentSize
            
            // 确保清晰的渲染
            hostingView.layer.contentsScale = UIScreen.main.scale
            
            // 重置滚动条位置和内容边距
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
            
            // 每次更新后都重新居中内容
            DispatchQueue.main.async {
                self.centerContent()
            }
        }
        
        private func centerContent() {
            guard let scrollView = scrollView else { return }
            
            let scrollViewSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize
            let currentZoom = scrollView.zoomScale
            
            // 计算缩放后的实际内容大小
            let scaledContentSize = CGSize(
                width: contentSize.width * currentZoom,
                height: contentSize.height * currentZoom
            )
            
            var contentOffset = CGPoint.zero
            
            // 水平居中：如果缩放后的内容宽度小于滚动视图宽度，则居中
            if scaledContentSize.width <= scrollViewSize.width {
                contentOffset.x = -(scrollViewSize.width - scaledContentSize.width) / 2 / currentZoom
            } else {
                // 内容较大时，确保不超出边界
                let maxOffsetX = contentSize.width - scrollViewSize.width / currentZoom
                contentOffset.x = max(0, min(scrollView.contentOffset.x, maxOffsetX))
            }
            
            // 垂直居中：如果缩放后的内容高度小于滚动视图高度，则居中
            if scaledContentSize.height <= scrollViewSize.height {
                contentOffset.y = -(scrollViewSize.height - scaledContentSize.height) / 2 / currentZoom
            } else {
                // 内容较大时，确保不超出边界
                let maxOffsetY = contentSize.height - scrollViewSize.height / currentZoom
                contentOffset.y = max(0, min(scrollView.contentOffset.y, maxOffsetY))
            }
            
            scrollView.contentOffset = contentOffset
        }
        

    }
}
#endif

#Preview {
    mermindView(text: """
    graph TD
        A[Start] --> B{Is it?}
        B -->|Yes| C[OK]
        B -->|No| D[End]
    """)
    .frame(width: 400, height: 300)
}
