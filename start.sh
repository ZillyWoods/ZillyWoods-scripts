#!/bin/bash
# helper script to start zillywoods client

gitpath="$HOME/Desktop/git"
reponame="ZillyWoods"

# actually binarys next to data dirs
declare -A aDataPaths

aDataPaths+=(["cmake"]="zillywoods")
aDataPaths+=(["bam64_dbg"]="x86_64/debug/zillywoods")
aDataPaths+=(["bam64_rls"]="x86_64/release/zillywoods")
aDataPaths+=(["bam32_dbg"]="x86_32/debug/zillywoods")
aDataPaths+=(["bam32_rls"]="x86_32/release/zillywoods")

function get_path() {
    file=$1
    echo ${file%/*}
}

function check_data() {
    file=$1
    if [ ! -f "$file" ]
    then
        echo "file does not exist '$file'"
        return
    fi
    echo "file = $file"
    path=$(get_path $file)
    if [ ! -d "$path" ]
    then
        echo "Invalid path='$path'. Script is probably broken"
        exit 1
    fi
    cd $path
    echo "cd into path=$path"
    cd "$path"
    zillywoods
    exit 0
}

for key in ${!aDataPaths[@]}; do
    file="$gitpath/$reponame/build/${aDataPaths[${key}]}"
    echo "${key} - $file"
    check_data $file
done

# last hope use ~.teeworlds/
echo "fallback to home directory"
cd
zillywoods
