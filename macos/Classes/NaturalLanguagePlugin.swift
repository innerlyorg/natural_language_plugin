import FlutterMacOS
import NaturalLanguage
import Foundation
import CoreML

public class NaturalLanguagePlugin: NSObject, FlutterPlugin {
    private var model: MLModel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "natural_language_plugin", binaryMessenger: registrar.messenger)
        let instance = NaturalLanguagePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing arguments", details: nil))
            return
        }
        
        switch call.method {
        case "isEnglish":
            guard let text = args["text"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing 'text' argument", details: nil))
                return
            }
            result(isEnglish(text: text))
            
        case "analyzeSentiment":
            guard let text = args["text"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing 'text' argument", details: nil))
                return
            }
            result(analyzeSentiment(text: text))
            
        case "extractEntities":
            guard let text = args["text"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing 'text' argument", details: nil))
                return
            }
            result(extractEntities(text: text))
            
        case "loadModel":
            guard let modelPath = args["modelPath"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing 'modelPath' argument", details: nil))
                return
            }
            loadModel(modelPath: modelPath, result: result)
            
        case "predictWithModel":
            guard let inputData = args["inputData"] as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing 'inputData' argument", details: nil))
                return
            }
            predictWithModel(inputData: inputData, result: result)
            
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

    private func analyzeSentiment(text: String) -> Double? {
        if #available(macOS 10.15, *) {
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = text
            let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
            if let scoreString = sentiment?.rawValue, let score = Double(scoreString) {
                return score
            }
            return nil
        } else {
            return nil
        }
    }

    private func extractEntities(text: String) -> [[String: String]] {
        var entities: [[String: String]] = []

        if #available(macOS 10.15, *) {
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

    private func loadModel(modelPath: String, result: @escaping FlutterResult) {
        do {
            // Check if file exists at path
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: modelPath) else {
                result(FlutterError(code: "MODEL_NOT_FOUND", message: "Model file not found at path: \(modelPath)", details: nil))
                return
            }
            
            // Create URL from path
            let modelURL = URL(fileURLWithPath: modelPath)
            
            // Compile model
            let compiledModelURL = try MLModel.compileModel(at: modelURL)
            
            // Load compiled model
            self.model = try MLModel(contentsOf: compiledModelURL)
            result(true)
        } catch {
            result(FlutterError(code: "MODEL_LOADING_ERROR", message: "Failed to load model: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func predictWithModel(inputData: [String: Any], result: @escaping FlutterResult) {
        guard let model = self.model else {
            result(FlutterError(code: "MODEL_NOT_LOADED", message: "No model has been loaded", details: nil))
            return
        }
        
        do {
            // Convert the input dictionary to MLFeatureProvider
            let inputFeatures = try MLDictionaryFeatureProvider(dictionary: inputData)
            
            // Make prediction
            let prediction = try model.prediction(from: inputFeatures)
            
            // Convert output features to dictionary
            var outputDict: [String: Any] = [:]
            for featureName in prediction.featureNames {
                if let feature = prediction.featureValue(for: featureName) {
                    switch feature.type {
                    case .string:
                        outputDict[featureName] = feature.stringValue
                    case .int64:
                        outputDict[featureName] = feature.int64Value
                    case .double:
                        outputDict[featureName] = feature.doubleValue
                    case .multiArray:
                        if let multiArray = feature.multiArrayValue {
                            var array: [Double] = []
                            for i in 0..<multiArray.count {
                                array.append(multiArray[i].doubleValue)
                            }
                            outputDict[featureName] = array
                        }
                    default:
                        // For other types, convert to string representation
                        outputDict[featureName] = "\(feature)"
                    }
                }
            }
            
            result(outputDict)
        } catch {
            result(FlutterError(code: "PREDICTION_ERROR", message: "Failed to make prediction: \(error.localizedDescription)", details: nil))
        }
    }
}