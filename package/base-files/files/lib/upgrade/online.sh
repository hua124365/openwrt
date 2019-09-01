#!/bin/sh

. /etc/openwrt_release
. /etc/os-relase
. /usr/share/libubox/jshn.sh

# downloads file and check if sha256sum matches
download_and_checksum() {
	# $1 URL to download
	# $2 sha256sum
	rm -f "$(basename $1)"
	wget "$1" || exit 1
	if [ "$(sha256sum $(basename $1) | cut -d ' ' -f 1)" != "$2" ]; then
		>&2 echo "$(basename $1): bad checksum"
		>&2 echo "URL: $1"
		>&2 echo "expected: $2"
		exit 1
	fi
}

download_and_signature() {
	# $1 URL to download
	rm -f "$(basename $1)"
	wget "$1" || exit 1
	wget "$1.sig" || exit 1
	if ! usign -V -P /etc/opkg/keys -m $(basename "$1"); then
		>&2 echo "$(basename $1): bad signature"
		>&2 echo "URL: $1"
		exit 1
	fi
}

# strip revision to a comparable integer
revision_count() {
	# $1 revision commit
	echo "$1" | cut -d "-" -f 0 | cut -d "+" -f 0 | tail -c +2
}

# check if found version is upgrdable
# TODO: currently only checks snapshots for newer revision
upgradable() {
	version="$1"
	revision="$2"
	if [ "$version" = "SNAPSHOT" ] &&  [ "$DISTRIB_RELEASE" = "SNAPSHOT" ]; then
		if [ $(revision_count "$revision") -gt $(revision_count "$DISTRIB_REVISION") ]; then
			>&2 echo "SNAPSHOT upgrade to $revision found"
			echo 1
		fi
	fi
}

# searches for new sysupgrades
sysupgrade_search() {
	cd /tmp || exit 1
	rm versions.json*
	download_and_signature "$HOME_URL/versions.json"

	json_load_file versions.json
	json_get_var metadata_version metadata_version
	json_select versions

	idx="1"
	while json_get_type Type "$idx" && [ "$Type" == object ]; do
		json_select "$idx"
		json_get_vars name revision
		if [[ -n "$(upgradable $name $revision)" ]]; then
			json_get_vars path sha256

			json_init
			json_add_string name "$name"
			json_add_string path "$path"
			json_add_string revision "$revision"
			json_add_string sha256 "$sha256"
			json_dump
			exit 0
		fi
		json_select ..
		$((idx++)) 2> /dev/null
	done

	json_init
	json_dump
	cd - || exit 1
}

# find sysupgrade file for board
sysupgrade_download() {
	cd /tmp || exit 1
	path_version="$1"
	sha256_targets="$2"
	json_load "$(ubus call system board)"
	json_get_vars board_name

	download_and_checksum "$HOME_URL/$path_version/$OPENWRT_BOARD/profiles.json" "$sha256_targets"

	json_load_file profiles.json
	json_get_var metadata_version metadata_version
	json_select profiles
	json_select "$board_name"
	json_select "images"

	idx="1"
	while json_get_type Type "$idx" && [ "$Type" == object ]; do
		json_select "$idx"
		json_get_var type type
		[[ "$type" == "sysupgrade" ]] && break
		json_select ..
		$((idx++)) 2> /dev/null
	done

	json_get_var sysupgrade name
	json_get_var sha256 sha256

	download_and_checksum "$HOME_URL/$path_version/$path_target/$sysupgrade" "$sha256"

	json_init
	json_add_int "successful" 1
	json_add_string "firmware" "$sysupgrade"
	json_close_object
	json_dump
	cd - || exit 1
}

# combines search, download and sysupgrade
sysupgrade_unattended() {
	search_response="$(sysupgrade_search)"

	if [ "$search_response" != "{ }" ]; then
		>&2 echo "No sysupgrade found"
		exit 0
	fi

	json_load "$search_response"
	json_get_vars path sha256
	download_response="$(sysupgrade_download $path $sha256)"
	json_load "$download_response"
	json_get_vars successful firmware
	if [ "$successful" -gt 0 ]; then
		# TODO don't to anything really
		sysupgrade -T "$firmware"
	fi
	exit $?
}
