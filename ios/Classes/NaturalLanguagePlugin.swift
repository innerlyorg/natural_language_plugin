import Flutter
import Foundation
import NaturalLanguage

public class NaturalLanguagePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "natural_language_plugin", binaryMessenger: registrar.messenger())
        let instance = NaturalLanguagePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let text = args["text"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing 'text' argument", details: nil))
            return
        }

        switch call.method {
        case "isEnglish":
            result(isEnglish(text: text))
        case "analyzeSentiment":
            result(analyzeSentiment(text: text))
        case "extractEntities":
            result(extractEntities(text: text))
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func isEnglish(text: String) -> Bool {
        let tagger = NLTagger(tagSchemes: [.language])
        tagger.string = text
        let (language, _) = tagger.tag(at: text.startIndex, unit: .word, scheme: .language)
        return language?.rawValue == "en"
    }

    private func analyzeSentiment(text: String) -> String {
        if #available(iOS 13.0, *) {
            let predictor = NLSentimentClassifier()
            let sentiment = predictor.predictedSentiment(for: text)
            return sentiment.rawValue
        } else {
            return "unsupported"
        }
    }

    private func extractEntities(text: String) -> [[String: String]] {
        var entities: [[String: String]] = []

        if #available(iOS 13.0, *) {
            let tagger = NLTagger(tagSchemes: [.nameType])
            tagger.string = text

            let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
            let tags: [NLTag] = [.personalName, .placeName, .organizationName]

            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
                if let tag = tag, tag != .other, tags.contains(tag) {
                    let textValue: String = String(text[tokenRange])
                    let typeValue: String = tag.rawValue
                    print("textValue: \(textValue), typeValue: \(typeValue)")
                    entities.append([
                        "text": textValue,
                        "type": typeValue
                    ])
                }
                return true
            }
        }

        let result: [[String: String]] = entities.map { entity in
            var newEntity: [String: String] = [:]
            for (key, value) in entity {
                newEntity[key] = value
            }
            return newEntity
        }

        return result
    }
}