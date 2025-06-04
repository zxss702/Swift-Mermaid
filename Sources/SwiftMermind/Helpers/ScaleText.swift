import SwiftUI

@MainActor
class ScaleTextHelperObject: ObservableObject, @unchecked Sendable {
    @Published var scale: CGFloat = 1
    @Published var font: UIFont = UIFont.systemFont(ofSize: 17)
    @Published var color: UIColor = .label
}

@MainActor
struct ScaleText: View {
    let content: String
    let font: UIFont?
    let color: UIColor?
    
    @EnvironmentObject var helperObject:ScaleTextHelperObject
    
    init(_ content: String, font: UIFont? = nil, color: UIColor? = nil) {
        self.content = content
        self.font = font
        self.color = color
    }
    
    @State var textImage: Image = Image(uiImage: UIImage())
    @State var size: CGSize = .zero
    
    var body: some View {
        textImage.resizable().scaledToFit().frame(width: size.width, height: size.height)
            .onAppear {
                let scale = helperObject.scale
                let font = font ?? helperObject.font
                let color = color ?? helperObject.color
               
                Task.detached {
                    let format = UIGraphicsImageRendererFormat()
                    if #available(iOS 18.0, *) {
                        format.scale = await max(min(scale * UIScreen().scale, 6), 0.1)
                    } else {
                        format.scale = await max(min(scale * UIScreen().scale, 6), 1)
                    }
                    let attributedString = NSAttributedString(string: content, attributes: [.font:font, .foregroundColor:color])
                    let size = attributedString.size()
                    let image = UIGraphicsImageRenderer(size: size, format: format).image(actions: { context in
                        attributedString
                            .draw(in: CGRect(origin: .zero, size: size))
                    })
                    await MainActor.run {
                        textImage = Image(uiImage: image)
                        self.size = size
                    }
                }
            }
            .onChange(of: "\(helperObject.scale)\(helperObject.font)\(helperObject.color)") { _ in
                let scale = helperObject.scale
                let font = font ?? helperObject.font
                let color = color ?? helperObject.color
               
                Task.detached {
                    let format = UIGraphicsImageRendererFormat()
                    if #available(iOS 18.0, *) {
                        format.scale = await max(min(scale * UIScreen().scale, 6), 0.1)
                    } else {
                        format.scale = await max(min(scale * UIScreen().scale, 6), 1)
                    }
                    let attributedString = NSAttributedString(string: content, attributes: [.font:font, .foregroundColor:color])
                    let size = attributedString.size()
                    let image = UIGraphicsImageRenderer(size: size, format: format).image(actions: { context in
                        attributedString
                            .draw(in: CGRect(origin: .zero, size: size))
                    })
                    await MainActor.run {
                        textImage = Image(uiImage: image)
                        self.size = size
                    }
                }
            }
    }
}
