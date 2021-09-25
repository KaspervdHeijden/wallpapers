#!/bin/env sh

if [ "$(id -u)" -eq 0 ]; then
    echo 'do not run as root' >&2;
    return 3;
fi

root_dir="$(git rev-parse --show-toplevel 2>/dev/null)";
if [ ! -d "${root_dir}/wallpapers" ]; then
    echo "not a valid directory: '${root_dir}/wallpapers'" >&2;
    exit 4;
fi

mkdir -p "${HOME}/.config/systemd/user";
if [ ! -d "${HOME}/.config/systemd/user" ]; then
    echo "could not create '${HOME}/.config/systemd/user'" >&2;
    exit 5;
fi

while true; do
    printf 'timeout (in seconds): ';
    read -r interval;

    if ! echo "${interval}" | grep -qE '^[0-9]+$'; then
        echo "not a number: ${interval}" >&2;
    elif [ "${interval}" -lt 30 ]; then
        echo 'number must be at least 30' >&2;
    else
        break;
    fi
done;

printf 'display images randomly? [y/n]: ';
random_flag="$(read -r answer && echo "${answer}" | grep -iq '^y' && echo '-r ')";

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
