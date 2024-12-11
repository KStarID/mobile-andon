Write-Host "Updating patch..."
flutter pub run cider bump patch
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Updating version..."
flutter pub run cider bump build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Building APK..."
flutter build apk
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Build completed successfully!"