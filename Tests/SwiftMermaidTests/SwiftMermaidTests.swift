import XCTest
@testable import SwiftMermaid

final class SwiftMermaidTests: XCTestCase {
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
    
    func testSequenceDiagramParsing() throws {
        let parser = MermaidParser()
        
        let sequenceText = """
        sequenceDiagram
            participant Alice
            participant Bob
            Alice->>Bob: Hello Bob, how are you?
            Bob-->>Alice: Great!
            Note right of Bob: Bob thinks
            activate Alice
            Alice->>Bob: Another message
            deactivate Alice
        """
        
        let diagram = parser.parse(sequenceText)
        XCTAssertEqual(diagram.type, .sequenceDiagram)
        
        // Check that participants were parsed
        if let participants = diagram.parsedData["participants"] as? [String] {
            XCTAssertTrue(participants.contains("Alice"))
            XCTAssertTrue(participants.contains("Bob"))
        } else {
            XCTFail("Participants not found in parsed data")
        }
        
        // Check that messages were parsed
        if let messages = diagram.parsedData["messages"] as? [SequenceMessage] {
            XCTAssertTrue(messages.count >= 2)
            XCTAssertTrue(messages.contains { $0.from == "Alice" && $0.to == "Bob" && $0.text == "Hello Bob, how are you?" })
            XCTAssertTrue(messages.contains { $0.from == "Bob" && $0.to == "Alice" && $0.text == "Great!" })
        } else {
            XCTFail("Messages not found in parsed data")
        }
        
        // Check that notes were parsed
        if let notes = diagram.parsedData["notes"] as? [SequenceNote] {
            XCTAssertTrue(notes.contains { $0.text == "Bob thinks" })
        } else {
            XCTFail("Notes not found in parsed data")
        }
        
        // Check that activations were parsed
        if let activations = diagram.parsedData["activations"] as? [SequenceActivation] {
            XCTAssertTrue(activations.contains { $0.participant == "Alice" && $0.isActivate })
        } else {
            XCTFail("Activations not found in parsed data")
        }
    }
    
    func testPieChartParsing() throws {
        let parser = MermaidParser()
        
        // Test basic pie chart
        let pieText1 = """
        pie title NETFLIX
            "Time spent looking for movie" : 90
            "Time spent watching it" : 10
        """
        
        let diagram1 = parser.parse(pieText1)
        XCTAssertEqual(diagram1.type, .pie)
        
        // Check title parsing
        if let title = diagram1.parsedData["title"] as? String {
            XCTAssertEqual(title, "NETFLIX")
        } else {
            XCTFail("Title not found in parsed data")
        }
        
        // Check data parsing
        if let data = diagram1.parsedData["data"] as? [String: Double] {
            XCTAssertEqual(data.count, 2)
            XCTAssertEqual(data["Time spent looking for movie"], 90.0)
            XCTAssertEqual(data["Time spent watching it"], 10.0)
        } else {
            XCTFail("Data not found in parsed data")
        }
        
        // Test pie chart with quoted title
        let pieText2 = """
        pie title "Pet Sales"
            "Dogs" : 386
            "Cats" : 85
            "Rats" : 15
        """
        
        let diagram2 = parser.parse(pieText2)
        XCTAssertEqual(diagram2.type, .pie)
        
        // Check quoted title parsing
        if let title = diagram2.parsedData["title"] as? String {
            XCTAssertEqual(title, "Pet Sales")
        } else {
            XCTFail("Quoted title not found in parsed data")
        }
        
        // Check multiple data entries
        if let data = diagram2.parsedData["data"] as? [String: Double] {
            XCTAssertEqual(data.count, 3)
            XCTAssertEqual(data["Dogs"], 386.0)
            XCTAssertEqual(data["Cats"], 85.0)
            XCTAssertEqual(data["Rats"], 15.0)
        } else {
            XCTFail("Multiple data entries not found in parsed data")
        }
        
        // Test pie chart without title
        let pieText3 = """
        pie
            "Category A" : 50
            "Category B" : 30
            "Category C" : 20
        """
        
        let diagram3 = parser.parse(pieText3)
        XCTAssertEqual(diagram3.type, .pie)
        
        // Check that data is still parsed without title
        if let data = diagram3.parsedData["data"] as? [String: Double] {
            XCTAssertEqual(data.count, 3)
            XCTAssertEqual(data["Category A"], 50.0)
            XCTAssertEqual(data["Category B"], 30.0)
            XCTAssertEqual(data["Category C"], 20.0)
        } else {
            XCTFail("Data without title not found in parsed data")
        }
    }
}