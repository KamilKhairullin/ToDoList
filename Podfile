platform :ios, '14.0'

def local_pod(name, **kwargs)
    kwargs[:path] = "./Modules/#{name}"
    pod name, kwargs
end

target 'ToDoList' do
  use_frameworks!

  pod 'CocoaLumberjack'
  pod 'SwiftLint'
  pod 'SQLite.swift', '~> 0.13.3'
  local_pod 'ColorBundle'
  
  target 'ToDoListTests' do
    inherit! :search_paths
    pod 'CocoaLumberjack'
    pod 'SwiftLint'
  end

  target 'ToDoListUITests' do
    inherit! :search_paths
    pod 'CocoaLumberjack'
    pod 'SwiftLint'
  end
end

