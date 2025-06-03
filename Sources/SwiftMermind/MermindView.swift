import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A SwiftUI view that renders Mermaid diagrams with zoom and scroll capabilities
public struct mermindView: View {
    private let scrollable: Bool
    private let text: String
    private let parser: MermaidParser
    
    public init(scrollable: Bool, text: String) {
        self.scrollable = scrollable
        self.text = text
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
        uiViewController.hostingView.rootView = AnyView(createDiagramView())
    }
    
    func createDiagramView() -> some View {
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
}

class ZoomableScrollViewController: UIViewController, UIScrollViewDelegate {
    let rootView: ZoomableScrollView
    var hostingView: UIHostingController<AnyView>
    var scrollView: UIScrollView = UIScrollView()
    
    init(rootView: ZoomableScrollView) {
        self.rootView = rootView
        self.hostingView = UIHostingController(rootView: AnyView(rootView.createDiagramView()))
        hostingView.view.isUserInteractionEnabled = true
        super.init(nibName: nil, bundle: nil)
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
        
        NSLayoutConstraint.activate([
            scrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: hostingView.view.heightAnchor),
            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: hostingView.view.widthAnchor)
        ])
        
        scrollView.contentInset.top = rootView.topIns
        scrollView.contentInset.bottom = rootView.bottomIns
        scrollView.contentInset.left = rootView.leftIns
        scrollView.contentInset.right = rootView.rightIns
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if rootView.minScaler == 0 {
            let minScaler = min(
                (view.bounds.width - rootView.leftIns - rootView.rightIns) / hostingView.view.bounds.width,
                (view.bounds.height - rootView.topIns - rootView.bottomIns) / hostingView.view.bounds.height
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
                (view.bounds.width - rootView.leftIns - rootView.rightIns) / hostingView.view.bounds.width,
                (view.bounds.height - rootView.topIns - rootView.bottomIns) / hostingView.view.bounds.height
            )
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if rootView.minScaler == 0 {
            let minScaler = min(
                (view.bounds.width - rootView.leftIns - rootView.rightIns) / hostingView.view.bounds.width,
                (view.bounds.height - rootView.topIns - rootView.bottomIns) / hostingView.view.bounds.height
            )
            
            if scrollView.minimumZoomScale != minScaler {
                scrollView.minimumZoomScale = minScaler
                scrollView.maximumZoomScale = scrollView.minimumZoomScale + rootView.maxScaler
                
                if scrollView.zoomScale < minScaler {
                    if rootView.scrollToCenter {
                        scrollView.zoomScale = min(
                            (view.bounds.width - rootView.leftIns - rootView.rightIns) / hostingView.view.bounds.width,
                            (view.bounds.height - rootView.topIns - rootView.bottomIns) / hostingView.view.bounds.height
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
        scrollView.contentInset.left = max(
            (view.bounds.width - hostingView.view.frame.width) / 2,
            rootView.leftIns
        )
        scrollView.contentInset.top = max(
            (view.bounds.height - hostingView.view.frame.height) / 2,
            rootView.topIns
        )
    }
}
#endif

#Preview {
    mermindView(scrollable: true, text: """
    graph TD
        A[Start] --> B{Is it?}
        B -->|Yes| C[OK]
        B -->|No| D[End]
    """)
    .frame(width: 400, height: 300)
}
