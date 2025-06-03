import XCTest
@testable import SwiftMermind

final class SwiftMermindTests: XCTestCase {
    func testMermaidParser() throws {
        let parser = MermaidParser()
        
        // Test flowchart parsing
        let flowchartText = "graph TD\nA[Start] --> B{Is it?}\nB -->|Yes| C[OK]\nB -->|No| D[End]"
        let flowchartDiagram = parser.parse(flowchartText)
        XCTAssertEqual(flowchartDiagram.type, .flowchart)
        XCTAssertEqual(flowchartDiagram.rawText, flowchartText)
        
        // Test sequence diagram parsing
        let sequenceText = "sequenceDiagram\nAlice->>Bob: Hello Bob, how are you?\nBob-->>Alice: Great!"
        let sequenceDiagram = parser.parse(sequenceText)
        XCTAssertEqual(sequenceDiagram.type, .sequenceDiagram)
        XCTAssertEqual(sequenceDiagram.rawText, sequenceText)
        
        // Test pie chart parsing
        let pieText = "pie title Pets\n\"Dogs\" : 386\n\"Cats\" : 85"
        let pieDiagram = parser.parse(pieText)
        XCTAssertEqual(pieDiagram.type, .pie)
        XCTAssertEqual(pieDiagram.rawText, pieText)
        
        // Test unknown diagram type
        let unknownText = "unknown diagram type"
        let unknownDiagram = parser.parse(unknownText)
        XCTAssertEqual(unknownDiagram.type, .unknown)
        XCTAssertEqual(unknownDiagram.rawText, unknownText)
    }
    
    func testDiagramTypeDetection() throws {
        let parser = MermaidParser()
        
        // Test different flowchart syntaxes
        XCTAssertEqual(parser.parse("graph TD").type, .flowchart)
        XCTAssertEqual(parser.parse("graph LR").type, .flowchart)
        XCTAssertEqual(parser.parse("flowchart TD").type, .flowchart)
        
        // Test other diagram types
        XCTAssertEqual(parser.parse("sequenceDiagram").type, .sequenceDiagram)
        XCTAssertEqual(parser.parse("classDiagram").type, .classDiagram)
        XCTAssertEqual(parser.parse("stateDiagram").type, .stateDiagram)
        XCTAssertEqual(parser.parse("gantt").type, .gantt)
        XCTAssertEqual(parser.parse("pie").type, .pie)
        XCTAssertEqual(parser.parse("gitGraph").type, .gitGraph)
        XCTAssertEqual(parser.parse("erDiagram").type, .erDiagram)
        XCTAssertEqual(parser.parse("journey").type, .userJourney)
    }
    
    func testFlowchartParsing() throws {
        let parser = MermaidParser()
        
        let flowchartText = """
        graph TD
            A[Start] --> B{Decision}
            B -->|Yes| C[Process]
            B -->|No| D[End]
        """
        
        let diagram = parser.parse(flowchartText)
        XCTAssertEqual(diagram.type, .flowchart)
        
        // Check that nodes were parsed
        XCTAssertTrue(diagram.nodes.contains { $0.id == "A" && $0.label == "Start" })
        XCTAssertTrue(diagram.nodes.contains { $0.id == "B" && $0.label == "Decision" })
        XCTAssertTrue(diagram.nodes.contains { $0.id == "C" && $0.label == "Process" })
        XCTAssertTrue(diagram.nodes.contains { $0.id == "D" && $0.label == "End" })
        
        // Check that edges were parsed
        XCTAssertTrue(diagram.edges.contains { $0.from == "A" && $0.to == "B" })
        XCTAssertTrue(diagram.edges.contains { $0.from == "B" && $0.to == "C" && $0.label == "Yes" })
        XCTAssertTrue(diagram.edges.contains { $0.from == "B" && $0.to == "D" && $0.label == "No" })
    }
}