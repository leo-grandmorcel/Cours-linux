#!/bin/bash
usage() {
        echo "Usage: yt.sh [options] <url>"
        echo " -q <quality> "
        echo " -o <directory> path file"
        echo " -h to show this menu "
        exit
}

if (! (command -v python) && ! (command -v youtube-dl)) &> /dev/null; then
        echo "Get youtube-dl and python"
        exit
fi
if [[ -d "/srv/yt/downloads" && -d "/var/log/yt/" ]]; then
        path="/srv/yt/downloads"
        format="mp4"
        for i in "$@"; do
                if [[ "$i" == "-q" ]]; then
                        path=true
                elif [[ "$i" == "-o" ]]; then
                        format=true
                elif [[ "$i" == "-h" ]]; then
                        echo "Usage : yt.sh [options] url"
                        echo " Options : -q <quality>   -o <directory> File path"
                        exit
                elif [[ $format == true ]]; then
                        format="$i"
                elif [[ $path == true ]]; then
                        path="$i"
                fi
                lien="$i"
        done
        if [[ "$lien" =~ https://www.youtube.com/ ]]; then
                if youtube-dl -e "$lien" &> /dev/null; then
                        title=$(youtube-dl -e "$lien")
                        mkdir "$path/$title" &> /dev/null
                        if (cd "$path/$title" && youtube-dl -f "$format/mp4" "$lien" &>/dev/null); then
                                youtube-dl --get-description "$lien" > "$path/$title/description"
                                echo "Video $lien was downloaded in $format format."
                                echo "File path : $path/$title/$title.mp4"
                                echo "[$(date "+%D %T")]"" Video $lien was downloaded. File path : ""$path/$title/$title.mp4""'" >> "/var/log/yt/download.log"
                        else
                                echo "Video download failed"
				echo "[$(date "+%D %T")]"" Video $lien failed to download.""'" >> "/var/log/yt/download.log"
                                usage
                        fi
                else
			echo "[$(date "+%D %T")]"" Link $lien is not working.""'" >> "/var/log/yt/download.log"
                        echo "Link not working"
                        usage
                fi
        else
		echo "[$(date "+%D %T")]"" Wrong URL : $lien""'" >> "/var/log/yt/download.log"
                echo "wrong URL"
                usage
        fi
else
        echo "Dossier manquant"
fi
