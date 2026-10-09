require 'xcodeproj'
require 'fileutils'

root = ARGV.fetch(0)
project_path = File.join(root, 'SCPFoundation.xcodeproj')
FileUtils.rm_rf(project_path)
project = Xcodeproj::Project.new(project_path)
project.root_object.attributes['LastUpgradeCheck'] = '1600'
project.root_object.attributes['TargetAttributes'] ||= {}

settings = {
  'SWIFT_VERSION' => '5.9',
  'CODE_SIGN_STYLE' => 'Automatic',
  'DEVELOPMENT_TEAM' => '',
  'IPHONEOS_DEPLOYMENT_TARGET' => '18.0',
  'MACOSX_DEPLOYMENT_TARGET' => '14.0',
  'WATCHOS_DEPLOYMENT_TARGET' => '10.0',
  'XROS_DEPLOYMENT_TARGET' => '2.0'
}

def set_common(target, settings)
  target.build_configurations.each do |config|
    settings.each { |key, value| config.build_settings[key] = value }
  end
end

def add_files(project, group, root, paths)
  refs = []
  paths.flatten.each do |relative|
    absolute = File.join(root, relative)
    next unless File.file?(absolute)
    ref = group.new_file(relative)
    ref.path = relative
    ref.source_tree = '<group>'
    refs << ref
  end
  refs
end

def add_sources(target, refs)
  refs.compact.each { |ref| target.source_build_phase.add_file_reference(ref) }
end

def add_resources(target, refs)
  refs.compact.each { |ref| target.resources_build_phase.add_file_reference(ref) }
end

def add_scheme(root, name, target, test_target = nil)
  scheme_dir = File.join(root, 'SCPFoundation.xcodeproj', 'xcshareddata', 'xcschemes')
  FileUtils.mkdir_p(scheme_dir)
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(target)
  scheme.launch_action.buildable_product_runnable = Xcodeproj::XCScheme::BuildableProductRunnable.new(target)
  if test_target
    scheme.test_action.add_testable(
      Xcodeproj::XCScheme::TestAction::TestableReference.new(test_target)
    )
  end
  scheme.launch_action.build_configuration = 'Debug'
  scheme.test_action.build_configuration = 'Debug'
  scheme.save_as(File.join(root, 'SCPFoundation.xcodeproj'), name, true)
end

root_group = project.main_group
shared_group = root_group.new_group('Shared', 'Sources/Shared')
ios_group = root_group.new_group('iOSApp', 'Sources/iOSApp')
mac_group = root_group.new_group('MacApp', 'Sources/MacApp')
vision_group = root_group.new_group('VisionApp', 'Sources/VisionApp')
platform_group = root_group.new_group('PlatformSupport', 'Sources/PlatformSupport')
watch_group = root_group.new_group('WatchApp', 'Sources/WatchApp')
widgets_group = root_group.new_group('Widgets', 'Sources/Widgets')
tests_group = root_group.new_group('Tests', 'Tests')
backend_group = root_group.new_group('Backend', 'Backend')

shared_files = Dir[File.join(root, 'Sources/Shared/**/*.swift')].map { |p| p.delete_prefix(root + '/') }
ios_files = Dir[File.join(root, 'Sources/iOSApp/**/*.swift')].map { |p| p.delete_prefix(root + '/') }
mac_files = Dir[File.join(root, 'Sources/MacApp/**/*.swift')].map { |p| p.delete_prefix(root + '/') }
vision_files = Dir[File.join(root, 'Sources/VisionApp/**/*.swift')].map { |p| p.delete_prefix(root + '/') }
platform_files = Dir[File.join(root, 'Sources/PlatformSupport/**/*.swift')].map { |p| p.delete_prefix(root + '/') }
watch_files = Dir[File.join(root, 'Sources/WatchApp/**/*.swift')].map { |p| p.delete_prefix(root + '/') }
widget_files = Dir[File.join(root, 'Sources/Widgets/**/*.swift')].map { |p| p.delete_prefix(root + '/') }
test_files = Dir[File.join(root, 'Tests/**/*.swift')].map { |p| p.delete_prefix(root + '/') }

shared_refs = add_files(project, shared_group, root, shared_files)
ios_refs = add_files(project, ios_group, root, ios_files)
mac_refs = add_files(project, mac_group, root, mac_files)
vision_refs = add_files(project, vision_group, root, vision_files)
platform_refs = add_files(project, platform_group, root, platform_files)
watch_refs = add_files(project, watch_group, root, watch_files)
widget_refs = add_files(project, widgets_group, root, widget_files)
test_refs = add_files(project, tests_group, root, test_files)

ios = project.new_target(:application, 'SCPFoundationIOS', :ios, '18.0')
set_common(ios, settings.merge('PRODUCT_BUNDLE_IDENTIFIER' => 'com.foundation.scp.app', 'PRODUCT_NAME' => 'SCPFoundationIOS', 'INFOPLIST_FILE' => 'Sources/iOSApp/Info.plist', 'TARGETED_DEVICE_FAMILY' => '1,2'))
add_sources(ios, shared_refs + ios_refs)
app_icon = ios_group.new_file('Sources/iOSApp/Assets.xcassets')
app_icon.last_known_file_type = 'folder.assetcatalog'
add_resources(ios, [app_icon])
ios.build_configurations.each do |config|
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
end
ios.add_system_framework('SwiftUI.framework')
ios.add_system_framework('ActivityKit.framework')

widgets = project.new_target(:app_extension, 'SCPFoundationWidgets', :ios, '18.0')
set_common(widgets, settings.merge('PRODUCT_BUNDLE_IDENTIFIER' => 'com.foundation.scp.app.widgets', 'PRODUCT_NAME' => 'SCPFoundationWidgets', 'INFOPLIST_FILE' => 'Sources/Widgets/Info.plist', 'SKIP_INSTALL' => 'YES'))
widget_shared = shared_refs.select { |r| r.path.end_with?('SCPIncidentDoc.swift', 'SCPObject.swift', 'SCPModels.swift', 'LiquidGlassKit.swift') }
add_sources(widgets, widget_shared + widget_refs)
widgets.add_system_framework('SwiftUI.framework')
widgets.add_system_framework('WidgetKit.framework')

a = project.new_target(:application, 'SCPFoundationWatch', :watchos, '10.0')
set_common(a, settings.merge('PRODUCT_BUNDLE_IDENTIFIER' => 'com.foundation.scp.app.watchkitapp', 'PRODUCT_NAME' => 'SCPFoundationWatch', 'INFOPLIST_FILE' => 'Sources/WatchApp/Info.plist'))
watch_shared = shared_refs.select { |r| r.path.end_with?('SCPIncidentDoc.swift', 'SCPObject.swift', 'SCPModels.swift', 'LiquidGlassKit.swift') }
add_sources(a, watch_shared + watch_refs)
a.add_system_framework('SwiftUI.framework')

mac = project.new_target(:application, 'SCPFoundationMac', :osx, '14.0')
set_common(mac, settings.merge('PRODUCT_BUNDLE_IDENTIFIER' => 'com.foundation.scp.app.mac', 'PRODUCT_NAME' => 'SCPFoundationMac', 'INFOPLIST_FILE' => 'Sources/MacApp/Info.plist'))
add_sources(mac, shared_refs + platform_refs + mac_refs)
mac.add_system_framework('SwiftUI.framework')

vision = project.new_target(:application, 'SCPFoundationVision', :ios, '18.0')
set_common(vision, settings.merge('PRODUCT_BUNDLE_IDENTIFIER' => 'com.foundation.scp.app.vision', 'PRODUCT_NAME' => 'SCPFoundationVision', 'INFOPLIST_FILE' => 'Sources/VisionApp/Info.plist', 'SDKROOT' => 'xros', 'SUPPORTED_PLATFORMS' => 'xros xrsimulator', 'XROS_DEPLOYMENT_TARGET' => '2.0', 'TARGETED_DEVICE_FAMILY' => '7'))
add_sources(vision, shared_refs + platform_refs + vision_refs)
vision.add_system_framework('SwiftUI.framework')

tests = project.new_target(:unit_test_bundle, 'SCPFoundationTests', :ios, '18.0')
set_common(tests, settings.merge('PRODUCT_BUNDLE_IDENTIFIER' => 'com.foundation.scp.app.tests', 'PRODUCT_NAME' => 'SCPFoundationTests', 'TEST_HOST' => '$(BUILT_PRODUCTS_DIR)/SCPFoundationIOS.app/SCPFoundationIOS'))
add_sources(tests, test_refs)
tests.add_dependency(ios)

# Embed WidgetKit into iOS app.
phase = ios.new_copy_files_build_phase('Embed Foundation Extensions')
phase.dst_subfolder_spec = '13'
phase.add_file_reference(widgets.product_reference)
ios.add_dependency(widgets)

# Add resources and plist references for Xcode visibility.
['Sources/iOSApp/Info.plist', 'Sources/MacApp/Info.plist', 'Sources/VisionApp/Info.plist', 'Sources/WatchApp/Info.plist', 'Sources/Widgets/Info.plist'].each do |relative|
  group = root_group.new_file(relative)
  group.source_tree = '<group>'
end

project.root_object.product_ref_group = root_group.new_group('Products')
project.save

add_scheme(root, 'SCPFoundationIOS', ios, tests)
add_scheme(root, 'SCPFoundationMac', mac)
add_scheme(root, 'SCPFoundationVision', vision)
add_scheme(root, 'SCPFoundationWatch', a)
puts "Generated #{project_path} with targets: #{project.targets.map(&:name).join(', ')}"
