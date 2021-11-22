#!/bin/bash
while true; do
    if [[ -d "/srv/yt/downloads" && -d "/var/log/yt/" && -s "/srv/yt/url" ]]; then 
        while read -r line < /srv/yt/url; do
            if [[ "$line" =~ https://www.youtube.com/ ]]; then
                if youtube-dl -e "$line" &> /dev/null; then
                    title=$(youtube-dl -e "$line") 
                    mkdir "/srv/yt/downloads/$title"
                    youtube-dl -o "/srv/yt/downloads/$title/$title.mp4" --format mp4 "$line" > /dev/null
                    youtube-dl --get-description "$line" > "/srv/yt/downloads/$title/description"
                    echo "Video $line was downloaded"
                    echo "File path : /srv/yt/downloads/$title/$title.mp4"
                    echo "[$(date "+%D %T")]"" Video $line was downloaded. File path : ""/srv/yt/downloads/$title/$title.mp4""'" >> "/var/log/yt/download.log"
                    sed -i '1d' /srv/yt/url
                else
                    echo "[$(date "+%D %T")]""$line is not a working url""'" >> "/var/log/yt/download.log"
                    sed -i '1d' /srv/yt/url
                fi
            else 
                echo "[$(date "+%D %T")]"" Wrong URL : $line""'" >> "/var/log/yt/download.log"
                echo "wrong URL"
            fi
        done
    fi
    sleep 5s
done