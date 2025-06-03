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
            
            // 为SwiftUI视图提供足够大的空间来计算其理想大小
            let proposedSize = CGSize(width: max(scrollViewSize.width, 800), 
                                    height: max(scrollViewSize.height, 600))
            
            // 临时设置一个大的frame来让SwiftUI计算其内容大小
            hostingView.frame = CGRect(origin: .zero, size: proposedSize)
            hostingView.setNeedsLayout()
            hostingView.layoutIfNeeded()
            
            // 使用systemLayoutSizeFitting获取内容的实际大小
            let fittingSize = hostingView.systemLayoutSizeFitting(
                proposedSize,
                withHorizontalFittingPriority: .defaultLow,
                verticalFittingPriority: .defaultLow
            )
            
            // 确保内容大小至少和滚动视图一样大，避免内容过小
            let contentWidth = max(fittingSize.width, scrollViewSize.width)
            let contentHeight = max(fittingSize.height, scrollViewSize.height)
            let contentSize = CGSize(width: contentWidth, height: contentHeight)
            
            // 设置最终的frame和contentSize
            hostingView.frame = CGRect(origin: .zero, size: contentSize)
            scrollView.contentSize = contentSize
            
            // 确保清晰的渲染
            hostingView.layer.contentsScale = UIScreen.main.scale
            
            // 重置滚动条位置和内容边距
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
            
            // 只在初始设置时居中内容
            if isInitialSetup {
                centerContent()
                isInitialSetup = false
            }
        }
        
        private func centerContent() {
            guard let scrollView = scrollView else { return }
            
            let scrollViewSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize
            
            // 只有当内容小于滚动视图时才居中
            if contentSize.width < scrollViewSize.width || contentSize.height < scrollViewSize.height {
                var contentOffset = CGPoint.zero
                
                if contentSize.width < scrollViewSize.width {
                    contentOffset.x = -(scrollViewSize.width - contentSize.width) / 2
                }
                
                if contentSize.height < scrollViewSize.height {
                    contentOffset.y = -(scrollViewSize.height - contentSize.height) / 2
                }
                
                scrollView.contentOffset = contentOffset
            } else {
                // 对于大内容，设置到左上角
                scrollView.contentOffset = .zero
            }
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