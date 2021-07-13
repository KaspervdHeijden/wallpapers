#!/bin/env sh

root_dir="$(git rev-parse --show-toplevel 2>/dev/null)";
random_mode="${2:-1}";
interval="${1:-600}";

if [ -z "${root_dir}" ]; then
    echo 'could not determine root directory' >&2;
    exit 2;
fi

if [ ! -d "${root_dir}/wallpapers" ]; then
    echo "not a valid directory: '${root_dir}/wallpapers'" >&2;
    exit 3;
fi

[ -d "${HOME}/.config/systemd/user" ] || mkdir -p "${HOME}/.config/systemd/user";
if [ ! -d "${HOME}/.config/systemd/user" ]; then
    echo "could not create '${HOME}/.config/systemd/user'" >&2;
    exit 4;
fi

[ -n "${random_mode}" ] && random_mode='-r ';

cat > "${HOME}/.config/systemd/user/wallpaper-rotator.service" <<END_OF_FILE
[Unit]
Description=Wallpaper rotator

[Service]
ExecStart=${root_dir}/scripts/wallpaper-rotator-daemon ${random_mode}-t${interval} -d${root_dir}/wallpapers

[Install]
WantedBy=default.target
END_OF_FILE

systemctl --user daemon-reload 2>/dev/null;
systemctl --user start wallpaper-rotator;
systemctl --user status wallpaper-rotator;
