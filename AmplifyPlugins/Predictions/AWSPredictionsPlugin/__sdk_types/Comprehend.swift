//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

enum AWSComprehend {}

extension AWSComprehend {
    struct InternalServerException: Error {}
    struct InvalidRequestException: Error {}
    struct TextSizeLimitExceededException: Error {}
}

struct DetectSentimentInput: Equatable {
    /// This member is required.
    var languageCode: ComprehendClientTypes.LanguageCode
    /// This member is required.
    var text: String

    enum CodingKeys: String, CodingKey {
        case languageCode = "LanguageCode"
        case text = "Text"
    }
}

struct DetectSentimentOutputResponse: Equatable {
    var sentiment: ComprehendClientTypes.SentimentType?
    var sentimentScore: ComprehendClientTypes.SentimentScore?

    enum CodingKeys: String, CodingKey {
        case sentiment = "Sentiment"
        case sentimentScore = "SentimentScore"
    }
}

struct DetectEntitiesInput: Equatable {
    var bytes: Data?
    var documentReaderConfig: ComprehendClientTypes.DocumentReaderConfig?
    var endpointArn: String?
    var languageCode: ComprehendClientTypes.LanguageCode?
    var text: String?

    enum CodingKeys: String, CodingKey {
        case bytes = "Bytes"
        case documentReaderConfig = "DocumentReaderConfig"
        case endpointArn = "EndpointArn"
        case languageCode = "LanguageCode"
        case text = "Text"
    }
}

struct DetectEntitiesOutputResponse: Equatable {
    var blocks: [ComprehendClientTypes.Block]?
    var documentMetadata: ComprehendClientTypes.DocumentMetadata?
    var documentType: [ComprehendClientTypes.DocumentTypeListItem]?
    var entities: [ComprehendClientTypes.Entity]?
    var errors: [ComprehendClientTypes.ErrorsListItem]?
    
    enum CodingKeys: String, CodingKey {
        case blocks = "Blocks"
        case documentMetadata = "DocumentMetadata"
        case documentType = "DocumentType"
        case entities = "Entities"
        case errors = "Errors"
    }
}


struct DetectKeyPhrasesInput: Equatable {
    /// This member is required.
    var languageCode: ComprehendClientTypes.LanguageCode
    /// This member is required.
    var text: String

    enum CodingKeys: String, CodingKey {
        case languageCode = "LanguageCode"
        case text = "Text"
    }
}

struct DetectKeyPhrasesOutputResponse: Equatable {
    var keyPhrases: [ComprehendClientTypes.KeyPhrase]?

    enum CodingKeys: String, CodingKey {
        case keyPhrases = "KeyPhrases"
    }
}

struct DetectSyntaxInput: Equatable {
    /// This member is required.
    var languageCode: ComprehendClientTypes.SyntaxLanguageCode
    /// This member is required.
    var text: String

    enum CodingKeys: String, CodingKey {
        case languageCode = "LanguageCode"
        case text = "Text"
    }
}

struct DetectSyntaxOutputResponse: Equatable {
    var syntaxTokens: [ComprehendClientTypes.SyntaxToken]?

    enum CodingKeys: String, CodingKey {
        case syntaxTokens = "SyntaxTokens"
    }
}

struct DetectDominantLanguageInput: Equatable {
    /// This member is required.
    var text: String

    enum CodingKeys: String, CodingKey {
        case text = "Text"
    }
}

struct DetectDominantLanguageOutputResponse: Equatable {
    var languages: [ComprehendClientTypes.DominantLanguage]?

    enum CodingKeys: String, CodingKey {
        case languages = "Languages"
    }
}

enum ComprehendClientTypes {}

extension ComprehendClientTypes {
    struct SentimentScore: Equatable {
        var mixed: Float?
        var negative: Float?
        var neutral: Float?
        var positive: Float?
    }
}

extension ComprehendClientTypes {
    enum DocumentReadMode: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case forceDocumentReadAction
        case serviceDefault
        case sdkUnknown(String)

        static var allCases: [DocumentReadMode] {
            return [
                .forceDocumentReadAction,
                .serviceDefault,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .forceDocumentReadAction: return "FORCE_DOCUMENT_READ_ACTION"
            case .serviceDefault: return "SERVICE_DEFAULT"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = DocumentReadMode(rawValue: rawValue) ?? DocumentReadMode.sdkUnknown(rawValue)
        }
    }
}

extension ComprehendClientTypes {
    enum DocumentReadAction: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case textractAnalyzeDocument
        case textractDetectDocumentText
        case sdkUnknown(String)

        static var allCases: [DocumentReadAction] {
            return [
                .textractAnalyzeDocument,
                .textractDetectDocumentText,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .textractAnalyzeDocument: return "TEXTRACT_ANALYZE_DOCUMENT"
            case .textractDetectDocumentText: return "TEXTRACT_DETECT_DOCUMENT_TEXT"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = DocumentReadAction(rawValue: rawValue) ?? DocumentReadAction.sdkUnknown(rawValue)
        }
    }
}

extension ComprehendClientTypes {
    enum DocumentReadFeatureTypes: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case forms
        case tables
        case sdkUnknown(String)

        static var allCases: [DocumentReadFeatureTypes] {
            return [
                .forms,
                .tables,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .forms: return "FORMS"
            case .tables: return "TABLES"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = DocumentReadFeatureTypes(rawValue: rawValue) ?? DocumentReadFeatureTypes.sdkUnknown(rawValue)
        }
    }
}


extension ComprehendClientTypes {
    struct DocumentReaderConfig: Equatable {
        /// This member is required.
        var documentReadAction: ComprehendClientTypes.DocumentReadAction
        var documentReadMode: ComprehendClientTypes.DocumentReadMode?
        var featureTypes: [ComprehendClientTypes.DocumentReadFeatureTypes]?

        enum CodingKeys: String, CodingKey {
            case documentReadAction = "DocumentReadAction"
            case documentReadMode = "DocumentReadMode"
            case featureTypes = "FeatureTypes"
        }
    }
}

extension ComprehendClientTypes {
    enum DocumentType: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case image
        case msWord
        case nativePdf
        case plainText
        case scannedPdf
        case textractAnalyzeDocumentJson
        case textractDetectDocumentTextJson
        case sdkUnknown(String)

        static var allCases: [DocumentType] {
            return [
                .image,
                .msWord,
                .nativePdf,
                .nativePdf,
                .plainText,
                .scannedPdf,
                .textractAnalyzeDocumentJson,
                .textractDetectDocumentTextJson,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .image: return "IMAGE"
            case .msWord: return "MS_WORD"
            case .nativePdf: return "NATIVE_PDF"
            case .plainText: return "PLAIN_TEXT"
            case .scannedPdf: return "SCANNED_PDF"
            case .textractAnalyzeDocumentJson: return "TEXTRACT_ANALYZE_DOCUMENT_JSON"
            case .textractDetectDocumentTextJson: return "TEXTRACT_DETECT_DOCUMENT_TEXT_JSON"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = DocumentType(rawValue: rawValue) ?? DocumentType.sdkUnknown(rawValue)
        }
    }
}

extension ComprehendClientTypes {
    /// Document type for each page in the document.
    struct DocumentTypeListItem: Equatable {
        /// Page number.
        var page: Int?
        /// Document type.
        var type: ComprehendClientTypes.DocumentType?
    }
}

extension ComprehendClientTypes {
    enum PageBasedErrorCode: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case internalServerError
        case pageCharactersExceeded
        case pageSizeExceeded
        case textractBadPage
        case textractProvisionedThroughputExceeded
        case sdkUnknown(String)

        static var allCases: [PageBasedErrorCode] {
            return [
                .internalServerError,
                .pageCharactersExceeded,
                .pageSizeExceeded,
                .textractBadPage,
                .textractProvisionedThroughputExceeded,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .internalServerError: return "INTERNAL_SERVER_ERROR"
            case .pageCharactersExceeded: return "PAGE_CHARACTERS_EXCEEDED"
            case .pageSizeExceeded: return "PAGE_SIZE_EXCEEDED"
            case .textractBadPage: return "TEXTRACT_BAD_PAGE"
            case .textractProvisionedThroughputExceeded: return "TEXTRACT_PROVISIONED_THROUGHPUT_EXCEEDED"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = PageBasedErrorCode(rawValue: rawValue) ?? PageBasedErrorCode.sdkUnknown(rawValue)
        }
    }
}

extension ComprehendClientTypes {
    struct ErrorsListItem: Equatable {
        var errorCode: ComprehendClientTypes.PageBasedErrorCode?
        var errorMessage: String?
        var page: Int?

        enum CodingKeys: String, CodingKey {
            case errorCode = "ErrorCode"
            case errorMessage = "ErrorMessage"
            case page = "Page"
        }
    }
}

extension ComprehendClientTypes {
    struct ChildBlock: Equatable {
        var beginOffset: Int?
        var childBlockId: String?
        var endOffset: Int?

        enum CodingKeys: String, CodingKey {
            case beginOffset = "BeginOffset"
            case childBlockId = "ChildBlockId"
            case endOffset = "EndOffset"
        }
    }
}


extension ComprehendClientTypes {
    struct BlockReference: Equatable {
        var beginOffset: Int?
        var blockId: String?
        var childBlocks: [ComprehendClientTypes.ChildBlock]?
        var endOffset: Int?

        enum CodingKeys: String, CodingKey {
            case beginOffset = "BeginOffset"
            case blockId = "BlockId"
            case childBlocks = "ChildBlocks"
            case endOffset = "EndOffset"
        }
    }
}

extension ComprehendClientTypes {
    /// Provides information about an entity.
    struct Entity: Equatable {
        /// The zero-based offset from the beginning of the source text to the first character in the entity. This field is empty for non-text input.
        var beginOffset: Int?
        /// A reference to each block for this entity. This field is empty for plain-text input.
        var blockReferences: [ComprehendClientTypes.BlockReference]?
        /// The zero-based offset from the beginning of the source text to the last character in the entity. This field is empty for non-text input.
        var endOffset: Int?
        /// The level of confidence that Amazon Comprehend has in the accuracy of the detection.
        var score: Float?
        /// The text of the entity.
        var text: String?
        /// The entity type. For entity detection using the built-in model, this field contains one of the standard entity types listed below. For custom entity detection, this field contains one of the entity types that you specified when you trained your custom model.
        var type: ComprehendClientTypes.EntityType?

        init(
            beginOffset: Int? = nil,
            blockReferences: [ComprehendClientTypes.BlockReference]? = nil,
            endOffset: Int? = nil,
            score: Float? = nil,
            text: String? = nil,
            type: ComprehendClientTypes.EntityType? = nil
        )
        {
            self.beginOffset = beginOffset
            self.blockReferences = blockReferences
            self.endOffset = endOffset
            self.score = score
            self.text = text
            self.type = type
        }
    }
}

extension ComprehendClientTypes {
    struct ExtractedCharactersListItem: Equatable {
        var count: Int?
        var page: Int?

        enum CodingKeys: String, CodingKey {
            case count = "Count"
            case page = "Page"
        }
    }
}

extension ComprehendClientTypes {
    struct DocumentMetadata: Equatable {
        var extractedCharacters: [ComprehendClientTypes.ExtractedCharactersListItem]?
        var pages: Int?
    }
}

extension ComprehendClientTypes {
    struct Geometry: Equatable {
        var boundingBox: ComprehendClientTypes.BoundingBox?
        var polygon: [ComprehendClientTypes.Point]?

        enum CodingKeys: String, CodingKey {
            case boundingBox = "BoundingBox"
            case polygon = "Polygon"
        }
    }
}

extension ComprehendClientTypes {
    struct BoundingBox: Equatable {
        var height: Float?
        var `left`: Float?
        var top: Float?
        var width: Float?

        enum CodingKeys: String, CodingKey {
            case height = "Height"
            case `left` = "Left"
            case top = "Top"
            case width = "Width"
        }
    }
}

extension ComprehendClientTypes {
    struct Point: Equatable {
        var x: Float?
        var y: Float?

        enum CodingKeys: String, CodingKey {
            case x = "X"
            case y = "Y"
        }
    }
}

extension ComprehendClientTypes {
    enum BlockType: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case line
        case word
        case sdkUnknown(String)

        static var allCases: [BlockType] {
            return [
                .line,
                .word,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .line: return "LINE"
            case .word: return "WORD"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = BlockType(rawValue: rawValue) ?? BlockType.sdkUnknown(rawValue)
        }
    }
}

extension ComprehendClientTypes {
    /// Information about each word or line of text in the input document. For additional information, see [Block](https://docs.aws.amazon.com/textract/latest/dg/API_Block.html) in the Amazon Textract API reference.
    struct Block: Equatable {
        /// The block represents a line of text or one word of text.
        ///
        /// * WORD - A word that's detected on a document page. A word is one or more ISO basic Latin script characters that aren't separated by spaces.
        ///
        /// * LINE - A string of tab-delimited, contiguous words that are detected on a document page
        var blockType: ComprehendClientTypes.BlockType?
        /// Co-ordinates of the rectangle or polygon that contains the text.
        var geometry: ComprehendClientTypes.Geometry?
        /// Unique identifier for the block.
        var id: String?
        /// Page number where the block appears.
        var page: Int?
        /// A list of child blocks of the current block. For example, a LINE object has child blocks for each WORD block that's part of the line of text.
        var relationships: [ComprehendClientTypes.RelationshipsListItem]?
        /// The word or line of text extracted from the block.
        var text: String?


    }

}

extension ComprehendClientTypes {
    struct RelationshipsListItem: Equatable {
        var ids: [String]?
        var type: ComprehendClientTypes.RelationshipType?

        enum CodingKeys: String, CodingKey {
            case ids = "Ids"
            case type = "Type"
        }
    }
}

extension ComprehendClientTypes {
    enum RelationshipType: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case child
        case sdkUnknown(String)

        static var allCases: [RelationshipType] {
            return [
                .child,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .child: return "CHILD"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = RelationshipType(rawValue: rawValue) ?? RelationshipType.sdkUnknown(rawValue)
        }
    }
}

extension ComprehendClientTypes {
    struct KeyPhrase: Equatable {
        var beginOffset: Int?
        var endOffset: Int?
        var score: Float?
        var text: String?
    }
}

extension ComprehendClientTypes {
    enum LanguageCode: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case ar
        case de
        case en
        case es
        case fr
        case hi
        case it
        case ja
        case ko
        case pt
        case zh
        case zhTw
        case sdkUnknown(String)

        static var allCases: [LanguageCode] {
            return [
                .ar,
                .de,
                .en,
                .es,
                .fr,
                .hi,
                .it,
                .ja,
                .ko,
                .pt,
                .zh,
                .zhTw,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .ar: return "ar"
            case .de: return "de"
            case .en: return "en"
            case .es: return "es"
            case .fr: return "fr"
            case .hi: return "hi"
            case .it: return "it"
            case .ja: return "ja"
            case .ko: return "ko"
            case .pt: return "pt"
            case .zh: return "zh"
            case .zhTw: return "zh-TW"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = LanguageCode(rawValue: rawValue) ?? LanguageCode.sdkUnknown(rawValue)
        }
    }
}

extension ComprehendClientTypes {
    enum SyntaxLanguageCode: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case de
        case en
        case es
        case fr
        case it
        case pt
        case sdkUnknown(String)

        static var allCases: [SyntaxLanguageCode] {
            return [
                .de,
                .en,
                .es,
                .fr,
                .it,
                .pt,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .de: return "de"
            case .en: return "en"
            case .es: return "es"
            case .fr: return "fr"
            case .it: return "it"
            case .pt: return "pt"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = SyntaxLanguageCode(rawValue: rawValue) ?? SyntaxLanguageCode.sdkUnknown(rawValue)
        }
    }
}

extension ComprehendClientTypes {
    struct SyntaxToken: Equatable {
        var beginOffset: Int?
        var endOffset: Int?
        var partOfSpeech: ComprehendClientTypes.PartOfSpeechTag?
        var text: String?
        var tokenId: Int?
    }
}


extension ComprehendClientTypes {
    struct DominantLanguage: Equatable {
        var languageCode: String?
        var score: Float?
    }
}

extension ComprehendClientTypes {
    struct PartOfSpeechTag: Equatable {
        var score: Float?
        var tag: ComprehendClientTypes.PartOfSpeechTagType?

        enum CodingKeys: String, CodingKey {
            case score = "Score"
            case tag = "Tag"
        }
    }
}

extension ComprehendClientTypes {
    enum SentimentType: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case mixed
        case negative
        case neutral
        case positive
        case sdkUnknown(String)

        static var allCases: [SentimentType] {
            return [
                .mixed,
                .negative,
                .neutral,
                .positive,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .mixed: return "MIXED"
            case .negative: return "NEGATIVE"
            case .neutral: return "NEUTRAL"
            case .positive: return "POSITIVE"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = SentimentType(rawValue: rawValue) ?? SentimentType.sdkUnknown(rawValue)
        }
    }
}

extension ComprehendClientTypes {
    enum PartOfSpeechTagType: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case adj
        case adp
        case adv
        case aux
        case cconj
        case conj
        case det
        case intj
        case noun
        case num
        case o
        case part
        case pron
        case propn
        case punct
        case sconj
        case sym
        case verb
        case sdkUnknown(String)

        static var allCases: [PartOfSpeechTagType] {
            return [
                .adj,
                .adp,
                .adv,
                .aux,
                .cconj,
                .conj,
                .det,
                .intj,
                .noun,
                .num,
                .o,
                .part,
                .pron,
                .propn,
                .punct,
                .sconj,
                .sym,
                .verb,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .adj: return "ADJ"
            case .adp: return "ADP"
            case .adv: return "ADV"
            case .aux: return "AUX"
            case .cconj: return "CCONJ"
            case .conj: return "CONJ"
            case .det: return "DET"
            case .intj: return "INTJ"
            case .noun: return "NOUN"
            case .num: return "NUM"
            case .o: return "O"
            case .part: return "PART"
            case .pron: return "PRON"
            case .propn: return "PROPN"
            case .punct: return "PUNCT"
            case .sconj: return "SCONJ"
            case .sym: return "SYM"
            case .verb: return "VERB"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = PartOfSpeechTagType(rawValue: rawValue) ?? PartOfSpeechTagType.sdkUnknown(rawValue)
        }
    }
}


extension ComprehendClientTypes {
    enum EntityType: Equatable, RawRepresentable, CaseIterable, Codable, Hashable {
        case commercialItem
        case date
        case event
        case location
        case organization
        case other
        case person
        case quantity
        case title
        case sdkUnknown(String)

        static var allCases: [EntityType] {
            return [
                .commercialItem,
                .date,
                .event,
                .location,
                .organization,
                .other,
                .person,
                .quantity,
                .title,
                .sdkUnknown("")
            ]
        }
        init?(rawValue: String) {
            let value = Self.allCases.first(where: { $0.rawValue == rawValue })
            self = value ?? Self.sdkUnknown(rawValue)
        }
        var rawValue: String {
            switch self {
            case .commercialItem: return "COMMERCIAL_ITEM"
            case .date: return "DATE"
            case .event: return "EVENT"
            case .location: return "LOCATION"
            case .organization: return "ORGANIZATION"
            case .other: return "OTHER"
            case .person: return "PERSON"
            case .quantity: return "QUANTITY"
            case .title: return "TITLE"
            case let .sdkUnknown(s): return s
            }
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(RawValue.self)
            self = EntityType(rawValue: rawValue) ?? EntityType.sdkUnknown(rawValue)
        }
    }
}
