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

function publishJUnitTestResults {
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

function runJUnitTest {
  # run junit test
  ./gradlew "test${productFlavor}${buildType}" --stacktrace

  # terminate build when test failed
  # https://stackoverflow.com/a/26814641/2722270
  if [ ${PIPESTATUS[0]} -ne "0" ]
  then
      echo "test failed with Error: ${PIPESTATUS[0]}"
      publishJUnitTestResults
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

function archiveArtifacts {
  rm -r artifacts/
  mkdir artifacts

  apkFilePath="app/build/outputs/apk/$productFlavor/$buildType/*-$productFlavor-$buildType*.apk"
  mappingPath="app/build/outputs/mapping/$productFlavor$buildType/mapping.txt"

  # Check if a file exists with wildcard in shell script
  # https://stackoverflow.com/a/6364244/2722270
  if ls $apkFilePath 1> /dev/null 2>&1; then
    # copy apk to artifacts
    cp $apkFilePath artifacts/
    # rename: append git sha
    # ${applicationId}-v${versionName}(${versionCode}-${productFlavor}-${buildType}-${gitsha})
    GIT_SHA=$(git rev-parse --short HEAD)
    for apk in artifacts/*.apk
    do
      apkFileName=$(echo "${apk%.*}")
      mv $apk "$apkFileName-$GIT_SHA.apk"
    done
  else
      echo "ERROR: Apk not exists: ($apkFilePath)"
      exit 1
  fi

  if ls $mappingPath 1> /dev/null 2>&1; then
    # copy apk to artifacts
    cp $mappingPath artifacts/
  else
      echo "ERROR: mappping.txt not exists: ($mappingPath)"
      exit 1
  fi
}

# -----------------------------------------------------------------
# -------------------------- TESTS & LINT--------------------------
# -----------------------------------------------------------------
runJUnitTest

# -----------------------------------------------------------------
# ------------------------------ BUILD ----------------------------
# -----------------------------------------------------------------
build

# -----------------------------------------------------------------
# -------------------------- POST BUILD ---------------------------
# -----------------------------------------------------------------
archiveArtifacts
publishJUnitTestResults

cat << "EOF"
EOF