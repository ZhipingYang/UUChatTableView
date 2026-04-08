Pod::Spec.new do |spec|
  spec.name         = 'UUChatTableView'
  spec.version      = '1.1.0'
  spec.summary      = 'Lightweight UIKit chat bubbles with text, image, and voice support.'
  spec.description  = <<-DESC
    UUChatTableView provides a small Objective-C chat UI focused on the core message
    model, frame calculation, cell rendering, and a pure-code input bar for demo and reuse.
  DESC
  spec.homepage     = 'https://github.com/ZhipingYang/UUChatTableView'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Zhiping Yang' => 'ZhipingYang@users.noreply.github.com' }
  spec.source       = { :git => 'https://github.com/ZhipingYang/UUChatTableView.git', :tag => spec.version.to_s }

  spec.ios.deployment_target = '13.0'
  spec.requires_arc = true
  spec.source_files = 'Class/**/*.{h,m}'
  spec.public_header_files = 'Class/**/*.h'
  spec.frameworks = 'UIKit', 'AVFoundation', 'Photos', 'PhotosUI'
  spec.cocoapods_version = '>= 1.13.0'
end
