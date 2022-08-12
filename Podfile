platform :ios, '14.0'

def local_pod(name, **kwargs)
    kwargs[:path] = "./Modules/#{name}"
    pod name, kwargs
end

target 'ToDoList' do
  use_frameworks!

  pod 'CocoaLumberjack'
  pod 'SwiftLint'
  local_pod 'TodoListModels'

  target 'ToDoListTests' do
    inherit! :search_paths
  end

  target 'ToDoListUITests' do
    inherit! :search_paths
  end
end

