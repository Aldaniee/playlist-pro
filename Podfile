# Uncomment the next line to define a global platform for your project
platform :ios, '14.4'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      end
    end
  end

target 'playlist-pro' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for playlist-pro
  pod 'SDWebImage'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Storage'
  pod 'CodableFirebase'
  pod 'Alamofire', '~> 5.2'
  pod "XCDYouTubeKit", "~> 2.15"

  target 'playlist-proTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'playlist-proUITests' do
    # Pods for testing
  end

end
