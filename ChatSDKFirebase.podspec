Pod::Spec.new do |s|
  s.name             = "ChatSDKFirebase"
  s.version          = "4.10.2"
  s.summary          = "Chat SDK - Mobile messaging framework for iOS"
  s.homepage         = "http://chatsdk.co"
  s.license          = { :type => 'Chat SDK License', :file => 'LICENSE.md' }
  s.author           = { "Ben Smiley" => "ben@chatsdk.co" }
  s.source           = { :git => "https://github.com/chat-sdk/chat-sdk-ios.git", :tag => s.version.to_s }
#   s.module_name      = 'ChatSDKFirebase'

  s.platform     = :ios, '9.0'
  s.requires_arc = true
  
  s.default_subspec = 'Adapter'
  
  s.static_framework = true
  s.pod_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }


 s.subspec 'Adapter' do |fb|

	fb.source_files = ['ChatSDKFirebase/FirebaseNetworkAdapter/Classes/**/*']
	
    fb.dependency 'Firebase/Auth'
    fb.dependency 'Firebase/Database'
 
	fb.dependency 'ChatSDK'
  
  end

 s.subspec 'FileStorage' do |ffs|

	ffs.source_files = ['ChatSDKFirebase/FirebaseFileStorage/Classes/**/*']

    ffs.dependency 'Firebase/Storage'
	ffs.dependency 'ChatSDKFirebase/Adapter'
  
  end

 s.subspec 'Push' do |fp|

	fp.source_files = ['ChatSDKFirebase/FirebasePush/Classes/**/*']

    fp.dependency 'Firebase/Messaging'
    fp.dependency 'Firebase/Functions'
	fp.dependency 'ChatSDKFirebase/Adapter'

  end

   s.subspec 'ReadReceipts' do |rr|

    rr.source_files = ['ChatSDKFirebase/ReadReceipts/Classes/**/*']
    rr.resource_bundles = {
      'ChatReadReceipts' => ['ChatSDKFirebase/ReadReceipts/Assets/**/*', 'ChatSDKFirebase/ReadReceipts/Interface/**/*']
    }

    rr.dependency 'ChatSDK/Core'
    rr.dependency 'ChatSDKFirebase/Adapter'
    rr.dependency 'ChatSDK/UI'

  end

   s.subspec 'AudioMessages' do |am|

    am.source_files = ['ChatSDKFirebase/AudioMessages/Classes/**/*']
    am.resource_bundles = {
      'ChatAudioMessages' => ['ChatSDKFirebase/AudioMessages/Assets/**/*', 'ChatSDKFirebase/AudioMessages/Interface/**/*']
    }
    
    am.dependency 'ChatSDK/Core'
    am.dependency 'ChatSDKFirebase/Adapter'
    am.dependency 'ChatSDK/UI'

  end

    s.subspec 'Blocking' do |blo|

    blo.source_files = ['ChatSDKFirebase/Blocking/Classes/**/*']
    blo.resource_bundles = {
      'ChatBlocking' => ['ChatSDKFirebase/Blocking/Assets/**/*', 'ChatSDKFirebase/Blocking/Interface/**/*']
    }

    blo.dependency 'ChatSDK/Core'
    blo.dependency 'ChatSDKFirebase/Adapter'

  end


 s.subspec 'FirebaseUI' do |f|

	f.source_files = ['ChatSDKFirebase/FirebaseUI/Classes/**/*']

	f.dependency 'ChatSDKFirebase/Adapter'
	f.dependency 'FirebaseUI/Auth'

  end
  
 s.subspec 'SocialLogin' do |fsl|

	fsl.source_files = ['ChatSDKFirebase/FirebaseSocialLogin/Classes/**/*']
	fsl.resource_bundles = {
	  'ChatFirebaseSocialLogin' => ['ChatSDKFirebase/FirebaseSocialLogin/Assets/**/*']
	}
	
# 	fsl.dependency 'TwitterKit', '<3.3.0'
# 	fsl.dependency 'TwitterCore', '<3.1.0'
 	fsl.dependency 'TwitterKit' 
 	fsl.dependency 'TwitterCore' 
    fsl.dependency 'GoogleSignIn'
    fsl.dependency 'FBSDKLoginKit'

	fsl.dependency 'ChatSDKFirebase/Adapter'
	fsl.dependency 'ChatSDK'

  end
      
end