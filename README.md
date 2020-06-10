# Hello Fastlane



## Running Android tests using fastlane

Two main test tasks: refer to [Running unit tests with Gradle](https://developer.android.com/studio/test/command-line)

- `test`
- `connectedAndroidTest`

Run `./gradlew tasks` to get a list of tasks with all build types and flavors.

Add androidTest`VariantName` folders where you can add test cases specific to each one of your flavors to fix androidTest failure: 

```xml
useAppContext 
org.junit.ComparisonFailure: expected:<...droid.hello_fastlane[]> but was:<...droid.hello_fastlane[.dev]>
```

`$ fastlane test`

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