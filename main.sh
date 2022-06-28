#! /bin/bash

<<flowchat
读取用户配置
连接API服务器
询问Note ID
Joplin API
	获取Note Body (JSON file)
	获取Note Title (JSON file)
	获取Note Create Data (JSON file)
	获取Note Note Book (JSON file)
	获取Note Tag (JSON file)
转换Note Body (JSON file) --> Note Body (MarkDown File)
修正Note Body (MarkDown File) --> Hexo Note Body (Markdown File)
添加Front Matter
	读取Note Title (JSON file) >> Note Body (MarkDown File Front Matter YAML)
	读取Note Create Data (JSON file) >> Note Body (MarkDown File Front Matter YAML)
	读取Note Note Book (JSON file) >> Note Body (MarkDown File Front Matter YAML)
	读取Note Tag (JSON file) >> Note Body (MarkDown File Front Matter YAML)
	读取Note Create Data (JSON file) >> Note Body (MarkDown File)
获取Note Attachment 储存到 /hexo/source/resources/
展示
flowchat

# Get hexo server directory.
hexo_dir=`realpath $(dirname $0) | sed -e 's/\/[0-9a-zA-Z]*$//'`
# File paths
hexo_post_dir=$hexo_dir/source/_posts
hexo_rsc_dir=$hexo_dir/source/resources
hexo_tmp_dir=$hexo_dir/tmp

note_body_json=$hexo_dir/tmp/0_Goted_Note_body_tmp.json
note_body_joplin_md=$hexo_dir/tmp/1_Joplin_Note_body_tmp.md
note_body_hexo_md=$hexo_dir/tmp/2_Hexo_Note_body_tmp.md

note_title_json=$hexo_dir/tmp/0_Goted_Note_title_tmp.json
note_date_json=$hexo_dir/tmp/0_Goted_Note_date_tmp.json

note_tag_json=$hexo_dir/tmp/0_Goted_Note_tag_tmp.json
note_tag_yaml=$hexo_dir/tmp/Edited_Note_tag_tmp.yaml

note_p_cat_json=$hexo_dir/tmp/0_Goted_Note_p_cat_tmp.json
note_gp_cat_json=$hexo_dir/tmp/0_Goted_Note_gp_cat_tmp.json
note_ggp_cat_json=$hexo_dir/tmp/0_Goted_Note_ggp_cat_tmp.json
note_cat_yaml=$hexo_dir/tmp/Edited_Note_cat_tmp.json

joplin_user_profile=$hexo_dir/joplin2hexo/joplin_user_profile.sh

# hexo post resources directory.
local_rsc_dir=$hexo_dir/source/resources/

# Import functions
source $hexo_dir/joplin2hexo/functions.sh

# Make directories
mkdir -p $hexo_dir/tmp $hexo_dir/source/resources


# Read user profile for connect JoplinClipperServer 
ReadConfig $joplin_user_profile

# JoplinClipperServer Connection
if [[ $joplin_srv_location == "remote" ]];then
	echo JoplinClipperServer Connecting ...
	ssh -fNL $joplin_srv_port:127.0.0.1:$joplin_srv_port $joplin_srv_user@$joplin_srv_ip
fi

# JoplinClipperServer Connection Check
echo JoplinClipperServer Connection Check:
SrvCheck

# JoplinClipperServer Authorisation Check
echo JoplinClipperServer Authorisation Check:
TokenCheck

echo -e "Please enter note ID:"
read note_id
#note_id=b76691e5a8f14c919360b5ed69b1c0c1

# Get note body(json format) by note id.
GetNoteBody $note_body_json $note_id
GetNoteTitle $note_title_json $note_id
GetNoteDate $note_date_json $note_id
GetNoteTag $note_tag_json $note_id
GetNoteCat $note_p_cat_json $note_id

# Edit json resources
Json2MD $note_body_json $note_body_joplin_md

JoplinMD2HexoMD $note_body_joplin_md $note_body_hexo_md
GetRscForJoplinMDByAPI $note_body_joplin_md $hexo_rsc_dir

# file name
fileName=`egrep -o "title\"\:\".*\"\,\"" $note_title_json | cut -c9- | sed -e 's/\",\"$//g' -e 's/[ ]/_/g' | awk '{print $0 ".md"}'`

echo --- > $hexo_tmp_dir/$fileName
# title
egrep -o "title\"\:\".*\"\,\"" $note_title_json | cut -c9- | sed -e 's/\",\"$//g' | awk '{print "title: " $0}' >> $hexo_tmp_dir/$fileName
# date
created_unix_time=`egrep -o "created_time\":[0-9]{10}" $note_date_json | cut -c15-` >> $hexo_tmp_dir/$fileName
date +'%Y/%m/%d %H:%M:%S' -d "@$created_unix_time" | awk '{print "date: " $0}' >> $hexo_tmp_dir/$fileName
# tags
egrep -o "title\"\:\"\w*" $note_tag_json | cut -c9- | awk '{print "  - " $0}' | sed '1i tags:' >> $hexo_tmp_dir/$fileName
# categories
category=`egrep -o -m1 "title\"\:\".*\"\,\"" $note_p_cat_json | cut -c9- | sed -e 's/\",\".*//g'`
category_folder=`echo $category | sed -e 's/ /_/g'`
echo $category | awk '{print "  - " $0}' | sed '1i categories:' >> $hexo_tmp_dir/$fileName
echo "toc: true" >> $hexo_tmp_dir/$fileName
echo "#sidebar: none" >> $hexo_tmp_dir/$fileName
echo --- >> $hexo_tmp_dir/$fileName
echo >> $hexo_tmp_dir/$fileName
cat $note_body_hexo_md >> $hexo_tmp_dir/$fileName
mkdir -p $hexo_post_dir/$category_folder
cp -f $hexo_tmp_dir/$fileName $hexo_post_dir/$category_folder


