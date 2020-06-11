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


# -----------------------------------------------------------------
# ------------------------------ BUILD ----------------------------
# -----------------------------------------------------------------
propertiesFile='gradle.properties'
chmod +x ${propertiesFile}

# update key properties based on build type
#if [ $buildType = 'debug' ]; then
#elif [ $buildType = 'release' ]; then
#fi
(setProperty "KEYSTORE" "hello_fastlane_release.keystore")
(setProperty "STORE_PASSWORD" "$storePass")
(setProperty "KEY_ALIAS" "$keyAlias")
(setProperty "KEY_PASSWORD" "$keyPass")


# clean project
chmod +x gradlew
./gradlew clean --stacktrace


# build
#if [ $buildType = 'debug' ]; then
#	./gradlew "assemble${productFlavor}Debug" --stacktrace
#elif [ $buildType = 'release' ]; then
#	./gradlew "assemble${productFlavor}Release" --stacktrace
#fi
./gradlew "assemble${productFlavor}${buildType}" --stacktrace


# -----------------------------------------------------------------
# -------------------------- POST BUILD ---------------------------
# -----------------------------------------------------------------
apkFileName="app-$productFlavor-$buildType.apk"
rm -r artifacts/
mkdir artifacts


# copy apk to artifacts
if [ ! -e "app/build/outputs/apk/$productFlavor/$buildType/$apkFileName" ]; then
    echo "ERROR: File not exists: (app/build/outputs/apk/$productFlavor/$buildType/$apkFileName)"
    exit 1
fi
cp app/build/outputs/apk/$productFlavor/$buildType/$apkFileName artifacts/

cat << "EOF"
EOF