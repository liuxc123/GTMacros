Pod::Spec.new do |s|
  s.name             = 'GTMacros'
  s.version          = '0.0.1'
  s.summary          = '公共宏，公共方法'
  s.homepage         = 'https://github.com/liuxc123/GTMacros'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuxc123' => 'lxc_work@126.com' }
  s.source           = { :git => 'https://github.com/liuxc123/GTMacros.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'GTMacros/**/*'

  s.dependency 'GTCategories/UIKit/UIColor'
end
