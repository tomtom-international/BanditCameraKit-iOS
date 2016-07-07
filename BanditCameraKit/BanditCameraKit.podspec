Pod::Spec.new do |s|
	s.name         = 'BanditCameraKit'
	s.version      = '1.0'
	s.platform     = :ios, '8.0'
	s.summary      = 'Core source for communication with TomTom Bandit camera media server'
	s.requires_arc = true
	s.dependency 'Alamofire'
	s.dependency 'CocoaAsyncSocket'
  	s.source_files = { :git => 'https://github.com/tomtom-international/BanditCameraKit-iOS.git', :tag => s.version }
end

