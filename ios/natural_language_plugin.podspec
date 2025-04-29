Pod::Spec.new do |s|
    s.name             = 'natural_language_plugin'
    s.version          = '0.0.1'
    s.summary          = 'Apple Natural Language plugin for Flutter (iOS and macOS).'
    s.description      = <<-DESC
  Flutter plugin to use Apple Natural Language for sentiment analysis and entity extraction.
                         DESC
    s.homepage         = 'https://yourhomepage.com'
    s.license          = { :file => '../LICENSE' }
    s.author           = { 'YourName' => 'you@example.com' }
    s.source           = { :path => '.' }
    s.source_files     = 'Classes/**/*'
    s.frameworks       = 'NaturalLanguage'
    s.platform         = :ios, '13.0'
    s.dependency 'Flutter'
  end