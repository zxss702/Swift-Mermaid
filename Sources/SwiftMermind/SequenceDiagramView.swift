import SwiftUI

/// A view that renders a sequence diagram
public struct SequenceDiagramView: View {
    private let diagram: MermaidDiagram
    private let size: CGSize
    private let actorSpacing: CGFloat = 150
    private let messageSpacing: CGFloat = 60
    private let actorTopMargin: CGFloat = 40
    
    public init(diagram: MermaidDiagram, size: CGSize) {
        self.diagram = diagram
        self.size = size
    }
    
    public var body: some View {
        let actors = extractActors()
        let messages = extractMessages()
        
        return ZStack {
            // Draw lifelines
            ForEach(0..<actors.count, id: \.self) { index in
                let x = calculateActorX(index: index, count: actors.count)
                
                // Lifeline
                Path { path in
                    path.move(to: CGPoint(x: x, y: actorTopMargin + 40))
                    path.addLine(to: CGPoint(x: x, y: size.height - 20))
                }
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                
                // Actor
                VStack {
                    Text(actors[index])
                        .font(.system(size: 14))
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 4).stroke(Color.black, lineWidth: 1).background(Color.white))
                    
                    Spacer()
                    
                    Text(actors[index])
                        .font(.system(size: 14))
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 4).stroke(Color.black, lineWidth: 1).background(Color.white))
                }
                .frame(height: size.height - 40)
                .position(x: x, y: size.height / 2)
            }
            
            // Draw messages
            ForEach(0..<messages.count, id: \.self) { index in
                let message = messages[index]
                let fromIndex = actors.firstIndex(of: message.from) ?? 0
                let toIndex = actors.firstIndex(of: message.to) ?? 0
                let fromX = calculateActorX(index: fromIndex, count: actors.count)
                let toX = calculateActorX(index: toIndex, count: actors.count)
                let y = actorTopMargin + 80 + CGFloat(index) * messageSpacing
                
                // Message line
                Path { path in
                    path.move(to: CGPoint(x: fromX, y: y))
                    path.addLine(to: CGPoint(x: toX, y: y))
                }
                .stroke(Color.black, lineWidth: 1)
                
                // Arrow
                if fromX < toX {
                    ArrowShape(start: CGPoint(x: fromX, y: y), end: CGPoint(x: toX, y: y))
                        .fill(Color.black)
                        .frame(width: 10, height: 10)
                        .position(x: toX - 5, y: y)
                } else {
                    ArrowShape(start: CGPoint(x: fromX, y: y), end: CGPoint(x: toX, y: y))
                        .fill(Color.black)
                        .frame(width: 10, height: 10)
                        .position(x: toX + 5, y: y)
                }
                
                // Message text
                Text(message.text)
                    .font(.system(size: 12))
                    .position(x: (fromX + toX) / 2, y: y - 15)
                    .background(Color.white.opacity(0.8))
                    .padding(2)
            }
        }
        .frame(width: size.width, height: size.height)
    }
    
    private func calculateActorX(index: Int, count: Int) -> CGFloat {
        if count <= 1 {
            return size.width / 2
        }
        
        let availableWidth = size.width - 80 // Padding on both sides
        let step = min(availableWidth / CGFloat(count - 1), actorSpacing)
        let totalWidth = step * CGFloat(count - 1)
        let leftMargin = (size.width - totalWidth) / 2
        
        return leftMargin + CGFloat(index) * step
    }
    
    private struct SequenceMessage {
        let from: String
        let to: String
        let text: String
        let type: MessageType
        
        enum MessageType {
            case solid
            case dashed
            case note
            case activation
            case deactivation
        }
    }
    
    private func extractActors() -> [String] {
        // In a real implementation, you would parse the actors from the diagram text
        // This is a simplified implementation for demonstration
        
        // Look for participant or actor definitions
        let lines = diagram.rawText.components(separatedBy: .newlines)
        var actors = [String]()
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("participant") || trimmedLine.hasPrefix("actor") {
                let components = trimmedLine.components(separatedBy: .whitespaces)
                if components.count >= 2 {
                    let actor = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                    actors.append(actor)
                }
            }
        }
        
        // If no actors were explicitly defined, extract them from message lines
        if actors.isEmpty {
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespaces)
                
                // Look for lines with arrows (->)
                if trimmedLine.contains("->") || trimmedLine.contains("->>")
                    || trimmedLine.contains("-->") || trimmedLine.contains("-->>") {
                    
                    let parts = trimmedLine.components(separatedBy: CharacterSet(charactersIn: "->:"))
                    if parts.count >= 2 {
                        let from = parts[0].trimmingCharacters(in: .whitespaces)
                        let to = parts[1].trimmingCharacters(in: .whitespaces)
                        
                        if !from.isEmpty && !actors.contains(from) {
                            actors.append(from)
                        }
                        
                        if !to.isEmpty && !actors.contains(to) {
                            actors.append(to)
                        }
                    }
                }
            }
        }
        
        // If still no actors found, create a default one
        if actors.isEmpty {
            actors = ["Participant"]
        }
        
        return actors
    }
    
    private func extractMessages() -> [SequenceMessage] {
        // In a real implementation, you would parse the messages from the diagram text
        // This is a simplified implementation for demonstration
        
        let lines = diagram.rawText.components(separatedBy: .newlines)
        var messages = [SequenceMessage]()
        let actors = extractActors()
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip lines that define participants or are empty
            if trimmedLine.hasPrefix("participant") || trimmedLine.hasPrefix("actor") || trimmedLine.isEmpty {
                continue
            }
            
            // Look for lines with arrows (->)
            if trimmedLine.contains("->") || trimmedLine.contains("->>")
                || trimmedLine.contains("-->") || trimmedLine.contains("-->>") {
                
                var arrowType: SequenceMessage.MessageType = .solid
                if trimmedLine.contains("-->") || trimmedLine.contains("-->>") {
                    arrowType = .dashed
                }
                
                // Split by arrow
                let arrowComponents: [String]
                if trimmedLine.contains("->") {
                    arrowComponents = trimmedLine.components(separatedBy: "->")
                } else if trimmedLine.contains("->>") {
                    arrowComponents = trimmedLine.components(separatedBy: "->")
                } else if trimmedLine.contains("-->") {
                    arrowComponents = trimmedLine.components(separatedBy: "-->")
                } else {
                    arrowComponents = trimmedLine.components(separatedBy: "-->>")
                }
                
                if arrowComponents.count >= 2 {
                    let from = arrowComponents[0].trimmingCharacters(in: .whitespaces)
                    
                    // Split the second part by colon to get the message text
                    let toParts = arrowComponents[1].components(separatedBy: ":")
                    let to = toParts[0].trimmingCharacters(in: .whitespaces)
                    
                    var messageText = ""
                    if toParts.count >= 2 {
                        messageText = toParts[1].trimmingCharacters(in: .whitespaces)
                    }
                    
                    // Ensure from and to are valid actors
                    let validFrom = actors.contains(from) ? from : actors.first ?? "Participant"
                    let validTo = actors.contains(to) ? to : actors.last ?? "Participant"
                    
                    messages.append(SequenceMessage(from: validFrom, to: validTo, text: messageText, type: arrowType))
                }
            }
        }
        
        // If no messages were found, create a default one
        if messages.isEmpty && actors.count >= 2 {
            messages = [SequenceMessage(from: actors[0], to: actors[1], text: "Message", type: .solid)]
        } else if messages.isEmpty {
            messages = [SequenceMessage(from: actors[0], to: actors[0], text: "Message", type: .solid)]
        }
        
        return messages
    }
}