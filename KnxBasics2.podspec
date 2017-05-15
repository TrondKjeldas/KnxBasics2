
Pod::Spec.new do |s|


  s.name         = "KnxBasics2"
  s.version      =  "0.0.2"
  s.summary      = "Basic interworking with KNX installation."

  s.description  = <<-DESC
  Basic interworking with KNX installation.
                   DESC

  s.homepage     = "https://EXAMPLE/KnxBasics2"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  s.license      =  { :type => "LGPL V2.1", :file => "LICENSE.md" }


  s.author             = { "Trond Kjeldås" => "trond@kjeldas.no" }

  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  #  When using multiple platforms
   s.ios.deployment_target = "9.0"
   s.osx.deployment_target = "10.11"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "ssh://gax58/local/gitroot/mac/KnxBasics2.git" }


  s.source_files  = "Source/*.swift"
  #s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.framework  = "Foundation"
  # s.frameworks = "CocoaAsyncSocket", "SwiftyBeaver"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"
  s.dependency "CocoaAsyncSocket"
  s.dependency "SwiftyBeaver"
end
