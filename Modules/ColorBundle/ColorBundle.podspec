Pod::Spec.new do |spec|
  spec.name         = "ColorBundle"
  spec.version      = "0.0.1"
  spec.summary      = "ColorBundle"
  spec.description  = "ColorBundle"
  spec.homepage     = "ColorBundle"
  spec.author       = { "Kamil Khairullin" => "kamil.khayrullin.personal@yandex.ru" }
  spec.source       = { :git => "local", :tag => "#{spec.version}" }
  spec.prefix_header_file = false
  spec.ios.deployment_target = '14.0'
  spec.resources = [
    'Sources/**/*.xcassets'
  ]
end
