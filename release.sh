source ./VERSION.sh
echo "###### Misstory Release $VERSION_NAME($VERSION_NUMBER) ######"

set -

echo "\n\n"
echo ">>>>>> Run Tests <<<<<<"
flutter test

echo "\n\n"
echo ">>>>>> Build Android <<<<<<"
flutter build apk --release --build-name="$VERSION_NAME" --build-number="$VERSION_NUMBER"

echo "\n\n"
echo ">>>>>> Build iOS <<<<<<"
flutter build ios --no-codesign --release --build-name="$VERSION_NAME" --build-number="$VERSION_NUMBER"

echo "\n\n"
echo ">>>>>> Save build files <<<<<<"
ls -la ./build/app/outputs/*

echo "\n\n"
echo "Write Current Build to VERSION.sh file"
# sed -i "s/^BUILD_NUMBER=.*$/BUILD_NUMBER=$VERSION_NUMBER/g" ./VERSION.sh
