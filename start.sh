#!/bin/bash
# https://github.com/ZillyWoods/ZillyWoods-scripts/blob/master/start.sh
# helper script to start zillywoods client

clientname="${1:-ZillyWoods}"
clientlower="${clientname,,}"
clientbinary="${2:-$clientlower}"

gitpath="$HOME/Desktop/git"
reponame="$clientname"
launch_client="gdb -ex='set confirm off' \
                -ex='set pagination off' \
                -ex=run -ex=bt -ex=quit --args ./$clientbinary"

# actually binarys next to data dirs
declare -A aDataPaths

aDataPaths+=(["cmake"]="$clientbinary")
aDataPaths+=(["bam64_dbg"]="x86_64/debug/$clientbinary")
aDataPaths+=(["bam64_rls"]="x86_64/release/$clientbinary")
aDataPaths+=(["bam32_dbg"]="x86_32/debug/$clientbinary")
aDataPaths+=(["bam32_rls"]="x86_32/release/$clientbinary")

function get_path() {
    file=$1
    echo "${file%/*}"
}

function launch_client() {
    echo "-------"
    echo ""
    echo "  cd $(pwd)"
    echo "  $launch_client"
    echo ""
    echo "-------"
    eval "$launch_client"
    exit "$?"
}

function check_data() {
    file=$1
    if [ ! -f "$file" ]
    then
        echo "file does not exist '$file'"
        return
    fi
    echo "file = $file"
    path="$(get_path "$file")"
    if [ ! -d "$path" ]
    then
        echo "Invalid path='$path'. Script is probably broken"
        exit 1
    fi
    cd "$path" || exit 1
    echo "cd into path=$path"
    cd "$path" || exit 1
    launch_client
}

for key in ${!aDataPaths[@]}; do
    file="$gitpath/$reponame/build/${aDataPaths[${key}]}"
    echo "${key} - $file"
    check_data "$file"
done

# last hope use ~.teeworlds/
echo "fallback to home directory"
cd || exit 1
launch_client
