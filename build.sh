#!/bin/bash
#https://www.sromku.com/blog/build-android-jenkins-types
#https://github.com/sromku/build-android-jenkins/blob/master/scripts-part-2/build.sh

# input params
branchName=$1
productFlavor=$2
buildType=$3
storePass=$4
keyAlias=$5
keyPass=$6


# helper method
setProperty() {
	sed -i.bak -e "s/\($1 *= *\).*/\1$2/" ${propertiesFile}
}

function reportTestResults {
  rm -r report/
  mkdir report
  mkdir report/test-results
  # copy tests results from all modules
  modules=("app")
  for module in "${modules[@]}"
  do
      testsDir="$module/build/test-results/test${productFlavor}${buildType}UnitTest"
      if [ ! "$(ls -A $testsDir)" ]; then
          echo "Unit tests report wasn't found for module: $module"
          continue
      fi
      # copy all files inside, to our folder
      cp $testsDir/* report/test-results/
  done
}

function runUnitTest {
  # run junit test
  ./gradlew "test${productFlavor}${buildType}" --stacktrace

  # terminate build when test failed
  # https://stackoverflow.com/a/26814641/2722270
  if [ ${PIPESTATUS[0]} -ne "0" ]
  then
      echo "test failed with Error: ${PIPESTATUS[0]}"
      reportTestResults
      exit 1
  else
      echo "test successfully!"
  fi
}

function build {
  propertiesFile='gradle.properties'
  chmod +x ${propertiesFile}

  # update key properties based on build type
  if [ $buildType = 'debug' ]; then
  	(setProperty "KEYSTORE" "hello_fastlane_debug.keystore")
  	(setProperty "STORE_PASSWORD" "debug2")
  	(setProperty "KEY_ALIAS" "debug")
  	(setProperty "KEY_PASSWORD" "debug2")
  elif [ $buildType = 'release' ]; then
    (setProperty "KEYSTORE" "hello_fastlane_release.keystore")
    (setProperty "STORE_PASSWORD" "$storePass")
    (setProperty "KEY_ALIAS" "$keyAlias")
    (setProperty "KEY_PASSWORD" "$keyPass")
  fi

  # clean project
  chmod +x gradlew
  ./gradlew clean --stacktrace

  # build
  ./gradlew "assemble${productFlavor}${buildType}" --stacktrace
}

function copyApkToArtifacts {
  apkFileName="app-$productFlavor-$buildType.apk"
  rm -r artifacts/
  mkdir artifacts

  # copy apk to artifacts
  if [ ! -e "app/build/outputs/apk/$productFlavor/$buildType/$apkFileName" ]; then
      echo "ERROR: File not exists: (app/build/outputs/apk/$productFlavor/$buildType/$apkFileName)"
      exit 1
  fi
  cp app/build/outputs/apk/$productFlavor/$buildType/$apkFileName artifacts/
}

# -----------------------------------------------------------------
# -------------------------- TESTS & LINT--------------------------
# -----------------------------------------------------------------
runUnitTest

# -----------------------------------------------------------------
# ------------------------------ BUILD ----------------------------
# -----------------------------------------------------------------
build

# -----------------------------------------------------------------
# -------------------------- POST BUILD ---------------------------
# -----------------------------------------------------------------
copyApkToArtifacts
reportTestResults

cat << "EOF"
EOF