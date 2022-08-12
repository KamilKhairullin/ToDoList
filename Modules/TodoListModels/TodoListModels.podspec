Pod::Spec.new do |spec|
  spec.name         = "TodoListModels"
  spec.version      = "0.0.1"
  spec.summary      = "TodoListModels"
  spec.description  = "TodoListModels"
  spec.homepage     = "TodoListModels"
  spec.author       = { "Kamil Khairullin" => "kamil.khayrullin.personal@yandex.ru" }
  spec.source       = { :git => "local", :tag => "#{spec.version}" }
  spec.prefix_header_file = false
  spec.ios.deployment_target = '14.0'
  spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"
  spec.source_files = [
    'Sources/**/*.{swift,h,m}'
  ]
end
