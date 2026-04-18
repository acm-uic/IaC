#!/usr/bin/env sh


profile_loc="${XDG_CONFIG_HOME:-$HOME/.config}/profile.d"
if test -d "$profile_loc"; then
    empty="$(ls $profile_loc/*.sh)"
    if test -n "$empty"; then
	. $profile_loc/*.sh
    fi
fi


