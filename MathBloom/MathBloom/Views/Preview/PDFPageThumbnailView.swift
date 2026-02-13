import SwiftUI
import PDFKit

struct PDFPageThumbnailView: View {
    let pdfData: Data
    let pageIndex: Int
    let size: CGSize

    var body: some View {
        if let image = generateThumbnail() {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width, height: size.height)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(radius: 2)
        } else {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: size.width, height: size.height)
                .overlay {
                    Image(systemName: "doc")
                        .foregroundStyle(.secondary)
                }
        }
    }

    private func generateThumbnail() -> UIImage? {
        guard let document = PDFDocument(data: pdfData),
              let page = document.page(at: pageIndex) else { return nil }

        let pageRect = page.bounds(for: .mediaBox)
        let scale = min(size.width / pageRect.width, size.height / pageRect.height)
        let scaledSize = CGSize(width: pageRect.width * scale, height: pageRect.height * scale)

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: scaledSize))

            ctx.cgContext.translateBy(x: 0, y: scaledSize.height)
            ctx.cgContext.scaleBy(x: scale, y: -scale)

            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
    }
}
