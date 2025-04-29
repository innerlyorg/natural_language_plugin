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
    s.platform         = :osx, '10.15'
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
    s.swift_version = '5.0'
    
    # This is the critical part to find FlutterMacOS framework
    s.xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(FLUTTER_ROOT)/bin/cache/artifacts/engine/darwin-x64"',
      'OTHER_LDFLAGS' => '$(inherited) -framework FlutterMacOS'
    }

    s.dependency 'FlutterMacOS'
  end