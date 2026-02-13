import UIKit

final class PrintManager {
    /// Print PDF data using AirPrint
    static func printPDF(_ pdfData: Data, jobName: String = "MathBloom Worksheet") {
        let printController = UIPrintInteractionController.shared

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = jobName
        printInfo.outputType = .general

        printController.printInfo = printInfo
        printController.printingItem = pdfData

        printController.present(animated: true) { _, completed, error in
            if let error = error {
                print("Print error: \(error.localizedDescription)")
            }
        }
    }
}
