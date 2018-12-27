Pod::Spec.new do |s|

  s.name         = "PBPopupController"
  s.version      = "0.1.0"
  s.summary      = "PBPopupController is a framework for presenting view controllers as popups."

  s.description  = <<-DESC
    PBPopupController is a framework for presenting view controllers as popups, much like the Apple Music and Podcasts apps.
    DESC

    s.homepage     = "https://github.com/iDevelopper/PBPopupController"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "iDevelopper" => "patrick.bodet4@wanadoo.fr" }
  # Or just: s.author    = "iDevelopper"
  # s.authors            = { "iDevelopper" => "patrick.bodet4@wanadoo.fr" }
  # s.social_media_url   = "http://twitter.com/iDevelopper"

  s.platform     = :ios
  s.platform     = :ios, "9.3"

  s.source       = { :git => "https://github.com/iDevelopper/PBPopupController.git", :tag => "#{s.version}" }

  s.source_files  = "PBPopupController/**/*.{swift,h,m}"
  s.exclude_files = "PBPopupController/CGMathSwift"

  s.swift_version = '4.2'

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  s.resources = "PBPopupController/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
