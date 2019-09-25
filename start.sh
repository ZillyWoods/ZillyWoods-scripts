#!/bin/bash
# helper script to start zillywoods client
# actually more designed for personal use
# it attempts to fix the ressource loading problem in a hacky way
# future releases or properly installed ones do not need this script

gitpath="~/Desktop/git"
reponame="ZillyWoods"

# actually binarys next to data dirs
declare -A aDataPaths

aDataPaths+=(["cmake"]="zillywoods")
aDataPaths+=(["bam64_dbg"]="build/x86_64/debug/zillywoods")
aDataPaths+=(["bam64_rls"]="build/x86_64/release/zillywoods")
aDataPaths+=(["bam32_dbg"]="build/x86_32/debug/zillywoods")
aDataPaths+=(["bam32_rls"]="build/x86_32/release/zillywoods")

function get_path() {
    file=$1
    echo ${file##*/}
}

function check_data() {
    file=$1
    if [ ! -f "$file" ]
    then
        return
    fi
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
    file="$gitpath/$reponame/${aDataPaths[${key}]}"
    echo "${key} - $file"
    check_data $file
done

# last hope use ~.teeworlds/
cd
zillywoods

