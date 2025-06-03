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
        
        // Create the content view
         let hostingController = UIHostingController(rootView: AnyView(createDiagramView()))
         hostingController.view.backgroundColor = UIColor.clear
         
         // Add the hosting controller's view to scroll view
         scrollView.addSubview(hostingController.view)
         
         // Store the hosting controller in the coordinator
         context.coordinator.hostingController = hostingController
         context.coordinator.scrollView = scrollView
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
         // Update the diagram when text changes
         let newDiagramView = AnyView(createDiagramView())
         context.coordinator.hostingController?.rootView = newDiagramView
         
         // Recalculate content size
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
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController?.view
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerContent()
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            // Ensure text remains crisp after zooming
            if let hostingView = hostingController?.view {
                hostingView.layer.shouldRasterize = false
                hostingView.contentScaleFactor = UIScreen.main.scale * scale
            }
        }
        
        func updateContentSize() {
            guard let scrollView = scrollView,
                  let hostingView = hostingController?.view else { return }
            
            // Calculate the intrinsic content size
            let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width,
                                  height: UIView.layoutFittingCompressedSize.height)
            let contentSize = hostingView.systemLayoutSizeFitting(targetSize,
                                                                withHorizontalFittingPriority: .fittingSizeLevel,
                                                                verticalFittingPriority: .fittingSizeLevel)
            
            // Set a minimum size to ensure proper display
            let minSize = CGSize(width: max(contentSize.width, 400),
                               height: max(contentSize.height, 300))
            
            // Update frame and content size
            hostingView.frame = CGRect(origin: .zero, size: minSize)
            scrollView.contentSize = minSize
            
            // Center the content initially
            centerContent()
        }
        
        private func centerContent() {
            guard let scrollView = scrollView else { return }
            
            let scrollViewSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize
            let zoomScale = scrollView.zoomScale
            
            let scaledContentSize = CGSize(width: contentSize.width * zoomScale,
                                         height: contentSize.height * zoomScale)
            
            var contentInset = UIEdgeInsets.zero
            
            if scaledContentSize.width < scrollViewSize.width {
                contentInset.left = (scrollViewSize.width - scaledContentSize.width) / 2
                contentInset.right = contentInset.left
            }
            
            if scaledContentSize.height < scrollViewSize.height {
                contentInset.top = (scrollViewSize.height - scaledContentSize.height) / 2
                contentInset.bottom = contentInset.top
            }
            
            scrollView.contentInset = contentInset
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