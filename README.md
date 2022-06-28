# Joplin2Hexo

## 说明
通过Joplin API或者SSH(SCP)获取笔记。转换为hexo格式。

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
克隆本项目到Hexo博客根目录：
```
git clone https://github.com/
```
执行下面命令：
```
joplin2hexo/main.sh
```

[https://kenryu.cc](https://kenryu.cc)
