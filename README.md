# Natural Language Plugin

Flutter plugin that provides offline sentiment analysis and entity extraction
using Apple's NaturalLanguage framework on iOS and macOS.

- Sentiment: Positive / Neutral / Negative
- Entities: Person, Organization, Place

## Usage

```dart
import 'package:natural_language_plugin/natural_language_plugin.dart';

final sentiment = await NaturalLanguagePlugin.analyzeSentiment("I love Flutter!");
final entities = await NaturalLanguagePlugin.extractEntities("Steve Jobs founded Apple.");

print(sentiment); // positive
print(entities); // [{"text": "Steve Jobs", "type": "PersonalName"}, ...]