#!/bin/bash
tmp_file=$(mktemp)
tmp_dir=$(mktemp -d)
aufs_dir=$(pwd "$tmp_dir")/aufs3-standalone
dir=(
"Documentation"
"fs"
"include"
)
if [ "$#" -ne 2 ]
then cat << 'EOF'
##############################################################################################
# Использование: make_aufs_patch.sh 'версия aufs' 'полный путь куда класть патчи'            #
# Например:                                                                                  #
# ./make_aufs_patch.sh 3.4 /var/lib/layman/init6/sys-kernel/geek-sources/files/3.4.0/aufs ;) #
##############################################################################################
EOF
exit
fi

file "$2" >/dev/null 2>&1 || mkdir -p "$2"
rm "$2"/* >/dev/null 2>&1
cd $(pwd "$aufs_dir")
git clone git://aufs.git.sourceforge.net/gitroot/aufs/aufs3-standalone.git
cd "$aufs_dir"
git checkout origin/aufs"$1"
rm "$aufs_dir"/include/linux/Kbuild

for i in "${dir[@]}";
	do diff -U 3 -dHrN -- "$tmp_dir" "$aufs_dir"/"$i" >> "$tmp_file";
	sed -i "s:"$tmp_dir":a/"$i":" "$tmp_file";
	sed -i "s:"$aufs_dir":b:" "$tmp_file";
done

patch_file=()
	while read -r ;
	do patch_file+=("$REPLY");
	done < <(/bin/ls "$aufs_dir" | grep patch)
for i in "${patch_file[@]}"; do cp "$aufs_dir"/"$i" "$2";
done

mv "$tmp_file" "$2"/aufs001.patch
ls -1 "$2" > "$2"/patch_list
rm -rf "$tmp_dir"
rm -rf "$aufs_dir"
echo -en "\033[1;32m Enjoy ;) \n"
