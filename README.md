# Hello Fastlane



## Running Android tests using fastlane

Add a test lane in Fastfile:

```ruby
  desc "Runs all the tests"
  lane :test do
    gradle(task: "test")
    gradle(task: "connectedAndroidTest")
  end
```

To use the newly created test lane, just run

`$ fastlane test`

Then you will see the result printed:

```xml
+------+----------------------+-------------+
|             fastlane summary              |
+------+----------------------+-------------+
| Step | Action               | Time (in s) |
+------+----------------------+-------------+
| 1    | default_platform     | 0           |
| 2    | test                 | 3           |
| 3    | connectedAndroidTest | 83          |
+------+----------------------+-------------+
```

Further read:

- `test`:  Run unit tests for all variants.
- `connectedAndroidTest`: Installs and runs instrumentation tests for all flavors on connected devices.

you can run `./gradlew tasks` to get a list of tasks with all build types and flavors. Refer to [Running unit tests with Gradle](https://developer.android.com/studio/test/command-line)

Add androidTest`VariantName` folders where you can add test cases specific to each one of your flavors to fix androidTest failure: 

```xml
useAppContext 
org.junit.ComparisonFailure: expected:<...droid.hello_fastlane[]> but was:<...droid.hello_fastlane[.dev]>
```



## Beta Release to Firebase App Distribution

Make sure you have already setup your Firebase project, added your app to firebase project,  onboard your app by pressing the "Get started" button on the App Distribution page.   

Then you can follow the doc to setup Firebase CLI, refer:

- [Distribute Android apps to testers using fastlane](https://firebase.google.com/docs/app-distribution/android/distribute-fastlane), also explains parameters used in `firebase_app_distribution` section in the following code snippet:
- [Fastlane Action: build_android_app](https://docs.fastlane.tools/actions/build_android_app/), also explains parameters used in `gradle` section in the following code snippet:

Add a UAT beta release lane in Fastfile:

```ruby
  desc "Submit a new Beta Build to Firebase App Distribution"
  lane :uat do
    gradle(
      task: "assemble",
      flavor: "Uat",
      build_type: "Release",
      print_command: false,
      properties: {
        "versionCode" => 1,
        "versionName" => "1.0.0",
        "android.injected.signing.store.file" => "keystore.jks",
        "android.injected.signing.store.password" => ENV["STORE_PASSWORD"],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"],
      }
    )
    firebase_app_distribution(
        app: "1:123456789:android:abcd1234",
        testers: "tester1@company.com, tester2@company.com",
        release_notes: "Lots of amazing new features to test out!",
    )
  end
```

To avoid having private key info hardcoded in Fastfile, you can use environment variables as showed above, refer

- [Fastlane Action: environment_variable](https://docs.fastlane.tools/actions/environment_variable/)
- [Android Continuous Integration using Fastlane and CircleCI 2.0 — Part III](https://medium.com/pink-room-club/android-continuous-integration-using-fastlane-and-circleci-2-0-part-iii-ccdf5b83d8f5)
- [How to add permanent environment variable in zsh](https://apple.stackexchange.com/questions/356441/how-to-add-permanent-environment-variable-in-zsh) Note: Although I use zsh, add the env val to `.bash_profile` works for me, not `.zshenv`

To use the newly created beta release lane, just run

`$ fastlane uat`

which will generate APK, sign it, upload to Firebase App Distribution:

```xml
+------+---------------------------+-------------+
|                fastlane summary                |
+------+---------------------------+-------------+
| Step | Action                    | Time (in s) |
+------+---------------------------+-------------+
| 1    | default_platform          | 0           |
| 2    | assembleuatrelease        | 3           |
| 3    | firebase_app_distribution | 16          |
+------+---------------------------+-------------+

[20:09:18]: fastlane.tools finished successfully 🎉
```