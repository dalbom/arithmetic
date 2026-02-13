import Foundation

enum TeXLiveAPIError: LocalizedError {
    case invalidResponse
    case serverError(String)
    case networkError(Error)

    private var appLocale: Locale {
        Locale(identifier: UserDefaults.standard.string(forKey: "appLanguage") ?? "ko")
    }

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return String(localized: "texlive_invalid_response", locale: appLocale)
        case .serverError(let msg): return String(localized: "texlive_server_error", locale: appLocale) + ": " + msg
        case .networkError(let error): return error.localizedDescription
        }
    }
}

final class TeXLiveAPIClient {
    private let apiURL = URL(string: "https://texlive.net/cgi-bin/latexcgi")!

    /// Compile LaTeX content to PDF via TeXLive.net
    func compileToPDF(texContent: String) async throws -> Data {
        let boundary = UUID().uuidString

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        // Build multipart form data matching Python implementation
        let fields: [(name: String, value: String)] = [
            (name: "filename[]", value: "document.tex"),
            (name: "filecontents[]", value: texContent),
            (name: "return", value: "pdf")
        ]

        request.httpBody = Data.multipartFormData(fields: fields, boundary: boundary)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw TeXLiveAPIError.invalidResponse
            }

            guard httpResponse.statusCode == 200,
                  httpResponse.value(forHTTPHeaderField: "Content-Type") == "application/pdf" else {
                let errorText = String(data: data.prefix(500), encoding: .utf8) ?? "Unknown error"
                throw TeXLiveAPIError.serverError(errorText)
            }

            return data
        } catch let error as TeXLiveAPIError {
            throw error
        } catch {
            throw TeXLiveAPIError.networkError(error)
        }
    }
}
