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
    flutter run --debug
} 
run
# 请帮忙从一行日志中提取··
# 2021-03-31 16:00:00.000 [INFO] [com.xxx.xxx.xxx]

function getLog() {
    local log=$1
    local pattern=$2
    local result=$(echo $log | grep -oE "$pattern")
    echo $result
}