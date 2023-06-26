# compile current flutter project in shell script
# run the compile result app in shell script

compile() { 
    echo "compile flutter project"
    flutter clean
    flutter pub get
    flutter pub run build_runner build --delete-conflicting-outputs
}
compile
run() {
    echo "run flutter project"
    flutter create --platforms=macos .
    sed -i '' 's/= 10.11/=13.3.1/g' ./macos/Pods/Pods.xcodeproj/project.pbxproj 
    flutter build macos
} 
run
