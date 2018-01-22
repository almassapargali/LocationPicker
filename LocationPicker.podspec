Pod::Spec.new do |s|
  s.name     = 'LocationPicker'
  s.version  = '1.1.0'
  s.author   = { 'Almas Sapargali' => 'almassapargali@gmail.com' }
  s.homepage = 'https://github.com/almassapargali/LocationPicker'
  s.description = "LocationPickerViewController is a UIViewController subclass to let users choose locations by searching or selecting on map. It's designed to work as UIImagePickerController."
  s.summary  = "UIViewController subclass for searching or selecting locations on map."
  s.license  = 'MIT'
  s.source   = { :git => 'https://github.com/almassapargali/LocationPicker.git', :tag => s.version.to_s }
  s.source_files = 'LocationPicker'
  s.resource = 'LocationPicker/Images.xcassets'
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
end
