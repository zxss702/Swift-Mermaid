import SwiftUI
import SwiftMermaid

struct TimelineExample: View {
    let timelineText = """
    timeline
        title History of Social Media Platform
        
        2002 : LinkedIn
        2004 : Facebook
             : Google
        2005 : Youtube
        2006 : Twitter
        2007 : FourSquare
        2008 : Github
        2010 : Instagram
        2011 : Snapchat
        2012 : Discord
    """
    
    var body: some View {
        VStack {
            Text("Timeline Diagram Example")
                .font(.title)
                .padding()
            
            mermaidView(text: timelineText)
                .frame(height: 400)
                .border(Color.gray, width: 1)
                .padding()
            
            Spacer()
        }
    }
}

#Preview {
    TimelineExample()
}