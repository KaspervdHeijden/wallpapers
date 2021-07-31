#!/bin/env sh

root_dir="$(git rev-parse --show-toplevel 2>/dev/null)";
if [ -z "${root_dir}" ]; then
    echo 'could not determine root directory' >&2;
    exit 2;
fi

if [ ! -d "${root_dir}/wallpapers" ]; then
    echo "not a valid directory: '${root_dir}/wallpapers'" >&2;
    exit 3;
fi

mkdir -p "${HOME}/.config/systemd/user";
if [ ! -d "${HOME}/.config/systemd/user" ]; then
    echo "could not create '${HOME}/.config/systemd/user'" >&2;
    exit 4;
fi

while true; do
    read -p 'timeout (in seconds): ' interval;
    if ! echo "${interval}" | grep -qE '^[0-9]+$'; then
        echo "not a number: ${interval}" >&2;
    elif [ "${interval}" -lt 30 ]; then
        echo 'number must be at least 30' >&2;
    else
        break;
    fi
done;

random_flag="$(read -p 'display images randomly? [y/n]: ' answer; echo "${answer}" | grep -iq '^y' && echo '-r ')";
cat > "${HOME}/.config/systemd/user/wallpaper-rotator.service" <<END_OF_FILE
[Unit]
Description=Wallpaper rotator

[Service]
ExecStart=${root_dir}/scripts/wallpaper-rotator-daemon ${random_flag}-t${interval} -d${root_dir}/wallpapers

[Install]
WantedBy=default.target
END_OF_FILE

systemctl --user daemon-reload 2>/dev/null;
systemctl --user enable wallpaper-rotator;
systemctl --user start wallpaper-rotator;
systemctl --user status wallpaper-rotator;
