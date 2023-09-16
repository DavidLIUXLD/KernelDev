#/bin/bash
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

make clean

build_dir="build"
bin_dir="bin"
l2_arr=("idt" "io" "memory" "string")
if [ ! -d "./$build_dir" ]; then
    mkdir "$build_dir"
fi

if [ ! -d "./$bin_dir" ]; then
    mkdir "$bin_dir"
fi

for var in ${l2_arr[@]}; do
if [ ! -d "./$build_dir/$var" ]; then
        mkdir "./$build_dir/$var"
    fi
done

make all