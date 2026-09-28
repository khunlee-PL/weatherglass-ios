# add_odr.rb — wire the language packs into the Xcode project as On-Demand Resources, the native
# plugin into the sources, and the privacy manifest into the resources. Runs in CI after
# `cap add ios` (the project is generated fresh every build, so this is idempotent and re-run).
#
#   · odr/lang/lang-<code>.json  -> Resources build phase with ASSET_TAGS ["lang-<code>"], the tag
#     registered in KnownAssetTags, NOT in the initial install: the App Store hosts it and the device
#     downloads it only when the reader picks that language (native WeatherglassLang.loadLang).
#   · native/WeatherglassLang.swift + MyViewController.swift (copied into ios/App/App/) -> Sources.
#   · native/PrivacyInfo.xcprivacy (copied) -> Resources.
#   · ENABLE_ON_DEMAND_RESOURCES = YES on every configuration.
#
# Uses the xcodeproj gem (ships with CocoaPods on the Codemagic image).

require 'xcodeproj'
require 'json'

project = Xcodeproj::Project.open('ios/App/App.xcodeproj')
target  = project.targets.find { |t| t.name == 'App' } or abort('no App target')
app_group = project.main_group.find_subpath('App', false) || project.main_group
attrs = project.root_object.attributes

# ---- 1. one On-Demand Resource per language pack ----------------------------------------------
manifest = JSON.parse(File.read('www/lang-manifest.json'))
lang_tags = []
Dir.glob('odr/lang/lang-*.json').sort.each do |lf|
  name = File.basename(lf)                       # lang-<code>.json
  code = File.basename(name, '.json').sub('lang-', '')
  abort("#{name} is not in www/lang-manifest.json — the app could never verify it") unless manifest['langs'][code]
  tag  = "lang-#{code}"
  ref = app_group.files.find { |f| f.path && f.path.end_with?(name) }
  unless ref
    ref = app_group.new_reference(File.expand_path(lf))
    ref.name = name
  end
  bf = target.resources_build_phase.files.find { |x| x.file_ref == ref }
  bf ||= target.resources_build_phase.add_file_reference(ref)
  bf.settings ||= {}
  bf.settings['ASSET_TAGS'] = [tag]
  lang_tags << tag
end
abort('no odr/lang/lang-*.json found — run tools/ship_ios.py in the corpus repo') if lang_tags.empty?
manifest['langs'].keys.each do |code|
  abort("manifest names lang-#{code} but odr/lang/lang-#{code}.json is missing") unless lang_tags.include?("lang-#{code}")
end
attrs['KnownAssetTags'] = (Array(attrs['KnownAssetTags']) | lang_tags)

target.build_configurations.each do |cfg|
  cfg.build_settings['ENABLE_ON_DEMAND_RESOURCES'] = 'YES'
  cfg.build_settings['ON_DEMAND_RESOURCES_INITIAL_INSTALL_TAGS'] = ''   # nothing prefetched: download on pick
  cfg.build_settings['ON_DEMAND_RESOURCES_PREFETCH_ORDER'] = ''
end

# ---- 2. the plugin sources (ALL of them — an unregistered plugin ships dead) --------------------
['WeatherglassLang.swift', 'MyViewController.swift'].each do |name|
  swift = "ios/App/App/#{name}"
  abort("#{swift} missing — the copy step did not run") unless File.exist?(swift)
  sref = app_group.files.find { |f| f.path && f.path.end_with?(name) }
  sref ||= app_group.new_reference(name)                 # path relative to the App group (bare filename)
  target.source_build_phase.add_file_reference(sref) unless target.source_build_phase.files.any? { |x| x.file_ref == sref }
end

# ---- 3. the privacy manifest rides as a RESOURCE --------------------------------------------------
priv = 'ios/App/App/PrivacyInfo.xcprivacy'
abort("#{priv} missing — the copy step did not run") unless File.exist?(priv)
pref = app_group.files.find { |f| f.path && f.path.end_with?('PrivacyInfo.xcprivacy') }
pref ||= app_group.new_reference('PrivacyInfo.xcprivacy')
target.resources_build_phase.add_file_reference(pref) unless target.resources_build_phase.files.any? { |x| x.file_ref == pref }

project.save
puts "ODR wired: #{lang_tags.length} language pack(s) (#{lang_tags.sort.join(', ')}), store-hosted, none in the initial install; " \
     "plugin sources added; privacy manifest bundled; KnownAssetTags=#{Array(attrs['KnownAssetTags']).sort.join(',')}"
