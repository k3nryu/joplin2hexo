#!/bin/bash

function SrvCheck {
	curl -so $hexo_dir/tmp/ping.json http://localhost:$joplin_srv_port/ping > $hexo_dir/tmp/ping.json
	if [ `grep -c "JoplinClipperServer" $hexo_dir/tmp/ping.json` -ne '0' ];then
	#if [ `cat $hexo_dir/tmp/ping.json` =~ Joplin ];then
		echo JoplinClipperServer Connected!
		echo
	else
		echo Connection failed!
		echo
		exit
	fi
}

function TokenCheck {
	curl -so $hexo_dir/tmp/auth.json http://localhost:$joplin_srv_port/auth/check/\?token\=$joplin_srv_token
	if [ `grep -c "true" $hexo_dir/tmp/auth.json` -ne '0' ];then
	#if [ `cat $hexo_dir/tmp/auth.json` =~ true ];then
		echo Token is valid!
		echo
	else
		echo Token is invald!
		echo
        	exit
	fi
}

function ReadConfig {
	if [[ -e "$1" ]];then
	        source $1
		echo -e 'The following parameters were successfully obtained:'
		echo hexo_dir=$hexo_dir
		echo joplin_srv_location=$joplin_srv_location
		echo joplin_srv_user=$joplin_srv_user
		echo joplin_srv_ip=$joplin_srv_ip
		echo joplin_srv_port=$joplin_srv_port
		echo joplin_srv_token=$joplin_srv_token
		echo joplin_rsc_dir=$joplin_rsc_dir
		echo ---
	else
		echo -e "User profile[$1] not found.\nPlease enter your Joplin server location(remote|local):"
		echo '#!bin/bash' >> $1
	        read joplin_srv_location
	        echo joplin_srv_location=$joplin_srv_location
		echo hexo_dir=$hexo_dir >> $1
		if [[ $joplin_srv_location == "remote" ]];then
	        	echo -e "Please enter your Joplin server user name:"
	        	read joplin_srv_user
			echo joplin_srv_user=$joplin_srv_user >> $1
	        	echo -e "Please enter your Joplin server IP:"
	        	read joplin_srv_ip
			echo joplin_srv_ip=$joplin_srv_ip >> $1
			echo -e "Please enter your Joplin server port(Defalt:41184):"
			read joplin_srv_port
			echo joplin_srv_port=$joplin_srv_port >> $1
	        	echo -e "Please enter your Joplin server token:"
	        	read joplin_srv_token
			echo joplin_srv_token=$joplin_srv_token >> $1
	        	echo -e "Please enter your Joplin server OS(mac or win):"
	        	read joplin_os
	        	if [[ $joplin_os == win ]];then
	        	        joplin_rsc_dir=$joplin_srv_user@$joplin_srv_ip:/C:/Users/$joplin_srv_user/.config/joplin-desktop/resources/
				echo joplin_rsc_dir=$joplin_rsc_dir >> $1
	        	elif [[ $joplin_os == mac ]];then
	        	        joplin_rsc_dir=$joplin_srv_user@$joplin_srv_ip:/Users/$joplin_srv_user/.config/joplin-desktop/resources/
				echo joplin_rsc_dir=$joplin_rsc_dir >> $1
	        	else
	        	        echo - "Input error!"
	        	fi
		fi
	fi
}

function GetNoteBody {
<<GetNoteBody
Get note body(json format) by note id.
GetNoteBody
	curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2?token=$joplin_srv_token\&fields=body
}

function GetNoteTitle {
<<GetNoteTitle
Get note title(json format) by note id.
GetNoteTitle
	curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2?token=$joplin_srv_token\&fields=title
}

function GetNoteDate {
<<GetNoteDate
Get note created date(json format) by note id.
GetNoteDate
	curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2?token=$joplin_srv_token\&fields=created_time
}

function GetNoteTag {
<<GetNoteTag
Get note tags(json format) by note id.
GetNoteTag
#curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2?token=$joplin_srv_token\&fields=tag
	curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2/tags/\?token\=$joplin_srv_token
}

function GetNoteCat {
<<GetNoteCat
Get note categories(json format) by note id.
GetNoteCat
	# get category id
	curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2?token=$joplin_srv_token\&fields=parent_id
	echo >> $1
	p_id=`egrep "\{\"parent_id\"\:\""  $1 | sed -e 's/{"parent_id":"//g' -e 's/","type_":1}//g'` 
	p_info=`curl -s -X GET http://localhost:$joplin_srv_port/folders/$p_id?token=$joplin_srv_token`
	gp_id=`echo $p_info | awk -F\" '{print $26}'`
	gp_info=`curl -s -X GET http://localhost:$joplin_srv_port/folders/$gp_id?token=$joplin_srv_token`
	# get parent category id
	#curl -s -X GET http://localhost:$joplin_srv_port/folders/$folder_id?token=$joplin_srv_token >> $1
        echo $p_info >> $1
        echo $gp_info >> $1
}


function Json2MD {
<<JsonToMD
json转化为md
1. 删除开头。
2. 删除结尾。
3. 把\n定义为换行。
JsonToMD
	sed -e 's/{"body":"//g' -e 's/","type_":.*//g' -e 's/\\n/\n/g' $1 > $2
}

function JoplinMD2HexoMD {
<<JoplinMDToHexoMD
joplin的原始md文件中附加文件资源部分修改为真实文件名
（例如: [fileName.ext](:/uuid) -->[fileName.ext](/resources/uuid.ext)
JoplinMDToHexoMD
	while read LINE
	do
	    if [[ $LINE =~ \!?\[.*\.[0-9a-zA-Z]*\]\(:\/.*\) ]];
	    then
	        ext=`echo $LINE | egrep  -o '\.\w*\]' | sed -e 's/.$//'`
	        echo $LINE | sed -e 's/](:/](\/resources/g' -e 's/\s*$//' -e "s/)/$ext)/g"
	    else
	        echo $LINE
	    fi
	done < $1 > $2
}

<<AddFrontMatterByNoteID
AddFrontMatterByNoteID

function GetRscForJoplinMDBySCP {
<<GetRsc
通过SCP提取Joplin-Desktop中的附加文件（例如*.png|*.txt|*pdf...etc）放在hexo/source/resources/里面。
*需要开启sshd，并设置好authorized_keys无密码使用scp
GetRsc
	while read LINE
	do
	    if [[ $LINE =~ \!?\[.*\.[0-9a-zA-Z]*\]\(:\/.*\) ]];
	    then
	        post_rsc_id=`echo $LINE | egrep -o ':/\w*' | cut -c3-`
	        ext=`echo $LINE | egrep  -o '\.\w*\]' | sed -e 's/.$//'`
		scp $joplin_rsc_dir$post_rsc_id$ext $2/$post_rsc_id$ext #> /dev/null
	    fi
	done < $1
}

function GetRscForJoplinMDByAPI {
<<GetRscByAPI
通过API提取Joplin-Desktop中的附加文件（例如*.png|*.txt|*pdf...etc）放在hexo/source/resources/里面。
GetRscByAPI
	while read LINE
	do
	    if [[ $LINE =~ \!?\[.*\.[0-9a-zA-Z]*\]\(:\/.*\) ]];
	    then
	        post_rsc_id=`echo $LINE | egrep -o ':/\w*' | cut -c3-`
	        ext=`echo $LINE | egrep  -o '\.\w*\]' | sed -e 's/.$//'`
		curl -so $2/$post_rsc_id$ext -X GET http://localhost:$joplin_srv_port/resources/$post_rsc_id/file?token=$joplin_srv_token
	    fi
	done < $1
}

function GetNoteAttachedFileIDTitle {
# Get note attached resources id;title;
	curl -so $1 -X GET http://localhost:$joplin_srv_port/notes/$2/resources/?token=$joplin_srv_token
}

# --- Useful ---
# Gets all notes
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/\?token\=$joplin_srv_token

# Get token 
#curl -XPOST http://$joplin_srv_ip:$joplin_srv_port/auth
#curl  http://$joplin_srv_ip:$joplin_srv_port/auth/check?auth_token=AUTH_TOKEN

# Get the note's location by note id
#curl http://$joplin_srv_ip:$joplin_srv_port/notes/$note_id?fields=longitude,latitude\&token=$joplin_srv_token

#date +'%Y/%m/%d %H:%M:%S' -d "@1653542376"
