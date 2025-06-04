import Foundation

/// Represents the type of Mermaid diagram
public enum DiagramType {
    case flowchart
    case sequenceDiagram
    case classDiagram
    case stateDiagram
    case gantt
    case pie
    case gitGraph
    case erDiagram
    case userJourney
    case unknown
}

// MARK: - Class Diagram Data Structures

/// Represents a class in a class diagram
public struct ClassEntity: Equatable {
    public let name: String
    public let attributes: [ClassAttribute]
    public let methods: [ClassMethod]
    public let position: CGPoint
    
    public init(name: String, attributes: [ClassAttribute] = [], methods: [ClassMethod] = [], position: CGPoint = .zero) {
        self.name = name
        self.attributes = attributes
        self.methods = methods
        self.position = position
    }
    
    public static func == (lhs: ClassEntity, rhs: ClassEntity) -> Bool {
        return lhs.name == rhs.name &&
               lhs.attributes == rhs.attributes &&
               lhs.methods == rhs.methods &&
               lhs.position == rhs.position
    }
}

/// Represents an attribute in a class
public struct ClassAttribute: Equatable {
    public let name: String
    public let type: String
    public let visibility: ClassVisibility
    
    public init(name: String, type: String, visibility: ClassVisibility) {
        self.name = name
        self.type = type
        self.visibility = visibility
    }
}

/// Represents a method in a class
public struct ClassMethod: Equatable {
    public let name: String
    public let returnType: String?
    public let parameters: [String]
    public let visibility: ClassVisibility
    
    public init(name: String, returnType: String? = nil, parameters: [String] = [], visibility: ClassVisibility) {
        self.name = name
        self.returnType = returnType
        self.parameters = parameters
        self.visibility = visibility
    }
}

/// Represents the visibility of class members
public enum ClassVisibility {
    case public_    // +
    case private_   // -
    case protected  // #
    case package    // ~
    
    public var symbol: String {
        switch self {
        case .public_: return "+"
        case .private_: return "-"
        case .protected: return "#"
        case .package: return "~"
        }
    }
}

/// Represents a relationship between classes
public struct ClassRelationship {
    public let from: String
    public let to: String
    public let type: ClassRelationshipType
    public let label: String?
    
    public init(from: String, to: String, type: ClassRelationshipType, label: String? = nil) {
        self.from = from
        self.to = to
        self.type = type
        self.label = label
    }
}

/// Represents the type of relationship between classes
public enum ClassRelationshipType {
    case inheritance     // <|--
    case composition     // *--
    case aggregation     // o--
    case association     // -->
    case dependency      // ..>
    case realization     // ..|>
}

// MARK: - State Diagram Data Structures

/// Represents a state in a state diagram
public struct StateEntity: Equatable {
    public let id: String
    public let description: String?
    public let isStart: Bool
    public let isEnd: Bool
    public let position: CGPoint
    
    public init(id: String, description: String? = nil, isStart: Bool = false, isEnd: Bool = false, position: CGPoint = .zero) {
        self.id = id
        self.description = description
        self.isStart = isStart
        self.isEnd = isEnd
        self.position = position
    }
    
    public static func == (lhs: StateEntity, rhs: StateEntity) -> Bool {
        return lhs.id == rhs.id &&
               lhs.description == rhs.description &&
               lhs.isStart == rhs.isStart &&
               lhs.isEnd == rhs.isEnd &&
               lhs.position == rhs.position
    }
}

/// Represents a transition between states
public struct StateTransition {
    public let from: String
    public let to: String
    public let label: String?
    
    public init(from: String, to: String, label: String? = nil) {
        self.from = from
        self.to = to
        self.label = label
    }
}

/// Represents a complete state diagram
public struct StateDiagram {
    public let states: [StateEntity]
    public let transitions: [StateTransition]
    
    public init(states: [StateEntity], transitions: [StateTransition]) {
        self.states = states
        self.transitions = transitions
    }
}

// MARK: - Sequence Diagram Data Structures

/// Represents a message in a sequence diagram
public struct SequenceMessage {
    public let from: String
    public let to: String
    public let text: String
    public let type: SequenceMessageType
    
    public init(from: String, to: String, text: String, type: SequenceMessageType) {
        self.from = from
        self.to = to
        self.text = text
        self.type = type
    }
}

/// Represents the type of message in a sequence diagram
public enum SequenceMessageType {
    case syncRequest      // ->
    case asyncRequest     // ->>
    case syncResponse     // -->
    case asyncResponse    // -->>
    case lost            // -x or --x
    case found           // ->> or -->
}

/// Represents a note in a sequence diagram
public struct SequenceNote {
    public let text: String
    public let position: SequenceNotePosition
    public let participants: [String]
    
    public init(text: String, position: SequenceNotePosition, participants: [String]) {
        self.text = text
        self.position = position
        self.participants = participants
    }
}

/// Represents the position of a note in a sequence diagram
public enum SequenceNotePosition {
    case leftOf(String)
    case rightOf(String)
    case over([String])
}

/// Represents an activation/deactivation in a sequence diagram
public struct SequenceActivation {
    public let participant: String
    public let isActivate: Bool
    
    public init(participant: String, isActivate: Bool) {
        self.participant = participant
        self.isActivate = isActivate
    }
}

/// Represents a loop construct in a sequence diagram
public struct SequenceLoop {
    public let text: String
    public let startIndex: Int
    public var endIndex: Int
    public var messages: [SequenceMessage]
    
    public init(text: String, startIndex: Int, endIndex: Int, messages: [SequenceMessage]) {
        self.text = text
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.messages = messages
    }
}

/// Represents a parsed Mermaid diagram
public struct MermaidDiagram {
    public let type: DiagramType
    public let nodes: [Node]
    public let edges: [Edge]
    public let rawText: String
    public let parsedData: [String: Any]
    
    public init(type: DiagramType, nodes: [Node] = [], edges: [Edge] = [], rawText: String, parsedData: [String: Any] = [:]) {
        self.type = type
        self.nodes = nodes
        self.edges = edges
        self.rawText = rawText
        self.parsedData = parsedData
    }
}

/// Represents a node in a diagram
public struct Node: Identifiable {
    public let id: String
    public let label: String
    public let shape: NodeShape
    public var position: CGPoint
    public let style: NodeStyle
    
    public init(id: String, label: String, shape: NodeShape = .rectangle, position: CGPoint = .zero, style: NodeStyle = NodeStyle()) {
        self.id = id
        self.label = label
        self.shape = shape
        self.position = position
        self.style = style
    }
}

/// Represents the shape of a node
public enum NodeShape {
    case rectangle
    case roundedRectangle
    case circle
    case diamond
    case hexagon
    case parallelogram
    case trapezoid
    case database
    case custom(String)
}

/// Represents the style of a node
public struct NodeStyle {
    public let fillColor: Color
    public let strokeColor: Color
    public let strokeWidth: CGFloat
    public let textColor: Color
    public let fontSize: CGFloat
    public let fontWeight: Font.Weight
    
    public init(
        fillColor: Color = .white,
        strokeColor: Color = .black,
        strokeWidth: CGFloat = 1.0,
        textColor: Color = .black,
        fontSize: CGFloat = 14.0,
        fontWeight: Font.Weight = .regular
    ) {
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.textColor = textColor
        self.fontSize = fontSize
        self.fontWeight = fontWeight
    }
}

/// Represents an edge (connection) between nodes
public struct Edge: Identifiable {
    public let id: UUID
    public let from: String
    public let to: String
    public let label: String
    public let style: EdgeStyle
    public let type: EdgeType
    
    public init(
        id: UUID = UUID(),
        from: String,
        to: String,
        label: String = "",
        style: EdgeStyle = EdgeStyle(),
        type: EdgeType = .solid
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.label = label
        self.style = style
        self.type = type
    }
}

/// Represents the style of an edge
public struct EdgeStyle {
    public let strokeColor: Color
    public let strokeWidth: CGFloat
    public let textColor: Color
    public let fontSize: CGFloat
    
    public init(
        strokeColor: Color = .black,
        strokeWidth: CGFloat = 1.0,
        textColor: Color = .black,
        fontSize: CGFloat = 12.0
    ) {
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.textColor = textColor
        self.fontSize = fontSize
    }
}

/// Represents the type of edge
public enum EdgeType: Equatable {
    case solid
    case dashed
    case dotted
    case arrow
    case doubleArrow
    case custom(String)
    
    public static func == (lhs: EdgeType, rhs: EdgeType) -> Bool {
        switch (lhs, rhs) {
        case (.solid, .solid), (.dashed, .dashed), (.dotted, .dotted), (.arrow, .arrow), (.doubleArrow, .doubleArrow):
            return true
        case (.custom(let lhsValue), .custom(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

/// Parser for Mermaid diagram syntax
public class MermaidParser {
    public init() {}
    
    /// Parse Mermaid diagram text into a structured representation
    /// - Parameter text: The Mermaid diagram text
    /// - Returns: A structured representation of the diagram
    public func parse(_ text: String) -> MermaidDiagram {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = trimmedText.components(separatedBy: .newlines)
        
        guard let firstLine = lines.first?.trimmingCharacters(in: .whitespaces) else {
            return MermaidDiagram(type: .unknown, rawText: text)
        }
        
        let diagramType = determineDiagramType(firstLine)
        
        switch diagramType {
        case .flowchart:
            return parseFlowchart(text)
        case .sequenceDiagram:
            return parseSequenceDiagram(text)
        case .classDiagram:
            return parseClassDiagram(text)
        case .stateDiagram:
            return parseStateDiagram(text)
        case .gantt:
            return parseGantt(text)
        case .pie:
            return parsePieChart(text)
        case .gitGraph:
            return parseGitGraph(text)
        case .erDiagram:
            return parseERDiagram(text)
        case .userJourney:
            return parseUserJourney(text)
        case .unknown:
            return MermaidDiagram(type: .unknown, rawText: text)
        }
    }
    
    private func determineDiagramType(_ firstLine: String) -> DiagramType {
        let lowercasedLine = firstLine.lowercased()
        
        if lowercasedLine.hasPrefix("graph") || lowercasedLine.hasPrefix("flowchart") {
            return .flowchart
        } else if lowercasedLine.hasPrefix("sequencediagram") {
            return .sequenceDiagram
        } else if lowercasedLine.hasPrefix("classdiagram") {
            return .classDiagram
        } else if lowercasedLine.hasPrefix("statediagram") {
            return .stateDiagram
        } else if lowercasedLine.hasPrefix("gantt") {
            return .gantt
        } else if lowercasedLine.hasPrefix("pie") {
            return .pie
        } else if lowercasedLine.hasPrefix("gitgraph") {
            return .gitGraph
        } else if lowercasedLine.hasPrefix("erdiagram") {
            return .erDiagram
        } else if lowercasedLine.hasPrefix("journey") {
            return .userJourney
        } else {
            return .unknown
        }
    }
    
    // MARK: - Diagram-specific parsers
    
    private func parseFlowchart(_ text: String) -> MermaidDiagram {
        var nodes: [Node] = []
        var edges: [Edge] = []
        var nodeIds = Set<String>()
        
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines and graph declaration
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("graph") || trimmedLine.hasPrefix("flowchart") {
                continue
            }
            
            // Skip comments (lines starting with %%)
            if trimmedLine.hasPrefix("%%") {
                continue
            }
            
            // Skip style definitions (classDef)
            if trimmedLine.hasPrefix("classDef") {
                continue
            }
            
            // Skip style applications (class)
            if trimmedLine.hasPrefix("class ") {
                continue
            }
            
            // Skip subgraph declarations and endings
            if trimmedLine.hasPrefix("subgraph") || trimmedLine == "end" {
                continue
            }
            
            // Skip linkStyle declarations
            if trimmedLine.hasPrefix("linkStyle") {
                continue
            }
            
            // Parse nodes and edges from the line
            parseFlowchartLine(trimmedLine, nodes: &nodes, edges: &edges, nodeIds: &nodeIds)
        }
        
        return MermaidDiagram(type: .flowchart, nodes: nodes, edges: edges, rawText: text)
    }
    
    private func parseFlowchartLine(_ line: String, nodes: inout [Node], edges: inout [Edge], nodeIds: inout Set<String>) {
        // Handle different arrow types, including edge labels with --
        let arrowPatterns = ["-->", "--->", "-.->" , "==>", "-.->"]
        
        // First check for edge labels with -- syntax (e.g., A4 -- 是 --> A5)
        if let edgeLabelMatch = line.range(of: #"\s--\s[^-]+\s-->\s"#, options: .regularExpression) {
            let matchString = String(line[edgeLabelMatch])
            let components = matchString.components(separatedBy: "--")
            if components.count >= 2 {
                let beforeLabel = components[0].trimmingCharacters(in: .whitespaces)
                let afterLabelPart = components[1].trimmingCharacters(in: .whitespaces)
                
                if let arrowIndex = afterLabelPart.range(of: "-->") {
                    let edgeLabel = String(afterLabelPart[..<arrowIndex.lowerBound]).trimmingCharacters(in: .whitespaces)
                    let afterArrow = String(afterLabelPart[arrowIndex.upperBound...]).trimmingCharacters(in: .whitespaces)
                    
                    // Extract node info
                    let (fromId, fromLabel, fromShape) = extractNodeInfo(beforeLabel)
                    let (toId, toLabel, toShape) = extractNodeInfo(afterArrow)
                    
                    // Add nodes if not already added
                    if !nodeIds.contains(fromId) {
                        nodes.append(Node(id: fromId, label: fromLabel, shape: fromShape))
                        nodeIds.insert(fromId)
                    }
                    
                    if !nodeIds.contains(toId) {
                        nodes.append(Node(id: toId, label: toLabel, shape: toShape))
                        nodeIds.insert(toId)
                    }
                    
                    // Add edge with label
                    edges.append(Edge(from: fromId, to: toId, label: edgeLabel))
                    return
                }
            }
        }
        
        // Handle standard arrow patterns
        for arrowPattern in arrowPatterns {
            if line.contains(arrowPattern) {
                let parts = line.components(separatedBy: arrowPattern)
                if parts.count >= 2 {
                    let fromPart = parts[0].trimmingCharacters(in: .whitespaces)
                    let toPart = parts[1].trimmingCharacters(in: .whitespaces)
                    
                    // Extract node info from left side
                    let (fromId, fromLabel, fromShape) = extractNodeInfo(fromPart)
                    
                    // Extract node info and edge label from right side
                    let (toId, toLabel, toShape, edgeLabel) = extractNodeInfoWithEdgeLabel(toPart)
                    
                    // Add nodes if not already added
                    if !nodeIds.contains(fromId) {
                        nodes.append(Node(id: fromId, label: fromLabel, shape: fromShape))
                        nodeIds.insert(fromId)
                    }
                    
                    if !nodeIds.contains(toId) {
                        nodes.append(Node(id: toId, label: toLabel, shape: toShape))
                        nodeIds.insert(toId)
                    }
                    
                    // Add edge
                    edges.append(Edge(from: fromId, to: toId, label: edgeLabel))
                    
                    return // Found an arrow, processed the line
                }
            }
        }
    }
    
    private func extractNodeInfo(_ nodeString: String) -> (id: String, label: String, shape: NodeShape) {
        let trimmed = nodeString.trimmingCharacters(in: .whitespaces)
        
        // Check for different node shapes with improved regex patterns
        // Rectangle nodes: A1[label] or A1_retry[label]
        if let match = trimmed.range(of: #"([A-Za-z0-9_]+)\[([^\]]+)\]"#, options: .regularExpression) {
            let matchString = String(trimmed[match])
            if let bracketIndex = matchString.firstIndex(of: "[") {
                let id = String(matchString[..<bracketIndex])
                let labelPart = String(matchString[matchString.index(after: bracketIndex)...])
                let label = labelPart.replacingOccurrences(of: "]", with: "")
                return (id, label, .rectangle)
            }
        }
        
        // Round rectangle nodes: A1(label)
        if let match = trimmed.range(of: #"([A-Za-z0-9_]+)\(([^\)]+)\)"#, options: .regularExpression) {
            let matchString = String(trimmed[match])
            if let parenIndex = matchString.firstIndex(of: "(") {
                let id = String(matchString[..<parenIndex])
                let labelPart = String(matchString[matchString.index(after: parenIndex)...])
                let label = labelPart.replacingOccurrences(of: ")", with: "")
                return (id, label, .roundedRectangle)
            }
        }
        
        // Diamond nodes: A1{label}
        if let match = trimmed.range(of: #"([A-Za-z0-9_]+)\{([^\}]+)\}"#, options: .regularExpression) {
            let matchString = String(trimmed[match])
            if let braceIndex = matchString.firstIndex(of: "{") {
                let id = String(matchString[..<braceIndex])
                let labelPart = String(matchString[matchString.index(after: braceIndex)...])
                let label = labelPart.replacingOccurrences(of: "}", with: "")
                return (id, label, .diamond)
            }
        }
        
        // Default case - just an ID
        return (trimmed, trimmed, .rectangle)
    }
    
    private func extractNodeInfoWithEdgeLabel(_ nodeString: String) -> (id: String, label: String, shape: NodeShape, edgeLabel: String) {
        var workingString = nodeString.trimmingCharacters(in: .whitespaces)
        var edgeLabel = ""
        
        // Check for edge label in format |label|
        if let labelMatch = workingString.range(of: #"\|([^\|]+)\|"#, options: .regularExpression) {
            let labelString = String(workingString[labelMatch])
            edgeLabel = labelString.replacingOccurrences(of: "|", with: "")
            workingString = workingString.replacingOccurrences(of: labelString, with: "").trimmingCharacters(in: .whitespaces)
        }
        
        let (id, label, shape) = extractNodeInfo(workingString)
        return (id, label, shape, edgeLabel)
    }
    
    private func parseSequenceDiagram(_ text: String) -> MermaidDiagram {
        var participants: [String] = []
        var messages: [SequenceMessage] = []
        var notes: [SequenceNote] = []
        var activations: [SequenceActivation] = []
        var loops: [SequenceLoop] = []
        
        let lines = text.components(separatedBy: .newlines)
        var currentLoop: SequenceLoop?
//        var skipUntilEnd = false
        var nestingLevel = 0
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines and diagram declaration
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("sequenceDiagram") {
                continue
            }
            
            // Handle nested structures (box, alt, opt, loop, etc.)
            if trimmedLine.hasPrefix("box ") || trimmedLine.hasPrefix("alt ") || 
               trimmedLine.hasPrefix("opt ") || trimmedLine.hasPrefix("else") ||
               trimmedLine.hasPrefix("par ") || trimmedLine.hasPrefix("and ") {
                nestingLevel += 1
                if trimmedLine.hasPrefix("box ") {
                    // Extract participants from box declaration
                    // box Backend Services
                    continue
                }
                continue
            }
            
            if trimmedLine == "end" {
                if nestingLevel > 0 {
                    nestingLevel -= 1
                    if currentLoop != nil && nestingLevel == 0 {
                        currentLoop!.endIndex = index
                        loops.append(currentLoop!)
                        currentLoop = nil
                    }
                }
                continue
            }
            
            // Parse participant declarations with alias support
            if trimmedLine.hasPrefix("participant ") || trimmedLine.hasPrefix("actor ") {
                parseParticipantDeclaration(trimmedLine, participants: &participants)
                continue
            }
            
            // Parse notes
            if trimmedLine.lowercased().hasPrefix("note ") {
                parseSequenceNote(trimmedLine, notes: &notes, participants: &participants)
                continue
            }
            
            // Parse activation/deactivation
            if trimmedLine.hasPrefix("activate ") || trimmedLine.hasPrefix("deactivate ") {
                parseActivation(trimmedLine, activations: &activations, participants: &participants)
                continue
            }
            
            // Parse loop constructs
            if trimmedLine.hasPrefix("loop ") {
                let loopText = String(trimmedLine.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                currentLoop = SequenceLoop(text: loopText, startIndex: index, endIndex: -1, messages: [])
                nestingLevel += 1
                continue
            }
            
            // Parse messages (arrows)
            if let message = parseSequenceMessage(trimmedLine, participants: &participants) {
                messages.append(message)
                
                // Add to current loop if we're inside one
                if currentLoop != nil {
                    currentLoop!.messages.append(message)
                }
            }
        }
        
        // Create parsed data dictionary
        let parsedData: [String: Any] = [
            "participants": participants,
            "messages": messages,
            "notes": notes,
            "activations": activations,
            "loops": loops
        ]
        
        return MermaidDiagram(type: .sequenceDiagram, rawText: text, parsedData: parsedData)
    }
    
    private func parseParticipantDeclaration(_ line: String, participants: inout [String]) {
        // Handle both "participant A" and "participant A as Description"
        let components = line.components(separatedBy: " ")
        if components.count >= 2 {
            var participant = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            
            // Handle alias: "participant AuthService as 认证服务"
            if components.count > 3 && components[2].lowercased() == "as" {
                // Use the alias part as display name, but keep the original as identifier
//                _ = components[3...].joined(separator: " ").trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                participant = components[1] // Keep original identifier for message parsing
            }
            
            if !participants.contains(participant) {
                participants.append(participant)
            }
        }
    }
    
    private func parseSequenceMessage(_ line: String, participants: inout [String]) -> SequenceMessage? {
        let arrowPatterns = [
            ("-->>", SequenceMessageType.asyncResponse),
            ("-->", SequenceMessageType.syncResponse),
            ("--x", SequenceMessageType.lost),
            ("->>", SequenceMessageType.asyncRequest),
            ("->", SequenceMessageType.syncRequest),
            ("-x", SequenceMessageType.lost)
        ]
        
        for (arrow, messageType) in arrowPatterns {
            if line.contains(arrow) {
                let parts = line.components(separatedBy: arrow)
                if parts.count >= 2 {
                    let from = parts[0].trimmingCharacters(in: .whitespaces)
                    let toPart = parts[1].trimmingCharacters(in: .whitespaces)
                    
                    // Extract message text if present (after colon)
                    let toComponents = toPart.components(separatedBy: ":")
                    let to = toComponents[0].trimmingCharacters(in: .whitespaces)
                    let messageText = toComponents.count > 1 ? toComponents[1].trimmingCharacters(in: .whitespaces) : ""
                    
                    // Add participants if not already present
                    if !participants.contains(from) {
                        participants.append(from)
                    }
                    if !participants.contains(to) {
                        participants.append(to)
                    }
                    
                    return SequenceMessage(
                        from: from,
                        to: to,
                        text: messageText,
                        type: messageType
                    )
                }
            }
        }
        
        return nil
    }
    
    private func parseSequenceNote(_ line: String, notes: inout [SequenceNote], participants: inout [String]) {
        // Parse note syntax: "note left of A: Note text" or "note over A,B: Note text"
        let components = line.components(separatedBy: ":")
        if components.count >= 2 {
            let noteDeclaration = components[0].trimmingCharacters(in: .whitespaces).lowercased()
            let noteText = components[1].trimmingCharacters(in: .whitespaces)
            
            if noteDeclaration.contains("left of") {
                let participant = noteDeclaration.replacingOccurrences(of: "note left of ", with: "").trimmingCharacters(in: .whitespaces)
                notes.append(SequenceNote(text: noteText, position: .leftOf(participant), participants: [participant]))
                if !participants.contains(participant) {
                    participants.append(participant)
                }
            } else if noteDeclaration.contains("right of") {
                let participant = noteDeclaration.replacingOccurrences(of: "note right of ", with: "").trimmingCharacters(in: .whitespaces)
                notes.append(SequenceNote(text: noteText, position: .rightOf(participant), participants: [participant]))
                if !participants.contains(participant) {
                    participants.append(participant)
                }
            } else if noteDeclaration.contains("over") {
                let participantsPart = noteDeclaration.replacingOccurrences(of: "note over ", with: "").trimmingCharacters(in: .whitespaces)
                let noteParticipants = participantsPart.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                notes.append(SequenceNote(text: noteText, position: .over(noteParticipants), participants: noteParticipants))
                for participant in noteParticipants {
                    if !participants.contains(participant) {
                        participants.append(participant)
                    }
                }
            }
        }
    }
    
    private func parseActivation(_ line: String, activations: inout [SequenceActivation], participants: inout [String]) {
        let components = line.components(separatedBy: " ")
        if components.count >= 2 {
            let isActivate = components[0] == "activate"
            let participant = components[1].trimmingCharacters(in: .whitespaces)
            
            if !participants.contains(participant) {
                participants.append(participant)
            }
            
            activations.append(SequenceActivation(participant: participant, isActivate: isActivate))
        }
    }
    
    private func parseClassDiagram(_ text: String) -> MermaidDiagram {
        var classes: [ClassEntity] = []
        var relationships: [ClassRelationship] = []
        var currentClass: String? = nil
        var currentAttributes: [ClassAttribute] = []
        var currentMethods: [ClassMethod] = []
        
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines, diagram declaration, direction commands, and comments
            if trimmedLine.isEmpty || 
               trimmedLine.lowercased().hasPrefix("classdiagram") ||
               trimmedLine.lowercased().hasPrefix("direction") ||
               trimmedLine.hasPrefix("%%") ||
               trimmedLine.lowercased().hasPrefix("note for") {
                continue
            }
            
            // Parse class relationships
            if let relationship = parseClassRelationship(trimmedLine) {
                relationships.append(relationship)
                continue
            }
            
            // Parse class declaration
            if trimmedLine.hasPrefix("class ") {
                // Save previous class if exists
                if let className = currentClass {
                    let classEntity = ClassEntity(
                        name: className,
                        attributes: currentAttributes,
                        methods: currentMethods
                    )
                    classes.append(classEntity)
                }
                
                // Start new class
                let classDeclaration = trimmedLine.replacingOccurrences(of: "class ", with: "")
                if let openBrace = classDeclaration.firstIndex(of: "{") {
                    currentClass = String(classDeclaration[..<openBrace]).trimmingCharacters(in: .whitespaces)
                } else {
                    currentClass = classDeclaration.trimmingCharacters(in: .whitespaces)
                }
                currentAttributes = []
                currentMethods = []
                continue
            }
            
            // Parse class members (attributes and methods)
            if let member = parseClassMember(trimmedLine) {
                if member.isMethod {
                    currentMethods.append(member.method!)
                } else {
                    currentAttributes.append(member.attribute!)
                }
                continue
            }
            
            // Parse standalone class members (outside class block)
            if let colonIndex = trimmedLine.firstIndex(of: ":") {
                let className = String(trimmedLine[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                let memberDeclaration = String(trimmedLine[trimmedLine.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                
                if let member = parseClassMember(memberDeclaration) {
                    // Find or create class
                    if let existingIndex = classes.firstIndex(where: { $0.name == className }) {
                        let existingClass = classes[existingIndex]
                        if member.isMethod {
                            let newMethods = existingClass.methods + [member.method!]
                            classes[existingIndex] = ClassEntity(
                                name: existingClass.name,
                                attributes: existingClass.attributes,
                                methods: newMethods,
                                position: existingClass.position
                            )
                        } else {
                            let newAttributes = existingClass.attributes + [member.attribute!]
                            classes[existingIndex] = ClassEntity(
                                name: existingClass.name,
                                attributes: newAttributes,
                                methods: existingClass.methods,
                                position: existingClass.position
                            )
                        }
                    } else {
                        // Create new class
                        let newClass = ClassEntity(
                            name: className,
                            attributes: member.isMethod ? [] : [member.attribute!],
                            methods: member.isMethod ? [member.method!] : []
                        )
                        classes.append(newClass)
                    }
                }
            }
        }
        
        // Save last class if exists
        if let className = currentClass {
            let classEntity = ClassEntity(
                name: className,
                attributes: currentAttributes,
                methods: currentMethods
            )
            classes.append(classEntity)
        }
        
        // Calculate positions for classes
        let positionedClasses = calculateClassPositions(classes)
        
        // Convert to nodes and edges for compatibility
        let nodes = positionedClasses.map { classEntity in
            Node(
                id: classEntity.name,
                label: classEntity.name,
                shape: .rectangle,
                position: classEntity.position
            )
        }
        
        let edges = relationships.map { relationship in
            Edge(
                from: relationship.from,
                to: relationship.to,
                label: relationship.label ?? "",
                style: EdgeStyle()
            )
        }
        
        let parsedData: [String: Any] = [
            "classes": positionedClasses,
            "relationships": relationships
        ]
        
        return MermaidDiagram(
            type: .classDiagram,
            nodes: nodes,
            edges: edges,
            rawText: text,
            parsedData: parsedData
        )
    }
    
    private func parseClassRelationship(_ line: String) -> ClassRelationship? {
        // Parse inheritance: Animal <|-- Duck
        if line.contains("<|--") {
            let parts = line.components(separatedBy: "<|--")
            if parts.count == 2 {
                let to = parts[0].trimmingCharacters(in: .whitespaces)
                let from = parts[1].trimmingCharacters(in: .whitespaces)
                return ClassRelationship(from: from, to: to, type: .inheritance)
            }
        }
        
        // Parse composition: Class1 *-- Class2
        if line.contains("*--") {
            let parts = line.components(separatedBy: "*--")
            if parts.count == 2 {
                let from = parts[0].trimmingCharacters(in: .whitespaces)
                let to = parts[1].trimmingCharacters(in: .whitespaces)
                return ClassRelationship(from: from, to: to, type: .composition)
            }
        }
        
        // Parse aggregation: Class1 o-- Class2
        if line.contains("o--") {
            let parts = line.components(separatedBy: "o--")
            if parts.count == 2 {
                let from = parts[0].trimmingCharacters(in: .whitespaces)
                let to = parts[1].trimmingCharacters(in: .whitespaces)
                return ClassRelationship(from: from, to: to, type: .aggregation)
            }
        }
        
        // Parse association: Class1 --> Class2
        if line.contains("-->") && !line.contains("<|--") {
            let parts = line.components(separatedBy: "-->")
            if parts.count == 2 {
                let from = parts[0].trimmingCharacters(in: .whitespaces)
                let to = parts[1].trimmingCharacters(in: .whitespaces)
                return ClassRelationship(from: from, to: to, type: .association)
            }
        }
        
        // Parse dependency: Class1 ..> Class2
        if line.contains("..") && line.contains(">") {
            let parts = line.components(separatedBy: "..>")
            if parts.count == 2 {
                let from = parts[0].trimmingCharacters(in: .whitespaces)
                let to = parts[1].trimmingCharacters(in: .whitespaces)
                return ClassRelationship(from: from, to: to, type: .dependency)
            }
        }
        
        return nil
    }
    
    private func parseClassMember(_ line: String) -> (isMethod: Bool, attribute: ClassAttribute?, method: ClassMethod?)? {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        
        // Skip empty lines and braces
        if trimmedLine.isEmpty || trimmedLine == "{" || trimmedLine == "}" {
            return nil
        }
        
        // Parse visibility
        var visibility: ClassVisibility = .public_
        var memberLine = trimmedLine
        
        if let firstChar = trimmedLine.first {
            switch firstChar {
            case "+":
                visibility = .public_
                memberLine = String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
            case "-":
                visibility = .private_
                memberLine = String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
            case "#":
                visibility = .protected
                memberLine = String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
            case "~":
                visibility = .package
                memberLine = String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
            default:
                break
            }
        }
        
        // Check if it's a method (contains parentheses)
        if memberLine.contains("(") && memberLine.contains(")") {
            // Parse method
            if let openParen = memberLine.firstIndex(of: "("),
               let closeParen = memberLine.lastIndex(of: ")") {
                let methodName = String(memberLine[..<openParen]).trimmingCharacters(in: .whitespaces)
                let parametersString = String(memberLine[memberLine.index(after: openParen)..<closeParen])
                
                let parameters = parametersString.isEmpty ? [] : 
                    parametersString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                
                let method = ClassMethod(
                    name: methodName,
                    returnType: nil,
                    parameters: parameters,
                    visibility: visibility
                )
                
                return (isMethod: true, attribute: nil, method: method)
            }
        } else {
            // Parse attribute
            let components = memberLine.components(separatedBy: " ")
            if components.count >= 2 {
                let type = components[0]
                let name = components[1]
                
                let attribute = ClassAttribute(
                    name: name,
                    type: type,
                    visibility: visibility
                )
                
                return (isMethod: false, attribute: attribute, method: nil)
            } else if components.count == 1 {
                // Simple attribute without type
                let attribute = ClassAttribute(
                    name: components[0],
                    type: "String",
                    visibility: visibility
                )
                
                return (isMethod: false, attribute: attribute, method: nil)
            }
        }
        
        return nil
    }
    
    private func calculateClassPositions(_ classes: [ClassEntity]) -> [ClassEntity] {
        let classesPerRow = 3
        let horizontalSpacing: CGFloat = 80
        let verticalSpacing: CGFloat = 80
        let padding: CGFloat = 100
        
        var positionedClasses: [ClassEntity] = []
        var maxClassWidths: [CGFloat] = []
        var rowHeights: [CGFloat] = []
        
        // 首先计算每个类的实际尺寸
         for (index, classEntity) in classes.enumerated() {
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
             
             // 计算类的宽度
             let classWidth = ([nameWidth] + attributeWidths + methodWidths).max() ?? 120
             maxClassWidths.append(classWidth + 16)
             
             // 计算类的高度
             let headerHeight: CGFloat = 30
             let attributesHeight = classEntity.attributes.isEmpty ? 0 : CGFloat(classEntity.attributes.count) * 20 + 8
             let methodsHeight = classEntity.methods.isEmpty ? 0 : CGFloat(classEntity.methods.count) * 20 + 8
             let separatorHeight: CGFloat = (classEntity.attributes.isEmpty ? 0 : 1) + (classEntity.methods.isEmpty ? 0 : 1)
             
             let classHeight = headerHeight + attributesHeight + methodsHeight + separatorHeight
             
             let row = index / classesPerRow
             if row >= rowHeights.count {
                 rowHeights.append(classHeight)
             } else {
                 rowHeights[row] = max(rowHeights[row], classHeight)
             }
         }
        
        // 计算每行的最大宽度
        var rowMaxWidths: [CGFloat] = []
        let totalRows = Int(ceil(Double(classes.count) / Double(classesPerRow)))
        
        for row in 0..<totalRows {
            var rowMaxWidth: CGFloat = 0
            let startIndex = row * classesPerRow
            let endIndex = min(startIndex + classesPerRow, classes.count)
            
            for i in startIndex..<endIndex {
                rowMaxWidth = max(rowMaxWidth, maxClassWidths[i])
            }
            rowMaxWidths.append(rowMaxWidth)
        }
        
        // 现在根据实际尺寸定位类
        let currentY = padding
        
        for (index, classEntity) in classes.enumerated() {
            let row = index / classesPerRow
            let col = index % classesPerRow
            
            // 计算X位置 - 在行内居中分布
//            let classesInThisRow = min(classesPerRow, classes.count - row * classesPerRow)
//            let totalRowWidth = CGFloat(classesInThisRow) * rowMaxWidths[row] + CGFloat(classesInThisRow - 1) * horizontalSpacing
            let startX = padding
            let x = startX + CGFloat(col) * (rowMaxWidths[row] + horizontalSpacing) + rowMaxWidths[row] / 2
            
            // 计算Y位置
            let y: CGFloat
            if row == 0 {
                y = currentY + rowHeights[row] / 2
            } else {
                y = rowHeights[0..<row].reduce(padding) { sum, height in
                    sum + height + verticalSpacing
                } + rowHeights[row] / 2
            }
            
            let positionedClass = ClassEntity(
                name: classEntity.name,
                attributes: classEntity.attributes,
                methods: classEntity.methods,
                position: CGPoint(x: x, y: y)
            )
            
            positionedClasses.append(positionedClass)
        }
        
        return positionedClasses
    }
    
    private func parseStateDiagram(_ text: String) -> MermaidDiagram {
        var states: [String: StateEntity] = [:]
        var transitions: [StateTransition] = []
        
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines and diagram declaration
            if trimmedLine.isEmpty || 
               trimmedLine.lowercased().hasPrefix("statediagram") ||
               trimmedLine.lowercased().hasPrefix("---") ||
               trimmedLine.lowercased().hasPrefix("title:") {
                continue
            }
            
            // Parse state definitions and transitions
            if trimmedLine.contains("-->") {
                // Parse transition: from --> to or from --> to : label
                parseStateTransition(trimmedLine, states: &states, transitions: &transitions)
            } else if trimmedLine.contains(":") && !trimmedLine.contains("-->") {
                // Parse state with description: stateId : description
                parseStateDescription(trimmedLine, states: &states)
            } else if trimmedLine.hasPrefix("state ") {
                // Parse state declaration: state "description" as stateId
                parseStateDeclaration(trimmedLine, states: &states)
            } else if !trimmedLine.contains("-->") && !trimmedLine.contains(":") {
                // Simple state id
                let stateId = trimmedLine.trimmingCharacters(in: .whitespaces)
                if !stateId.isEmpty && stateId != "[*]" {
                    if states[stateId] == nil {
                        states[stateId] = StateEntity(id: stateId)
                    }
                }
            }
        }
        
        // Calculate positions for states
        let positionedStates = calculateStatePositions(Array(states.values))
        
        let stateDiagram = StateDiagram(states: positionedStates, transitions: transitions)
        
        let parsedData: [String: Any] = [
            "stateDiagram": stateDiagram
        ]
        
        return MermaidDiagram(type: .stateDiagram, rawText: text, parsedData: parsedData)
    }
    
    private func parseStateTransition(_ line: String, states: inout [String: StateEntity], transitions: inout [StateTransition]) {
        let parts = line.components(separatedBy: "-->")
        if parts.count >= 2 {
            let fromPart = parts[0].trimmingCharacters(in: .whitespaces)
            let toPart = parts[1].trimmingCharacters(in: .whitespaces)
            
            // Check if there's a label after colon
            var toState = toPart
            var label: String? = nil
            
            if toPart.contains(":") {
                let toComponents = toPart.components(separatedBy: ":")
                if toComponents.count >= 2 {
                    toState = toComponents[0].trimmingCharacters(in: .whitespaces)
                    label = toComponents[1].trimmingCharacters(in: .whitespaces)
                }
            }
            
            // Handle start and end states
            let fromStateId: String
            let toStateId: String
            
            if fromPart == "[*]" {
                fromStateId = "[*]"
                // Mark the target state as having a start transition
                if states[toState] == nil {
                    states[toState] = StateEntity(id: toState)
                }
            } else {
                fromStateId = fromPart
                if states[fromStateId] == nil {
                    states[fromStateId] = StateEntity(id: fromStateId)
                }
            }
            
            if toState == "[*]" {
                toStateId = "[*]"
                // Mark the source state as having an end transition
                if let existingState = states[fromStateId] {
                    states[fromStateId] = StateEntity(
                        id: existingState.id,
                        description: existingState.description,
                        isStart: existingState.isStart,
                        isEnd: true,
                        position: existingState.position
                    )
                }
            } else {
                toStateId = toState
                if states[toStateId] == nil {
                    states[toStateId] = StateEntity(id: toStateId)
                }
            }
            
            let transition = StateTransition(from: fromStateId, to: toStateId, label: label)
            transitions.append(transition)
        }
    }
    
    private func parseStateDescription(_ line: String, states: inout [String: StateEntity]) {
        let parts = line.components(separatedBy: ":")
        if parts.count >= 2 {
            let stateId = parts[0].trimmingCharacters(in: .whitespaces)
            let description = parts[1].trimmingCharacters(in: .whitespaces)
            
            if let existingState = states[stateId] {
                states[stateId] = StateEntity(
                    id: existingState.id,
                    description: description,
                    isStart: existingState.isStart,
                    isEnd: existingState.isEnd,
                    position: existingState.position
                )
            } else {
                states[stateId] = StateEntity(id: stateId, description: description)
            }
        }
    }
    
    private func parseStateDeclaration(_ line: String, states: inout [String: StateEntity]) {
        // Parse: state "description" as stateId
        if line.contains(" as ") {
            let parts = line.components(separatedBy: " as ")
            if parts.count >= 2 {
                let stateId = parts[1].trimmingCharacters(in: .whitespaces)
                
                // Extract description part more carefully
                var descriptionPart = parts[0].trimmingCharacters(in: .whitespaces)
                if descriptionPart.lowercased().hasPrefix("state ") {
                    descriptionPart = String(descriptionPart.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                }
                
                var description = descriptionPart
                // Remove quotes if present
                if (description.hasPrefix("\"") && description.hasSuffix("\"")) || 
                   (description.hasPrefix("'") && description.hasSuffix("'")) {
                    description = String(description.dropFirst().dropLast())
                }
                
                if let existingState = states[stateId] {
                    states[stateId] = StateEntity(
                        id: existingState.id,
                        description: description,
                        isStart: existingState.isStart,
                        isEnd: existingState.isEnd,
                        position: existingState.position
                    )
                } else {
                    states[stateId] = StateEntity(id: stateId, description: description)
                }
            }
        }
    }
    
    private func calculateStatePositions(_ states: [StateEntity]) -> [StateEntity] {
        let statesPerRow = 4
        let horizontalSpacing: CGFloat = 120
        let verticalSpacing: CGFloat = 80
        let padding: CGFloat = 60
        
        var positionedStates: [StateEntity] = []
        
        // Separate start states, regular states, and end states
        let startStates = states.filter { $0.isStart || hasIncomingFromStart(stateId: $0.id, states: states) }
        let endStates = states.filter { $0.isEnd || hasOutgoingToEnd(stateId: $0.id, states: states) }
        let regularStates = states.filter { state in
            !startStates.contains { $0.id == state.id } && !endStates.contains { $0.id == state.id }
        }
        
        let currentY = padding
        let allStates = startStates + regularStates + endStates
        
        for (index, state) in allStates.enumerated() {
            let row = index / statesPerRow
            let col = index % statesPerRow
            
            let x = padding + CGFloat(col) * horizontalSpacing
            let y = currentY + CGFloat(row) * verticalSpacing
            
            let positionedState = StateEntity(
                id: state.id,
                description: state.description,
                isStart: state.isStart,
                isEnd: state.isEnd,
                position: CGPoint(x: x, y: y)
            )
            
            positionedStates.append(positionedState)
        }
        
        return positionedStates
    }
    
    private func hasIncomingFromStart(stateId: String, states: [StateEntity]) -> Bool {
        // This would need access to transitions, simplified for now
        return false
    }
    
    private func hasOutgoingToEnd(stateId: String, states: [StateEntity]) -> Bool {
        // This would need access to transitions, simplified for now
        return false
    }
    
    private func parseGantt(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .gantt, rawText: text)
    }
    
    private func parsePieChart(_ text: String) -> MermaidDiagram {
        var title = ""
        var data: [String: Double] = [:]
        
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines
            if trimmedLine.isEmpty {
                continue
            }
            
            // Parse title
            if trimmedLine.lowercased().hasPrefix("pie title ") {
                title = String(trimmedLine.dropFirst(10)).trimmingCharacters(in: .whitespaces)
                // Remove quotes if present
                if (title.hasPrefix("\"") && title.hasSuffix("\"")) || (title.hasPrefix("'") && title.hasSuffix("'")) {
                    title = String(title.dropFirst().dropLast())
                }
                continue
            }
            
            // Parse pie declaration
            if trimmedLine.lowercased() == "pie" {
                continue
            }
            
            // Parse data lines: "Label" : value
            if trimmedLine.contains(":") {
                let parts = trimmedLine.components(separatedBy: ":")
                if parts.count >= 2 {
                    var label = parts[0].trimmingCharacters(in: .whitespaces)
                    let valueString = parts[1].trimmingCharacters(in: .whitespaces)
                    
                    // Remove quotes from label
                    if (label.hasPrefix("\"") && label.hasSuffix("\"")) || (label.hasPrefix("'") && label.hasSuffix("'")) {
                        label = String(label.dropFirst().dropLast())
                    }
                    
                    if let value = Double(valueString) {
                        data[label] = value
                    }
                }
            }
        }
        
        let parsedData: [String: Any] = [
            "title": title,
            "data": data
        ]
        
        return MermaidDiagram(type: .pie, rawText: text, parsedData: parsedData)
    }
    
    private func parseGitGraph(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .gitGraph, rawText: text)
    }
    
    private func parseERDiagram(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .erDiagram, rawText: text)
    }
    
    private func parseUserJourney(_ text: String) -> MermaidDiagram {
        // Simplified implementation
        return MermaidDiagram(type: .userJourney, rawText: text)
    }
}

// Add SwiftUI Color extension for convenience
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
