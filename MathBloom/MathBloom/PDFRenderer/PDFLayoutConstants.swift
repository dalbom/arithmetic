import UIKit

enum PDFLayoutConstants {
    // A4 page dimensions in points (72 dpi)
    static let pageWidth: CGFloat = 595.28
    static let pageHeight: CGFloat = 841.89
    static let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

    // Margins (2cm = ~56.69 pt)
    static let marginTop: CGFloat = 56.69
    static let marginBottom: CGFloat = 56.69
    static let marginLeft: CGFloat = 56.69
    static let marginRight: CGFloat = 56.69

    // Content area
    static let contentWidth: CGFloat = pageWidth - marginLeft - marginRight
    static let contentHeight: CGFloat = pageHeight - marginTop - marginBottom

    // Two-column layout
    static let columnGap: CGFloat = 56.69 // 2cm gap matching LaTeX \columnsep{2cm}
    static let columnWidth: CGFloat = (contentWidth - columnGap) / 2.0

    // Header area
    static let headerHeight: CGFloat = 40.0
    static let dateFieldY: CGFloat = marginTop
    static let dateUnderlineWidth: CGFloat = 141.73 // ~5cm

    // Footer area
    static let footerY: CGFloat = pageHeight - marginBottom + 20

    // Problem area starts after header
    static let problemAreaTop: CGFloat = marginTop + headerHeight + 14.0 // 0.5cm vspace
}
