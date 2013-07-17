Pod::Spec.new do |s|
  s.name         = "AnimationMenu"
  s.platform 	 = :ios, '5.0'
  s.summary      = "This menu will show up from left to right in 90 degree oath"
  s.homepage     = "https://github.com/jailanigithub/AnimationMenu"
  s.author       = { "Jailani" => "jailaninice@gmail.com" }
  s.source       = { :git => "https://github.com/jailanigithub/AnimationMenu.git"}
  s.source_files = 'AwesomeMenu'
  s.frameworks = 'UIKit', 'QuartzCore'
  s.requires_arc = true
end  
