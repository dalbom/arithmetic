import Foundation

extension Data {
    /// Create multipart form data from field dictionary
    static func multipartFormData(
        fields: [(name: String, value: String)],
        boundary: String
    ) -> Data {
        var body = Data()

        for field in fields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(field.name)\"\r\n\r\n")
            body.append("\(field.value)\r\n")
        }

        body.append("--\(boundary)--\r\n")
        return body
    }

    /// Append string as UTF-8 data
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
