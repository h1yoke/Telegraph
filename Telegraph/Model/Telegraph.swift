import Foundation

/// Available [Telegraph API](https://telegra.ph/api#Available-types) types protocol.
/// Expected Telegraph API types:
///  - Account
///  - PageList
///  - Page
///  - PageViews
///  - Node
///  - NodeElement
protocol TelegraphTypes: Codable {}

/// Enumeration namespace for [Telegraph API](https://telegra.ph/api) interaction.
/// Contains:
///  - All expected Telegraph API types
///  - Error enumeration
///  - `query` method
enum Telegraph {
    /// Errors that might occure during Telegraph API query.
    /// Values:
    ///  - `Telegraph.Error.wrongQuery`: constructed query was not correct (ussually means `ok == false` in `Telegraph.Response`)
    ///  - `Telegraph.Error.badResponse`: recieved API response was not correct
    enum Error: Swift.Error {
        case wrongQuery(descrpition: String)
        case badResponse(response: String)
    }

    /// This object represents a Telegraph [account](https://telegra.ph/api#Account).
    struct Account: TelegraphTypes {
        /// Account name, helps users with several accounts remember which they are currently using.
        /// Displayed to the user above the "Edit/Publish" button on Telegra.ph, other users don't see this name.
        var shortName: String?
        /// Default author name used when creating new articles.
        var authorName: String?
        /// Profile link, opened when users click on the author's name below the title.
        /// Can be any link, not necessarily to a Telegram profile or channel.
        var authorUrl: String?
        /// Optional. Only returned by the createAccount and revokeAccessToken method. Access token of the Telegraph account.
        var accessToken: String?
        /// Optional. URL to authorize a browser on telegra.ph and connect it to a Telegraph account.
        /// This URL is valid for only one use and for 5 minutes only.
        var authUrl: String?
        /// Optional. Number of pages belonging to the Telegraph account.
        var pageCount: Int?

        /// JSON corresponding coding keys
        private enum CodingKeys: String, CodingKey {
            case shortName = "short_name"
            case authorUrl = "author_url"
            case accessToken = "access_token"
            case authUrl = "auth_url"
            case pageCount = "page_count"
        }
    }

    /// This abstract object represents a [DOM Node](https://telegra.ph/api#Node).
    /// It can be a String which represents a DOM text node or a NodeElement object.
    struct Node: TelegraphTypes, CustomStringConvertible {
        /// String that represents a DOM text node. Either this or object is valid.
        var textNode: String?
        /// NodeElement object. Either this or textNode is valid.
        var object: NodeElement?
        /// Custom String coversion.
        var description: String {
            if let textNode = textNode {
                return "{\"tag\":\"p\",\"children\":[\"\(textNode)\"]}"
            }
            if let object = object {
                return "\(object)"
            }
            return ""
        }

        /// Decoder initializer for `Decodable` conformance.
        /// - parameter from decoder: `Decoder` object.
        init(from decoder: Decoder) throws {
            let container =  try decoder.singleValueContainer()
            do {
                object = try container.decode(NodeElement.self)
                textNode = nil
            } catch {
                textNode = try container.decode(String.self)
                object = nil
            }
        }

        /// Default initializer. One of parameters should be nil.
        /// - parameter textNode: String text node.
        /// - parameter object: Complex node element.
        init(textNode: String?, object: NodeElement?) {
            self.textNode = textNode
            self.object = object
        }

        /// `Encodable` protocol conformance.
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try object == nil ? container.encode(textNode!) : container.encode(object)
        }

        private func flatUnwrapRecoursive(root current: Node, accumulator: String) -> String {
            if let textNode = current.textNode {
                return accumulator + textNode + "\n"
            } else if let object = current.object {
                var newAccum = accumulator
                object.children?.forEach { newAccum += flatUnwrapRecoursive(root: $0, accumulator: accumulator) }
                return newAccum
            }
            return ""
        }

        func flatUnwrap() -> String {
            return flatUnwrapRecoursive(root: self, accumulator: "")
        }
    }

    /// This object represents a [page](https://telegra.ph/api#Page) on Telegraph.
    struct Page: TelegraphTypes {
        /// Path to the page.
        var path: String
        /// URL of the page.
        var url: String
        /// Title of the page.
        var title: String
        /// Description of the page.
        var description: String
        /// Optional. Name of the author, displayed below the title.
        var authorName: String?
        /// Optional. Profile link, opened when users click on the author's name below the title.
        /// Can be any link, not necessarily to a Telegram profile or channel.
        var authorUrl: String?
        /// Optional. Image URL of the page.
        var imageUrl: String?
        /// Optional. Content of the page.
        var content: [Node]?
        /// Number of page views for the page.
        var views: Int
        /// Optional. Only returned if access_token passed. True, if the target Telegraph account can edit the page.
        var canEdit: Bool?

        /// JSON corresponding coding keys
        private enum CodingKeys: String, CodingKey {
            case path = "path"
            case url = "url"
            case title = "title"
            case description = "description"
            case authorName = "author_name"
            case authorUrl = "author_url"
            case imageUrl = "image_url"
            case content = "content"
            case views = "views"
            case canEdit = "can_edit"
        }
    }

    /// This object represents a [list of Telegraph articles](https://telegra.ph/api#PageList)
    /// belonging to an account. Most recently created articles first.
    struct PageList: TelegraphTypes {
        /// Total number of pages belonging to the target Telegraph account.
        var totalCount: Int
        /// Requested pages of the target Telegraph account.
        var pages: [Page]

        /// JSON corresponding coding keys
        private enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case pages = "pages"
        }
    }

    /// This object represents the number of [page views](https://telegra.ph/api#PageViews) for a Telegraph article.
    struct PageViews: TelegraphTypes {
        /// Number of page views for the target page.
        var views: Int
    }

    /// This object represents a [DOM element node](https://telegra.ph/api#NodeElement).
    struct NodeElement: TelegraphTypes {
        /// Name of the DOM element. Available tags: a, aside, b, blockquote, br,
        /// code, em, figcaption, figure, h3, h4, hr, i, iframe, img, li, ol, p, pre, s, strong, u, ul, video.
        var tag: String
        /// Optional. Attributes of the DOM element. Key of object represents
        /// name of attribute, value represents value of attribute. Available attributes: href, src.
        var attrs: [String: String]?
        /// Optional. List of child nodes for the DOM element.
        var children: [Node]?
    }

    /// This object represents server response.
    struct Response<T: TelegraphTypes>: TelegraphTypes {
        // True if data is valid, false otherwise.
        var ok: Bool
        // TelegraphTypes requested data.
        var result: T?
        // Error description if ok if False.
        var error: String?
    }

    /// Enumeration for [Telegraph API Methods](https://telegra.ph/api#Available-methods).
    enum Method {
        /// Use this method to create a new Telegraph account. Most users only need one account,
        /// but this can be useful for channel administrators who would like to keep individual
        /// author names and profile links for each of their channels.
        /// On success, returns an Account object with the regular fields and an additional access_token field.
        ///
        /// - `short_name (String, 1-32 characters)`:
        ///
        /// **Required.** Account name, helps users with several accounts remember which they are currently using.
        /// Displayed to the user above the "Edit/Publish" button on Telegra.ph, other users don't see this name.
        /// - `author_name (String, 0-128 characters)`:
        ///
        /// Default author name used when creating new articles.
        /// - `author_url (String, 0-512 characters)`:
        ///
        /// Default profile link, opened when users click on the author's name below the title.
        /// Can be any link, not necessarily to a Telegram profile or channel.
        case createAccount(shortName: String, authorName: String? = nil, authorUrl: String? = nil)

        /// Use this method to update information about a Telegraph account.
        /// Pass only the parameters that you want to edit. On success, returns an Account object with the default fields.
        ///
        /// - `access_token (String)`:
        ///
        /// **Required.** Access token of the Telegraph account.
        ///
        /// - `short_name (String, 1-32 characters)`:
        ///
        /// New account name.
        /// - `author_name (String, 0-128 characters)`:
        ///
        /// New default author name used when creating new articles.
        /// - `author_url (String, 0-512 characters)`:
        ///
        /// New default profile link, opened when users click on the author's name below the title.
        /// Can be any link, not necessarily to a Telegram profile or channel.
        case editAccountInfo(accessToken: String, shortName: String? = nil, authorName: String? = nil, authorUrl: String? = nil)

        /// Use this method to get information about a Telegraph account. Returns an Account object on success.
        ///
        /// - `access_token (String)`:
        ///
        /// **Required.** Access token of the Telegraph account.
        /// - `fields (Array of String, default = [“short_name”,“author_name”,“author_url”])`:
        ///
        /// List of account fields to return. Available fields: short_name, author_name, author_url, auth_url, page_count.
        case getAccountInfo(accessToken: String, fields: [String]? = ["short_name", "author_name", "author_url", "page_count"])

        /// Use this method to revoke access_token and generate a new one, for example,
        /// if the user would like to reset all connected sessions, or you have reasons to believe the token was compromised.
        /// On success, returns an Account object with new access_token and auth_url fields.
        ///
        /// - `access_token (String)`:
        ///
        /// **Required.** Access token of the Telegraph account.
        case revokeAccessToken(accessToken: String)

        /// Use this method to create a new Telegraph page. On success, returns a Page object.
        ///
        /// - `access_token (String)`:
        ///
        /// **Required.** Access token of the Telegraph account.
        /// - `title (String, 1-256 characters)`:
        ///
        /// **Required.** Page title.
        /// - `author_name (String, 0-128 characters)`:
        ///
        /// Author name, displayed below the article's title.
        /// - `author_url (String, 0-512 characters)`:
        ///
        /// Profile link, opened when users click on the author's name below the title.
        /// Can be any link, not necessarily to a Telegram profile or channel.
        /// `content (Array of Node, up to 64 KB)`:
        ///
        /// **Required.** Content of the page.
        /// `return_content (Boolean, default = false)`:
        ///
        /// If true, a content field will be returned in the Page object (see: Content format).
        case createPage(accessToken: String, title: String, authorName: String? = nil,
                        authorUrl: String? = nil, content: [Node], returnContent: Bool? = false)

        /// Use this method to edit an existing Telegraph page. On success, returns a Page object.
        ///
        /// - `access_token (String)`:
        ///
        /// **Required.** Access token of the Telegraph account.
        /// - `path (String)`:
        ///
        /// **Required.** Path to the page.
        /// - `title (String, 1-256 characters)`:
        ///
        /// **Required.** Page title.
        /// - `content (Array of Node, up to 64 KB)`:
        ///
        /// **Required.** Content of the page.
        /// - `author_name (String, 0-128 characters)`:
        ///
        /// Author name, displayed below the article's title.
        /// - `author_url (String, 0-512 characters)`:
        ///
        /// Profile link, opened when users click on the author's name below the title.
        /// Can be any link, not necessarily to a Telegram profile or channel.
        /// - `return_content (Boolean, default = false)`:
        ///
        /// If true, a content field will be returned in the Page object.
        case editPage(accessToken: String, path: String, title: String,
                      content: [Node], authorName: String? = nil, authorUrl: String? = nil, returnContent: Bool? = false)

        /// Use this method to get a Telegraph page. Returns a Page object on success.
        ///
        /// - `path (String)`:
        ///
        /// **Required.** Path to the Telegraph page (in the format Title-12-31, i.e. everything that comes after `http://telegra.ph/`).
        /// - `return_content (Boolean, default = false)`:
        ///
        /// If true, content field will be returned in Page object.
        case getPage(path: String, returnContent: Bool? = false)

        /// Use this method to get a list of pages belonging to a Telegraph account.
        /// Returns a PageList object, sorted by most recently created pages first.
        ///
        /// - `access_token (String)`:
        ///
        /// **Required.** Access token of the Telegraph account.
        /// - `offset (Integer, default = 0)`:
        ///
        /// Sequential number of the first page to be returned.
        /// - `limit (Integer, 0-200, default = 50)`:
        ///
        /// Limits the number of pages to be retrieved.
        case getPageList(accessToken: String, offset: Int? = 0, limit: Int? = 50)

        /// Use this method to get the number of views for a Telegraph article.
        /// Returns a PageViews object on success. By default, the total number of page views will be returned.
        ///
        /// - `path (String)`:
        ///
        /// **Required.** Path to the Telegraph page (in the format Title-12-31,
        /// where 12 is the month and 31 the day the article was first published).
        /// - `year (Integer, 2000-2100)`:
        ///
        /// Required if month is passed. If passed, the number of page views for the requested year will be returned.
        /// - `month (Integer, 1-12)`:
        ///
        /// Required if day is passed. If passed, the number of page views for the requested month will be returned.
        /// - `day (Integer, 1-31)`:
        ///
        /// Required if hour is passed. If passed, the number of page views for the requested day will be returned.
        /// - `hour (Integer, 0-24)`:
        ///
        /// If passed, the number of page views for the requested hour will be returned.
        case getViews(path: String, year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil)

        /// Generates URL  based on `self` value.
        /// - returns: URL for Telegraph API server.
        func generateQuery() -> URL? {
            func addToQuery(queryItems: inout [URLQueryItem]?, newItems: [(String, Any?)]) {
                newItems.forEach {
                    if let item = $0.1 {
                        queryItems?.append(URLQueryItem(name: $0.0, value: "\(item)"))
                    }
                }
            }

            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.telegra.ph"
            components.queryItems = []

            switch self {
            case .createAccount(let shortName, let authorName, let authorUrl):
                components.path = "/createAccount"
                addToQuery(queryItems: &components.queryItems, newItems: [
                    ("short_name", shortName),
                    ("author_name", authorName),
                    ("author_url", authorUrl)
                ])
            case .editAccountInfo(let accessToken, let shortName, let authorName, let authorUrl):
                components.path = "/editAccountInfo"
                addToQuery(queryItems: &components.queryItems, newItems: [
                    ("access_token", accessToken),
                    ("short_name", shortName),
                    ("author_name", authorName),
                    ("author_url", authorUrl)
                ])
            case .getAccountInfo(let accessToken, let fields):
                components.path = "/getAccountInfo"
                addToQuery(queryItems: &components.queryItems, newItems: [
                    ("access_token", accessToken),
                    ("fields", fields)
                ])
            case .revokeAccessToken(let accessToken):
                components.path = "/revokeAccessToken"
                addToQuery(queryItems: &components.queryItems, newItems: [("access_token", accessToken)])
            case .createPage(let accessToken, let title, let authorName, let authorUrl, let content, let returnContent):
                components.path = "/createPage"
                addToQuery(queryItems: &components.queryItems, newItems: [
                    ("access_token", accessToken),
                    ("title", title),
                    ("author_name", authorName),
                    ("author_url", authorUrl),
                    ("content", content),
                    ("return_content", returnContent)
                ])
            case .editPage(let accessToken, let path, let title, let content, let authorName, let authorUrl, let returnContent):
                components.path = "/editPage"
                addToQuery(queryItems: &components.queryItems, newItems: [
                    ("access_token", accessToken),
                    ("path", path),
                    ("title", title),
                    ("content", content),
                    ("author_name", authorName),
                    ("author_url", authorUrl),
                    ("return_content", returnContent)
                ])
            case .getPage(let path, let returnContent):
                components.path = "/getPage"
                addToQuery(queryItems: &components.queryItems, newItems: [
                    ("path", path),
                    ("return_content", returnContent)
                ])
            case .getPageList(let accessToken, let offset, let limit):
                components.path = "/getPageList"
                addToQuery(queryItems: &components.queryItems, newItems: [
                    ("access_token", accessToken),
                    ("offset", offset),
                    ("limit", limit)
                ])
            case .getViews(let path, let year, let month, let day, let hour):
                components.path = "/getViews"
                addToQuery(queryItems: &components.queryItems, newItems: [
                    ("path", path),
                    ("year", year),
                    ("month", month),
                    ("day", day),
                    ("hour", hour)
                ])
            }
            return components.url
        }
    }

    /// Parses given input string to Telegraph API response.
    /// - parameter input: String to be prased.
    /// - returns: Parsed `Response<T>` value
    /// - throws: `Telegraph.Error.badResponse` if  given value can not be parsed.
    private static func parse<T: TelegraphTypes>(input: String) throws -> Response<T> {
        guard let inputData = input.data(using: .utf8) else {
            throw Telegraph.Error.badResponse(response: input)
        }
        do {
            let response = try JSONDecoder().decode(Response<T>.self, from: inputData)
            return response
        } catch {
            throw Telegraph.Error.badResponse(response: input)
        }
    }

    /// Unwraps given response to a Telegraph API type.
    /// - parameter response: Reponse to be unwrapped.
    /// - parameter success: Clousure that will be executed if response is unwrappable.
    /// - parameter failure: Clousure that will be executed if response is not unwrappable.
    static func unwrapResponse<T: TelegraphTypes>(_ response: Response<T>, success: (T) -> Void, failure: (String) -> Void) {
        if response.ok, let result = response.result {
            success(result)
        } else if let error = response.error {
            failure(error)
        }
    }

    /// Makes an URL query to Telegraph API servers.
    /// - parameter method: Telegraph API method that will be queried.
    /// - parameter completion: Clousure that will be executed if response is unwrappable.
    /// - throws: `Telegraph.Error.wrongQuery` if query can not be generated.
    static func query<T: TelegraphTypes>(method: Method, completion: @escaping (Response<T>) -> Void) throws {
        guard let url = method.generateQuery() else {
            throw Telegraph.Error.wrongQuery(descrpition: "")
        }
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let input = String(data: data, encoding: .utf8),
               let response: Response<T> = try? parse(input: input) {
                completion(response)
            }
        }
    }
}
