#!/bin/sh

check_dependency()
{
	if ! type cmus 1> /dev/null; then
		echo "Cmus is not installed!"
		echo ""
		echo "Cmus is available on most package managers"
	
	elif ! type curl 1> /dev/null; then
		echo "Curl is not installed !"
		echo ""
		echo "Curl is available on most package managers"
		
	elif ! type glyrc 1> /dev/null; then
		echo "glyr is not installed !"
		echo ""
		echo "glyr is available on most package managers"

	else
		echo "dependencies validated"
	fi
}

check_cmus()
{
	CMUS_STATUS="cmus-remote -Q 2> /dev/null"
	if [[ ! $CMUS_STATUS ]]; then 
		echo "cmus is not running"
	else 
		echo "fetching music informations"
		TITLECOMMAND=$(cmus-remote -Q | grep title)
		TITLE=${TITLECOMMAND/tag title }
		TITLE=${TITLE// /-}
		ARTISTCOMMAND=$(cmus-remote -Q | grep -m 1 artist)
		ARTIST=${ARTISTCOMMAND/tag artist }

	fi
}

check_lyrics_directory()
{
	lyric_directory="$HOME/Music/lyfetch"
	if [[ ! -d "$lyric_directory" ]]; then
		echo "creating $(lyric_directory)"
		mkdir -p $lyric_directory
	else
		echo "directory already exists"
	fi
}

get_ovh_lyrics()
{

	OVH_FILE="$lyric_directory/tmp"
	if [[ ! -f $OVH_FILE ]]; then
		# echo "curl https://api.lyrics.ovh/v1/$ARTIST/$TITLE -o $OVH_FILE 1> /dev/null"
		curl "https://api.lyrics.ovh/v1/$ARTIST/$TITLE" -o "$OVH_FILE" > /dev/null
		format_ovh_lyrics
	else
		echo "something's not right..."
	fi
}

get_glyr_lyrics()
{
	GLYR_FILE="$lyric_directory/glyr_lyrics"
	glyrc --write $GLYR_FILE lyrics -a "$ARTIST" -t "TITLE" > /dev/null
	if [[ -f $GLYR_FILE ]]; then 
		cat $GLYR_FILE
	fi

}

format_ohv_lyrics()
{
	lyrics="$lyric_directory/lyrics"
	perl -pe 's#\\r#\r#g' $OVH_FILE | perl -pe 's#\\n#\n#g' $OVH_FILE >> $lyrics
}

show_lyrics()
{
	# termite -e "vim $lyrics"
	clear
	cat "$lyrics"
	rm -r "$lyric_directory"
}

exit_cmus() 
{
	if type cmus > /dev/null 2>&1; then 
		rm $lyrics $OVH_FILE
	fi
}

check_dependency
check_cmus
check_lyrics_directory
get_lyrics
show_lyrics
