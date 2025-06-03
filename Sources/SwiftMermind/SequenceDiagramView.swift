//
//  SequenceDiagramView.swift
//  SwiftMermind
//
//  A comprehensive view that renders sequence diagrams with full Mermaid support
//  including participants, messages, notes, activations, and loops
//

import SwiftUI

/// A comprehensive view that renders sequence diagrams with full Mermaid support
public struct SequenceDiagramView: View {
    private let diagram: MermaidDiagram
    private let size: CGSize
    private let participantSpacing: CGFloat = 150
    private let messageSpacing: CGFloat = 50
    private let participantTopMargin: CGFloat = 40
    private let activationWidth: CGFloat = 10
    
    public init(diagram: MermaidDiagram, size: CGSize) {
        self.diagram = diagram
        self.size = size
    }
    
    public var body: some View {
        let participants = getParticipants()
        let messages = getMessages()
        let notes = getNotes()
        let activations = getActivations()
        let loops = getLoops()
        
        return ZStack {
            // Draw participants and lifelines
            ForEach(0..<participants.count, id: \.self) { index in
                let x = calculateParticipantX(index: index, count: participants.count)
                
                // Lifeline
                Path { path in
                    path.move(to: CGPoint(x: x, y: participantTopMargin + 50))
                    path.addLine(to: CGPoint(x: x, y: size.height - 60))
                }
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                
                // Participant boxes (top and bottom)
                VStack {
                    ParticipantBox(name: participants[index])
                    Spacer()
                    ParticipantBox(name: participants[index])
                }
                .frame(height: size.height - 80)
                .position(x: x, y: size.height / 2)
            }
            
            // Draw activation boxes
            ForEach(activations.indices, id: \.self) { index in
                let activation = activations[index]
                if let participantIndex = participants.firstIndex(of: activation.participant) {
                    let x = calculateParticipantX(index: participantIndex, count: participants.count)
                    let y = participantTopMargin + 80 + CGFloat(index) * messageSpacing
                    
                    if activation.isActivate {
                        Rectangle()
            .fill(Color.white)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 1)
            )
                            .frame(width: activationWidth, height: messageSpacing * 2)
                            .position(x: x, y: y + messageSpacing)
                    }
                }
            }
            
            // Draw messages
            ForEach(messages.indices, id: \.self) { index in
                let message = messages[index]
                MessageView(
                    message: message,
                    participants: participants,
                    index: index,
                    size: size,
                    participantSpacing: participantSpacing,
                    messageSpacing: messageSpacing,
                    participantTopMargin: participantTopMargin
                )
            }
            
            // Draw notes
            ForEach(notes.indices, id: \.self) { index in
                let note = notes[index]
                NoteView(
                    note: note,
                    participants: participants,
                    messageIndex: index,
                    size: size,
                    participantSpacing: participantSpacing,
                    messageSpacing: messageSpacing,
                    participantTopMargin: participantTopMargin
                )
            }
            
            // Draw loops
            ForEach(loops.indices, id: \.self) { index in
                let loop = loops[index]
                LoopView(
                    loop: loop,
                    participants: participants,
                    size: size,
                    participantSpacing: participantSpacing,
                    messageSpacing: messageSpacing,
                    participantTopMargin: participantTopMargin
                )
            }
        }
        .frame(width: size.width, height: size.height)
    }
    
    // MARK: - Data Extraction Methods
    
    private func getParticipants() -> [String] {
        if let participants = diagram.parsedData["participants"] as? [String] {
            return participants
        }
        return ["Participant"]
    }
    
    private func getMessages() -> [SequenceMessage] {
        if let messages = diagram.parsedData["messages"] as? [SequenceMessage] {
            return messages
        }
        return []
    }
    
    private func getNotes() -> [SequenceNote] {
        if let notes = diagram.parsedData["notes"] as? [SequenceNote] {
            return notes
        }
        return []
    }
    
    private func getActivations() -> [SequenceActivation] {
        if let activations = diagram.parsedData["activations"] as? [SequenceActivation] {
            return activations
        }
        return []
    }
    
    private func getLoops() -> [SequenceLoop] {
        if let loops = diagram.parsedData["loops"] as? [SequenceLoop] {
            return loops
        }
        return []
    }
    
    private func calculateParticipantX(index: Int, count: Int) -> CGFloat {
        if count <= 1 {
            return size.width / 2
        }
        
        let availableWidth = size.width - 100 // Padding on both sides
        let step = min(availableWidth / CGFloat(count - 1), participantSpacing)
        let totalWidth = step * CGFloat(count - 1)
        let leftMargin = (size.width - totalWidth) / 2
        
        return leftMargin + CGFloat(index) * step
    }
}

// MARK: - Supporting Views

/// A view that represents a participant box
struct ParticipantBox: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black, lineWidth: 1.5)
                    )
            )
    }
}

/// A view that renders a message between participants
struct MessageView: View {
    let message: SequenceMessage
    let participants: [String]
    let index: Int
    let size: CGSize
    let participantSpacing: CGFloat
    let messageSpacing: CGFloat
    let participantTopMargin: CGFloat
    
    var body: some View {
        let fromIndex = participants.firstIndex(of: message.from) ?? 0
        let toIndex = participants.firstIndex(of: message.to) ?? 0
        let fromX = calculateParticipantX(index: fromIndex, count: participants.count)
        let toX = calculateParticipantX(index: toIndex, count: participants.count)
        let y = participantTopMargin + 100 + CGFloat(index) * messageSpacing
        
        ZStack {
            // Message line
            MessageLine(
                from: CGPoint(x: fromX, y: y),
                to: CGPoint(x: toX, y: y),
                type: message.type
            )
            
            // Message text
            if !message.text.isEmpty {
                Text(message.text)
                    .font(.system(size: 12))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                            )
                    )
                    .position(x: (fromX + toX) / 2, y: y - 18)
            }
        }
    }
    
    private func calculateParticipantX(index: Int, count: Int) -> CGFloat {
        if count <= 1 {
            return size.width / 2
        }
        
        let availableWidth = size.width - 100
        let step = min(availableWidth / CGFloat(count - 1), participantSpacing)
        let totalWidth = step * CGFloat(count - 1)
        let leftMargin = (size.width - totalWidth) / 2
        
        return leftMargin + CGFloat(index) * step
    }
}

/// A view that renders different types of message lines
struct MessageLine: View {
    let from: CGPoint
    let to: CGPoint
    let type: SequenceMessageType
    
    var body: some View {
        ZStack {
            // Main line
            Path { path in
                path.move(to: from)
                path.addLine(to: to)
            }
            .stroke(
                Color.black,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    dash: isDashed ? [6, 3] : []
                )
            )
            
            // Arrow head
            if from.x != to.x {
                ArrowHead(from: from, to: to, type: type)
            }
        }
    }
    
    private var lineWidth: CGFloat {
        switch type {
        case .syncRequest, .asyncRequest:
            return 1.5
        case .syncResponse, .asyncResponse:
            return 1.0
        case .lost, .found:
            return 1.5
        }
    }
    
    private var isDashed: Bool {
        switch type {
        case .syncResponse, .asyncResponse:
            return true
        default:
            return false
        }
    }
}

/// A view that renders arrow heads for messages
struct ArrowHead: View {
    let from: CGPoint
    let to: CGPoint
    let type: SequenceMessageType
    
    var body: some View {
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength: CGFloat = 8
        let arrowAngle: CGFloat = .pi / 6
        
        Path { path in
            // Arrow tip
            path.move(to: to)
            
            // Left arrow line
            let leftPoint = CGPoint(
                x: to.x - arrowLength * cos(angle - arrowAngle),
                y: to.y - arrowLength * sin(angle - arrowAngle)
            )
            path.addLine(to: leftPoint)
            
            // Right arrow line
            path.move(to: to)
            let rightPoint = CGPoint(
                x: to.x - arrowLength * cos(angle + arrowAngle),
                y: to.y - arrowLength * sin(angle + arrowAngle)
            )
            path.addLine(to: rightPoint)
        }
        .stroke(Color.black, lineWidth: 1.5)
    }
}

/// A view that renders notes in sequence diagrams
struct NoteView: View {
    let note: SequenceNote
    let participants: [String]
    let messageIndex: Int
    let size: CGSize
    let participantSpacing: CGFloat
    let messageSpacing: CGFloat
    let participantTopMargin: CGFloat
    
    var body: some View {
        let (x, width) = calculateNotePosition()
        let y = participantTopMargin + 100 + CGFloat(messageIndex) * messageSpacing + 30
        
        Text(note.text)
            .font(.system(size: 11))
            .padding(8)
            .frame(width: width)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.yellow.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.orange, lineWidth: 1)
                    )
            )
            .position(x: x, y: y)
    }
    
    private func calculateNotePosition() -> (x: CGFloat, width: CGFloat) {
        switch note.position {
        case .leftOf(let participant):
            if let index = participants.firstIndex(of: participant) {
                let participantX = calculateParticipantX(index: index, count: participants.count)
                return (participantX - 60, 100)
            }
            return (size.width / 2, 100)
            
        case .rightOf(let participant):
            if let index = participants.firstIndex(of: participant) {
                let participantX = calculateParticipantX(index: index, count: participants.count)
                return (participantX + 60, 100)
            }
            return (size.width / 2, 100)
            
        case .over(let noteParticipants):
            if noteParticipants.count == 1,
               let index = participants.firstIndex(of: noteParticipants[0]) {
                let participantX = calculateParticipantX(index: index, count: participants.count)
                return (participantX, 120)
            } else if noteParticipants.count >= 2,
                      let firstIndex = participants.firstIndex(of: noteParticipants[0]),
                      let lastIndex = participants.firstIndex(of: noteParticipants.last!) {
                let firstX = calculateParticipantX(index: firstIndex, count: participants.count)
                let lastX = calculateParticipantX(index: lastIndex, count: participants.count)
                let centerX = (firstX + lastX) / 2
                let width = abs(lastX - firstX) + 40
                return (centerX, width)
            }
            return (size.width / 2, 120)
        }
    }
    
    private func calculateParticipantX(index: Int, count: Int) -> CGFloat {
        if count <= 1 {
            return size.width / 2
        }
        
        let availableWidth = size.width - 100
        let step = min(availableWidth / CGFloat(count - 1), participantSpacing)
        let totalWidth = step * CGFloat(count - 1)
        let leftMargin = (size.width - totalWidth) / 2
        
        return leftMargin + CGFloat(index) * step
    }
}

/// A view that renders loop constructs in sequence diagrams
struct LoopView: View {
    let loop: SequenceLoop
    let participants: [String]
    let size: CGSize
    let participantSpacing: CGFloat
    let messageSpacing: CGFloat
    let participantTopMargin: CGFloat
    
    var body: some View {
        let startY = participantTopMargin + 100 + CGFloat(loop.startIndex) * messageSpacing - 20
        let endY = participantTopMargin + 100 + CGFloat(loop.endIndex) * messageSpacing + 20
        let height = endY - startY
        
        VStack {
            HStack {
                Text("loop [\(loop.text)]")
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    )
                Spacer()
            }
            Spacer()
        }
        .frame(width: size.width - 60, height: height)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 1, dash: [4, 2]))
        )
        .position(x: size.width / 2, y: (startY + endY) / 2)
    }
}

// MARK: - Legacy compatibility
// ArrowShape is defined in FlowchartView.swift and can be reused here if needed