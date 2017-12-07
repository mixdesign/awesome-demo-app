source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

def shared_pods
  pod 'RealmSwift', '2.10.2'
  pod 'SnapKit', '~> 4.0'
  pod 'RxSwift', '~> 3.0'
  pod 'DynamicColor', '4.0.1'
end

target 'EasySell' do
  shared_pods
  pod 'IQKeyboardManagerSwift', '~> 5.0.0'
  pod 'SVProgressHUD', '2.2.2'
  pod "RxRealm", '0.7.2'
  pod "RxRealmDataSources", '0.2.4'
  pod 'CHIPageControl', '~> 0.1.3'
  pod 'GrowingTextView', '~> 0.5.3'
  pod 'Fusuma'
  pod 'MGSwipeTableCell'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          if ["RxSwift", "RxCocoa", "SwiftyAttributes", "Result", "Fusuma"].include? target.name
            config.build_settings['SWIFT_VERSION'] = '3.0'
          else
            config.build_settings['SWIFT_VERSION'] = '4.0'
          end
      end
  end
end
