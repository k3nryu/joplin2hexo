# Joplin2Hexo

## 说明
本脚本采用BASH编写，支持Linux，macOS，Windows（WSL）。通过Joplin API或者可选SSH(SCP)获取笔记以及其附件（包括图片），并转换为hexo格式。实现一行命令将Joplin笔记生成Hexo博客。

# Flowchart
```mermaid
flowchart TD
	start([start]) --> id1{The location of the JoplinClipperServer relative to this program.}
	id1 --> |remote| SSH_L[SSH Local port forwarding :41184] --> test1
	id1 --> |local| test1[Testing JoplinClipperServer connetciton and return the result.]
	test1 --> test2{Use API to check token available and return the result}
	test2 --> |No| req1[Request token]
	test2 --> |Yes| getNoteID[Ask user Joplin note id.] --> proc1
	proc1[Get note body] --> proc2
	proc2[Convert note body JSON to Markdown] --> proc3
	proc3[Modify]
	
```

## 使用


### Step1.克隆本项目到Hexo博客根目录：
```
git submodule add git@github.com:k3nryu/joplin2hexo.git
```
### Step2.执行下面命令：
```
joplin2hexo/main.sh
```

输入你想要放入Hexo博客的Joplin笔记的ID。
> 第一次使用的时候会让你输入你的Joplin位置。以及各种信息。并生成profile文件。
> 或者你可以直接编辑profile文件。

## 更新
```
cd $Your_Hexo_Directory
git pull --recurse-submodules
```
