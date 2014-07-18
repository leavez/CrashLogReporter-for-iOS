

Pod::Spec.new do |s|


  s.name         = "RMCrashLogReporter"
  s.version      = "0.0.1"
  s.summary      = "RMCrashLogReporter. A crashlog reporter"

  s.description  = <<-DESC
                    RMCrashLogReporter. A crashlog reporter lib for iOS.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://EXAMPLE/RMCrashLogReporter"

  s.license      = { :type => "MIT" }

  
  s.author       = { "高佶" => "ji.gao@renren-inc.com" }

  s.platform     = :ios

  s.source       = { :git => "https://github.com/leavez/MyPaper.git", :tag => "v1.0" }
  

  s.source_files = "MyPaper/"
  s.public_header_files = "/MyPaper/RMCrashLogReporter.h","MyPaper/RMCrashLogMacro.h"
  s.exclude_files = "MyPaper/RMAppDelegate.{h.m}","MyPaper/RMViewController.{h.m}","MyPaper/MyPaper-Info.plist","MyPaper/MyPaper-Prefix.pch","MyPaper/main.m","MyPaper/Base.lproj","MyPaper/en.lproj","MyPaper/Images.xcassets","MyPaper/RMThreadName.{h,c}"
  s.requires_arc = true

  s.subspec 'noARC' do |noARC|
    noARC.source_files = "MyPaper/RMThreadName.{h,c}"
    noARC.public_header_files = ""
    noARC.requires_arc = false
  end
  
  s.resources  = "MyPaper/CrashReporter.framework"
  s.frameworks = "CrashReporter","UIkit","SystemConfiguration"
  s.vendored_frameworks = "MyPaper/CrashReporter.framework"

end
















