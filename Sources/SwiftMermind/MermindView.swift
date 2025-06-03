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
            // 只在缩放时调整内容位置，避免强制居中
            adjustContentInsets()
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            // Ensure text remains crisp after zooming
            if let hostingView = hostingController?.view {
                hostingView.layer.shouldRasterize = false
                // Force re-render at the new scale for crisp text
                hostingView.layer.contentsScale = UIScreen.main.scale * scale
                hostingView.setNeedsDisplay()
            }
            adjustContentInsets()
        }
        
        func updateContentSize() {
            guard let scrollView = scrollView,
                  let hostingView = hostingController?.view else { return }
            
            // Force layout update
            hostingView.setNeedsLayout()
            hostingView.layoutIfNeeded()
            
            // Calculate content size based on SwiftUI view's intrinsic size
            let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, 
                               height: CGFloat.greatestFiniteMagnitude)
            let fittingSize = hostingView.systemLayoutSizeFitting(
                maxSize,
                withHorizontalFittingPriority: .defaultLow,
                verticalFittingPriority: .defaultLow
            )
            
            // Ensure minimum size for proper display
            let contentWidth = max(fittingSize.width, 400)
            let contentHeight = max(fittingSize.height, 300)
            let contentSize = CGSize(width: contentWidth, height: contentHeight)
            
            // Update frame and content size
            hostingView.frame = CGRect(origin: .zero, size: contentSize)
            scrollView.contentSize = contentSize
            
            // Ensure proper scaling for crisp rendering
            hostingView.layer.contentsScale = UIScreen.main.scale
            
            // 只在初始设置时居中内容
            if isInitialSetup {
                centerContent()
                isInitialSetup = false
            } else {
                adjustContentInsets()
            }
        }
        
        private func centerContent() {
            guard let scrollView = scrollView else { return }
            
            let scrollViewSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize
            let zoomScale = scrollView.zoomScale
            
            // Calculate the actual size of content after zoom
            let scaledContentSize = CGSize(
                width: contentSize.width * zoomScale,
                height: contentSize.height * zoomScale
            )
            
            // Calculate content offset to center the content
            var contentOffset = CGPoint.zero
            
            if scaledContentSize.width < scrollViewSize.width {
                contentOffset.x = -(scrollViewSize.width - scaledContentSize.width) / 2
            }
            
            if scaledContentSize.height < scrollViewSize.height {
                contentOffset.y = -(scrollViewSize.height - scaledContentSize.height) / 2
            }
            
            scrollView.contentOffset = contentOffset
        }
        
        // 新方法：调整内容边距而不强制居中
        private func adjustContentInsets() {
            guard let scrollView = scrollView else { return }
            
            let scrollViewSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize
            let zoomScale = scrollView.zoomScale
            
            // Calculate the actual size of content after zoom
            let scaledContentSize = CGSize(
                width: contentSize.width * zoomScale,
                height: contentSize.height * zoomScale
            )
            
            // 计算内容边距，让小内容可以居中，但不强制移动大内容
            var contentInset = UIEdgeInsets.zero
            
            if scaledContentSize.width < scrollViewSize.width {
                let horizontalInset = (scrollViewSize.width - scaledContentSize.width) / 2
                contentInset.left = horizontalInset
                contentInset.right = horizontalInset
            }
            
            if scaledContentSize.height < scrollViewSize.height {
                let verticalInset = (scrollViewSize.height - scaledContentSize.height) / 2
                contentInset.top = verticalInset
                contentInset.bottom = verticalInset
            }
            
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
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