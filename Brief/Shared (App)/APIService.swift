import Foundation

struct APIService {
    func sendArticle(
        url: String,
        title: String,
        email: String,
        context: String? = nil,
        aiSummary: Bool = false,
        summaryLength: String = "short"
    ) async throws -> Bool {
        
        let endpoint = UserPreferences.shared.apiEndpoint
        
        guard let apiURL = URL(string: endpoint),
              Self.isSupportedWebURL(apiURL) else {
            throw APIError.invalidURL
        }

        guard let articleURL = URL(string: url),
              Self.isSupportedWebURL(articleURL) else {
            throw APIError.unsupportedURL
        }
        
        // Extract site from URL
        let site = articleURL.host ?? ""
        
        let requestBody = APIRequest(
            url: url,
            title: title,
            site: site,
            email: email,
            context: context,
            aiSummary: aiSummary,
            summaryLength: summaryLength
        )
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw APIError.encodingError
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 30
        let session = URLSession(configuration: config)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            if let responseData = try? JSONDecoder().decode(APIResponse.self, from: data) {
                return responseData.success
            }
            return true
        } else {
            // Try to parse error message
            if let errorData = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                throw APIError.serverError(errorData.error)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    private static func isSupportedWebURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(),
              let host = url.host,
              !host.isEmpty else { return false }
        return scheme == "http" || scheme == "https"
    }
}

struct APIRequest: Codable {
    let url: String
    let title: String
    let site: String
    let email: String
    let context: String?
    let aiSummary: Bool
    let summaryLength: String
}

struct APIResponse: Codable {
    let success: Bool
}

struct APIErrorResponse: Codable {
    let error: String
}

enum APIError: LocalizedError {
    case invalidURL
    case unsupportedURL
    case encodingError
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL. Please check your settings."
        case .unsupportedURL:
            return "Brief can only send web links that start with http:// or https://."
        case .encodingError:
            return "Failed to encode request data."
        case .invalidResponse:
            return "Invalid response from server."
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .serverError(let message):
            return message
        }
    }
}
