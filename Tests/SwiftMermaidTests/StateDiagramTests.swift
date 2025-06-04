import XCTest
@testable import SwiftMermaid

final class StateDiagramTests: XCTestCase {
    
    func testBasicStateDiagram() {
        let mermaidText = """
        stateDiagram-v2
            [*] --> Still
            Still --> [*]
            Still --> Moving
            Moving --> Still
            Moving --> Crash
            Crash --> [*]
        """
        
        let parser = MermaidParser()
        let diagram = parser.parse(mermaidText)
        
        XCTAssertEqual(diagram.type, .stateDiagram)
        
        guard let stateDiagramData = diagram.parsedData["stateDiagram"] as? StateDiagram else {
            XCTFail("Failed to parse state diagram data")
            return
        }
        
        // Check states
        XCTAssertEqual(stateDiagramData.states.count, 3) // Still, Moving, Crash
        
        let stateIds = Set(stateDiagramData.states.map { $0.id })
        XCTAssertTrue(stateIds.contains("Still"))
        XCTAssertTrue(stateIds.contains("Moving"))
        XCTAssertTrue(stateIds.contains("Crash"))
        
        // Check transitions
        XCTAssertEqual(stateDiagramData.transitions.count, 6)
        
        let transitionPairs = stateDiagramData.transitions.map { "\($0.from) -> \($0.to)" }
        XCTAssertTrue(transitionPairs.contains("[*] -> Still"))
        XCTAssertTrue(transitionPairs.contains("Still -> [*]"))
        XCTAssertTrue(transitionPairs.contains("Still -> Moving"))
        XCTAssertTrue(transitionPairs.contains("Moving -> Still"))
        XCTAssertTrue(transitionPairs.contains("Moving -> Crash"))
        XCTAssertTrue(transitionPairs.contains("Crash -> [*]"))
    }
    
    func testStateWithDescription() {
        let mermaidText = """
        stateDiagram-v2
            s1 : This is a state description
            [*] --> s1
            s1 --> [*]
        """
        
        let parser = MermaidParser()
        let diagram = parser.parse(mermaidText)
        
        guard let stateDiagramData = diagram.parsedData["stateDiagram"] as? StateDiagram else {
            XCTFail("Failed to parse state diagram data")
            return
        }
        
        let s1State = stateDiagramData.states.first { $0.id == "s1" }
        XCTAssertNotNil(s1State)
        XCTAssertEqual(s1State?.description, "This is a state description")
    }
    
    func testStateDeclaration() {
        let mermaidText = """
        stateDiagram-v2
            state "This is a state description" as s2
            [*] --> s2
            s2 --> [*]
        """
        
        let parser = MermaidParser()
        let diagram = parser.parse(mermaidText)
        
        guard let stateDiagramData = diagram.parsedData["stateDiagram"] as? StateDiagram else {
            XCTFail("Failed to parse state diagram data")
            return
        }
        
        let s2State = stateDiagramData.states.first { $0.id == "s2" }
        XCTAssertNotNil(s2State)
        XCTAssertEqual(s2State?.description, "This is a state description")
    }
    
    func testTransitionWithLabel() {
        let mermaidText = """
        stateDiagram-v2
            s1 --> s2: A transition
        """
        
        let parser = MermaidParser()
        let diagram = parser.parse(mermaidText)
        
        guard let stateDiagramData = diagram.parsedData["stateDiagram"] as? StateDiagram else {
            XCTFail("Failed to parse state diagram data")
            return
        }
        
        XCTAssertEqual(stateDiagramData.transitions.count, 1)
        let transition = stateDiagramData.transitions.first!
        XCTAssertEqual(transition.from, "s1")
        XCTAssertEqual(transition.to, "s2")
        XCTAssertEqual(transition.label, "A transition")
    }
    
    func testComplexStateDiagram() {
        let mermaidText = """
        stateDiagram-v2
            [*] --> Still
            Still --> [*]
            Still --> Moving
            Moving --> Still
            Moving --> Crash
            Crash --> [*]
            
            Still : The car is still
            Moving : The car is moving
            Crash : The car has crashed
        """
        
        let parser = MermaidParser()
        let diagram = parser.parse(mermaidText)
        
        guard let stateDiagramData = diagram.parsedData["stateDiagram"] as? StateDiagram else {
            XCTFail("Failed to parse state diagram data")
            return
        }
        
        // Check that states have descriptions
        let stillState = stateDiagramData.states.first { $0.id == "Still" }
        let movingState = stateDiagramData.states.first { $0.id == "Moving" }
        let crashState = stateDiagramData.states.first { $0.id == "Crash" }
        
        XCTAssertEqual(stillState?.description, "The car is still")
        XCTAssertEqual(movingState?.description, "The car is moving")
        XCTAssertEqual(crashState?.description, "The car has crashed")
    }
}