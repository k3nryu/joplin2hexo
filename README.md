# Joplin2Hexo
[![Open Source Love](https://badges.frapsoft.com/os/v3/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)
[![Bash Shell](https://badges.frapsoft.com/bash/v1/bash.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

## Description
Get the notes and their attachments (including images) via the Joplin API or optionally SSH (SCP) and add the front-matter in hexo format. this script is written in BASH and supports Linux, macOS, Windows (WSL). Implements a one-line command to generate Joplin notes into a Hexo blog.

## Features
- Multi-platform: supports Linux, macOS, Windows (WSL).
- Distributed design: supports Hexo and Joplin not on the same computer.
- Simple & efficient: only 'note id' need to be entered.
- Secure: uses SSH reverse proxy.
- Easy to maintain: uses BASH and Joplin official API.

## Quick Start
### (When you first use) Step1. Clone or download this script to your Hexo root directory.
```
cd $Your_Hexo_Directory
git clone https://github.com/k3nryu/joplin2hexo.git
```
### Step2. Excute following command.
```
joplin2hexo/main.sh
```
Then enter the noteid that you want to upload to Hexo.
> The first time you use it you will be asked to enter your Joplin location. And various information. And generate a profile file. Or you can edit the profile file directly.

# Flowchart
<details>
<summary> Flowchat </summary>

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
</details>

## Update
```
cd $Your_Hexo_Directory
git pull
```

## Uninstall
```
cd $Your_Hexo_Directory
rm -rf joplin2hexo
```

## ToDo
- [ ] Support embed format resources
        For example: <embed src="abc.pdf" width="100%" height="1000" type="application/pdf">
- [ ] Support recognizing tag to upload automatically
        For example, if you put a tag like "hexo" or "blog" on a joplin note, the program will automatically filter the notes and copy them to the hexo post directory.
