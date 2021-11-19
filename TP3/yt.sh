if [[ -d "/srv/yt/downloads" && -d "/var/log/yt/" ]]; then 
	title=$(youtube-dl -e $1) 
	mkdir "/srv/yt/downloads/$title"
	youtube-dl -o "/srv/yt/downloads/$title/$title.mp4" --format mp4 $1 > /dev/null
	youtube-dl --get-description $1 > "/srv/yt/downloads/$title/description"
	echo "Video $1 was downloaded"
	echo "File path : /srv/yt/downloads/$title/$title.mp4"
	echo "[$(date "+%D %T")]"" Video $1 was downloaded. File path : ""/srv/yt/downloads/$title/$title.mp4""'" >> "/var/log/yt/download.log"
else
	echo "Pas trouvé"
	exit
fi
