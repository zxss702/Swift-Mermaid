import SwiftUI

/// The main entry point for the SwiftMermind library
/// This file provides public access to the mermindView component

// Re-export the main view for easier access
public typealias MermindView = mermindView

/// Example usage and documentation
public struct SwiftMermindExamples {
    
    /// Example flowchart diagram
    public static let flowchartExample = """
    graph TD
        A[Start] --> B{Is it working?}
        B -->|Yes| C[Great!]
        B -->|No| D[Debug]
        D --> B
        C --> E[End]
    """
    
    /// Example sequence diagram
    public static let sequenceExample = """
    sequenceDiagram
        participant Alice
        participant Bob
        Alice->>Bob: Hello Bob, how are you?
        Bob-->>Alice: Great!
        Alice-)Bob: See you later!
    """
    
    /// Example pie chart
    public static let pieExample = """
    pie title Pets adopted by volunteers
        "Dogs" : 386
        "Cats" : 85
        "Rats" : 15
    """
    
    /// Example class diagram
    public static let classExample = """
    classDiagram
        Animal <|-- Duck
        Animal <|-- Fish
        Animal <|-- Zebra
        Animal : +int age
        Animal : +String gender
        Animal: +isMammal()
        Animal: +mate()
        class Duck{
            +String beakColor
            +swim()
            +quack()
        }
        class Fish{
            -int sizeInFeet
            -canEat()
        }
        class Zebra{
            +bool is_wild
            +run()
        }
    """
}

/// Convenience initializers and utilities
extension mermindView {
    
    /// Create a mermindView with a flowchart example
    public static func flowchartExample() -> mermindView {
        return mermindView(text: SwiftMermindExamples.flowchartExample)
    }
    
    /// Create a mermindView with a sequence diagram example
    public static func sequenceExample() -> mermindView {
        return mermindView(text: SwiftMermindExamples.sequenceExample)
    }
    
    /// Create a mermindView with a pie chart example
    public static func pieExample() -> mermindView {
        return mermindView(text: SwiftMermindExamples.pieExample)
    }
    
    /// Create a mermindView with a class diagram example
    public static func classExample() -> mermindView {
        return mermindView(text: SwiftMermindExamples.classExample)
    }
}