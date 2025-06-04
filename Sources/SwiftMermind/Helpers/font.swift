import SwiftUI

typealias FontSize = CGFloat

extension Font {
    static func custom(size: FontSize) -> Font {
        @AppStorage("fontName") var fontName:String = "Source Han Serif SC VF"
        return .custom(fontName, fixedSize: size)
    }
}
extension UIFont {
    static func custom(size: FontSize) -> UIFont {
        @AppStorage("fontName") var fontName:String = "Source Han Serif SC VF"
        return UIFont(name: fontName, size: size)!
    }
}
extension FontSize {
    public static let largeTitle: CGFloat = 34

    /// A font with the title text style.
    public static let title: CGFloat = 28
    
    public static let title2: CGFloat = 22
    
    public static let title3: CGFloat = 20

    /// A font with the headline text style.
    public static let headline: CGFloat = 17

    /// A font with the subheadline text style.
    public static let subheadline: CGFloat = 15

    /// A font with the body text style.
    public static let body: CGFloat = 17

    /// A font with the callout text style.
    public static let callout: CGFloat = 16

    /// A font with the footnote text style.
    public static let footnote: CGFloat = 13

    /// A font with the caption text style.
    public static let caption: CGFloat = 12

    public static let caption2: CGFloat = 11
}
