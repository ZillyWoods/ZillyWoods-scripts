#!/bin/bash
# https://github.com/ZillyWoods/ZillyWoods-scripts/blob/master/start.sh
# helper script to start zillywoods client

is_update=0
is_found=0

if [[ "$1" == "--update" ]] || [[ "$1" == "update" ]]
then
    is_update=1
    shift
fi

clientname="${1:-ZillyWoods}"
clientlower="${clientname,,}"
clientbinary="${2:-$clientlower}"

gitpath="$HOME/Desktop/git"
reponame="$clientname"
run_client="gdb -ex='set confirm off' "
run_client+="-ex='set pagination off' "
run_client+="-ex=run -ex=bt -ex=quit --args ./$clientbinary"

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

function git_save_pull() {
    if [ "$(git status | tail -n1)" != "nothing to commit, working tree clean" ]
    then
        echo "WARNING: git pull failed! Is your working tree clean?"
        echo "  git status"
        return
    fi
    git pull
}

function get_bam() {
	bam="echo 'Bam not found';exit 1;"
	if [ -x "$(command -v bam)" ]
	then
		bam="bam"
	elif [ -x "$(command -v bam5)" ]
	then
		bam="bam5"
	elif [ -x "$(command -v bam4)" ]
	then
		bam="bam4"
	elif [ -x "$(command -v ../bam)" ]
	then
		bam="../bam"
	elif [ -x "$(command -v ../bam/bam)" ]
	then
		bam="../bam/bam"
	fi
	echo "$bam"
}

function get_build_cmd() {
    local build
	local bam
    if [ "$is_update" == "0" ]
    then
        return
    fi
	bam="$(get_bam)"
    build=""
	if [ "$is_found" == "0" ]
	then
		return
	fi
    if [ -d ../.git ]
    then
		git_save_pull >/dev/null 2>&1
    fi
    if [ -f ../CMakeLists.txt ]
    then
        build="cd .. || exit 1;"
        build+="mkdir -p build && cd build;"
        build+="cmake .. -DCMAKE_BUILD_TYPE=Debug;"
        build+="make -j$(nproc)"
	else
		# bam does two more up
		if [ -f ../../bam.lua ]
		then
            build="cd ../../ || exit 1;"
			build+="$bam"
		fi
    fi
    echo "$build"
}

function launch_client() {
    local build
    build="$(get_build_cmd)"
    echo "-------"
    echo ""
    echo "  cd $(pwd)"
    echo "  $build"
    echo "  $run_client"
    echo ""
    echo "-------"
    eval "$build"
    eval "$run_client"
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
    is_found=1
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
