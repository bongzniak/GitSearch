# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'GitSearch' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Architecture
  pod 'ReactorKit'

  # DI
  pod 'Pure'
  pod 'PureSwinject'

  # Networking
  pod 'Moya', '14.0.0-beta.6'
  pod 'Moya/RxSwift', '14.0.0-beta.6'
  pod 'MoyaSugar', '1.3.2'
  pod 'MoyaSugar/RxSwift', '1.3.2'

  # Rx
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxCocoa-Texture'
  pod 'RxDataSources'
  pod 'RxDataSources-Texture'
  pod 'RxOptional'
  pod 'RxCodable'
  pod 'RxViewController'
  pod 'RxKeyboard'

  # UI
  pod 'Texture'
  pod 'TextureSwiftSupport'
  pod 'BonMot'

  # Logging
  pod 'CocoaLumberjack/Swift', '3.6.2'

  # Misc.
  pod 'URLNavigator'
  pod 'SwiftLint'
  pod 'Then'
  pod 'CGFloatLiteral'


  target 'GitSearchTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# Texture temp fix
# https://github.com/TextureGroup/Texture/issues/1914
post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    if target.name == "PINCache" or target.name == "PINRemoteImage"
      puts "Updating #{target.name} OTHER_CFLAGS"
      target.build_configurations.each do |config|
        config.build_settings['OTHER_CFLAGS'] = '-Xclang -fcompatibility-qualified-id-block-type-checking'
      end
    end
  end
end
