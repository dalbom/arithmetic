import Foundation

extension ArithmeticEngine {
    /// Generate answer key data from an existing worksheet
    static func generateAnswerKey(from worksheet: GeneratedWorksheet) -> [[String]] {
        worksheet.pages.map { page in
            page.problems.map { problem in
                "\(problem.problemNumber). \(problem.answerDisplayString)"
            }
        }
    }
}
