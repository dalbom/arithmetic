import SwiftUI

struct WorksheetConfig: Codable {
    var name: String = ""
    var childName: String = ""
    var schoolName: String = ""
    var numberOfPages: Int = 3
    var pageOffset: Int = 1
    var problems: [ProblemConfig] = [ProblemConfig()]
    var includeAnswerKey: Bool = false

    /// Total questions per page across all problem types
    var totalQuestionsPerPage: Int {
        problems.reduce(0) { $0 + $1.questionsPerPage }
    }

    /// Validate the configuration
    func validate() -> [LocalizedStringKey] {
        var errors: [LocalizedStringKey] = []
        if problems.isEmpty {
            errors.append("no_problem_types")
        }
        if totalQuestionsPerPage > 50 {
            errors.append("max_questions_error")
        }
        if totalQuestionsPerPage < 1 {
            errors.append("min_questions_error")
        }
        return errors
    }
}
