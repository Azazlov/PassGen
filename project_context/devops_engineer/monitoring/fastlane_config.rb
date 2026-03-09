# Fastlane Configuration for Automated Deployments
# Install: brew install fastlane
# Setup: cd android && fastlane init

default_platform: :android

platform :android do
  desc "Build and deploy to Google Play Internal Testing"
  lane :internal do
    build_android_app
    upload_to_play_store(
      track: 'internal',
      aab: 'build/app/outputs/bundle/release/app-release.aab',
      skip_upload_apk: false,
      skip_upload_changelog: true,
      skip_upload_screenshots: true
    )
  end

  desc "Build and deploy to Google Play Beta"
  lane :beta do
    build_android_app
    upload_to_play_store(
      track: 'beta',
      aab: 'build/app/outputs/bundle/release/app-release.aab',
      skip_upload_apk: false
    )
  end

  desc "Build and deploy to Google Play Production"
  lane :production do
    build_android_app
    upload_to_play_store(
      track: 'production',
      aab: 'build/app/outputs/bundle/release/app-release.aab',
      skip_upload_apk: false
    )
  end

  desc "Build APK"
  lane :apk do
    build_android_app(
      build_type: 'apk',
      output_directory: 'build/app/outputs/flutter-apk',
      output_name: 'app-release.apk'
    )
  end

  desc "Build App Bundle"
  lane :aab do
    build_android_app(
      build_type: 'aab',
      output_directory: 'build/app/outputs/bundle/release',
      output_name: 'app-release.aab'
    )
  end

  desc "Deploy to Firebase App Distribution"
  lane :firebase do
    build_android_app
    firebase_app_distribution(
      app: ENV['FIREBASE_APP_ID'],
      groups: 'testers',
      release_notes: 'New build from Fastlane'
    )
  end
end

platform :ios do
  desc "Build and deploy to TestFlight"
  lane :beta do
    build_ios_app(
      workspace: 'ios/Runner.xcworkspace',
      scheme: 'Runner',
      export_method: 'app-store'
    )
    upload_to_testflight(
      ipa: 'build/ios/ipa/Runner.ipa',
      skip_waiting_for_build_processing: false
    )
  end

  desc "Deploy to Firebase App Distribution"
  lane :firebase do
    build_ios_app
    firebase_app_distribution(
      app: ENV['FIREBASE_APP_ID'],
      groups: 'testers',
      release_notes: 'New build from Fastlane'
    )
  end
end
