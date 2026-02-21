# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

newline=$'\n' # shit
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\][\t] \u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}[\t] \u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -ali --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export COLOR_CYAN='\e[1;36m'
export COLOR_BLUE='\e[1;34m'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -Alf --color=auto'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

alias c='clear'
#alias g='gcc -o'
#alias gp='g++ -o'
alias s='source'
alias b='cd -'
alias p='pwndbg'
LS_COLORS=$LS_COLORS:'di=1;36:'

function gc() {
	git add .
	git commit -m "$@"
	git push
}

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
PATH=$PATH:.

function g() {
	gcc -o $1 $1.c
}
function gp() {
	g++ -o $1 $1.cpp
}

function mkdir() {
  /usr/bin/mkdir -p "$1"
  cd "$1"
}

function cd() {
	builtin cd "$1"
	pwd
	l
}


function _reculsiveLs {
	local pwd=$1 # the name of working directory
	local inherited_string=$2 # visualizing depth
	local -i last_file=$3

	local TabArray
	if [ $last_file == 1 ]; then
		TabArray="$inherited_string└── "
	else
		TabArray="$inherited_string├── "
	fi


	local files="$(printf '%s' "$(/usr/bin/ls -l $pwd)" | sort --ignore-case)" # auto sorted

	local generals="" # general files without directories in this directory
	local directories=""

	# classifing an object into 2 types-general file & directory
	for element in $files:
	do
		if [[ ${element:0:1} == "-" ]]; then
			generals="$generals$newline$(echo $element | rev | cut -d$' ' -f 1 | rev)"
		elif [[ ${element:0:1} == "d" ]]; then
			directories="$directories$newline$(echo $element | rev | cut -d$' ' -f 1 | rev)"
		else
			break
		fi
	done
	
	generals="$(printf '%s' "$generals" | sort --ignore-case)" # sort

	local -i count=0
	local -i NGF=-1 # the Number of General Files ( -1 )
	for file in $generals:
	do
		NGF=$(($NGF+1)) # counting the number of general files
	done
	if [[ $generals != "" ]]; then # Are there at least one general file
		for file in $generals:
		do
			if [ $count != $NGF ]; then
				echo "$TabArray$file"
			fi
			count=$(($count+1))
		done
		#
		file=$(echo $file | rev)
		file=${file:1}
		file=$(echo $file | rev)
		echo "$TabArray$file"
	fi

	directories="$(printf '%s' "$directories" | sort --ignore-case)" # sort

	
	local -i ND=-1 # the Number of Directories ( -1 )

	for directory in $directories:
	do
		ND=$(($ND+1)) # counting the number of directories
	done

	count=0 # re use

	if [[ $directories == "" ]]; then # there is no directory in $pwd
		return
	fi

	for directory in $directories:
	do
		if [ $count != $ND ]; then
			echo "$TabArray$directory"
			_reculsiveLs "$pwd/$directory" "$inherited_string    " 0
		fi
		count=$(($count+1))
	done
	directory=$(echo $directory | rev)
	directory=${directory:1}
	directory=$(echo $directory | rev)
	echo "$TabArray$directory"
	_reculsiveLs "$pwd/$directory" "$inheriting│   " 1
	
}

function _ls {
	IFS=$'\n'
	if [[ $1 == "" ]]; then
		_reculsiveLs .  ""  0 
	else
		_reculsiveLs $1  ""  0 
	fi
	IFS=$' '
}

alias sl="_ls"
alias GPUstat="watch -d -n 0.5 nvidia-smi"

function SG {
	IFS=$'\n'
	local magic_file_name="$1.mg"
	
	if [ ! -e $magic_file_name ]; then
		echo "Which files are source files? (Maybe its name ends with .c extension but, for convenience when coding, please subtract the extension) And split by newline."
		touch $magic_file_name
		cat > $magic_file_name
	fi
	
	local magic_file="$(cat $magic_file_name)"
	local object_files=""
	local -c holy_shit=0 # bash SHITS ':' in last for-loop ;;

	for sf in $magic_file:
	do
		holy_shit=$(($holy_shit+1))
	done
	local -c loop_index=0
	for source_file in $magic_file: # it includes all source files will be forming an excutable file.
	do
		if [ $(($loop_index+1)) == $holy_shit ]; then
			source_file=$(echo $source_file | rev)
			source_file=${source_file:1}
			source_file=$(echo $source_file | rev)
		fi
		gcc -c "$source_file.c"
		object_files="$source_file.o$newline$object_files"
		loop_index=$(($loop_index+1))
	done
	
	gcc -o $1 $object_files # == gcc -o $1 $object_files
	IFS=$' '
}

function EC { # Extract comments from source code ( C code )
	IFS=$'\n'
	local file="$1"
	local extractedFile=""
	local extension
	local -c lineNumber=0;
	if [ ! -e $file ]; then
		echo "There doesn't exist such file!"
	fi

	local code="$(cat $file)"
	local -c stillInComment=0 # Status refers that the line is in /**/
#for line in $code:
	while read line;
	do
		lineNumber=$(($lineNumber+1))
		if [ $stillInComment == 0 ]; then
			# processing for /**/
			local -c loop_index=0
			splitAtSlashWithStar="${line//$'/*'/$newline}"
			local -c holy_shit=0 # bash SHITS ':' in last for-loop ;;
		
			for seperatedString in $splitAtSlashWithStar:
			do
				holy_shit=$(($holy_shit+1))
			done
			
			if [ $holy_shit != 1 ] || [[ ${line:0:1} = "/" && ${line:1:1} = "*" ]]; then # fucking bash
				extractedFile="$extractedFile$lineNumber "
				for seperatedString in $splitAtSlashWithStar:
				do
					if [ $(($loop_index+1)) == $holy_shit ]; then
						seperatedString=$(echo $seperatedString | rev)
						seperatedString=${seperatedString:1}
						seperatedString=$(echo $seperatedString | rev)
					fi
					if [ $loop_index != 0 ]; then
						extractedFile="$extractedFile/*$seperatedString"
					fi
					loop_index=$(($loop_index+1))
				done
				extractedFile="$extractedFile$newline"

				splitAtStarWithSlash="${line//'*/'/$newline}"
				holy_shit=0 # bash SHITS ':' in last for-loop ;;
			
				for seperatedString in $splitAtStarWithSlash:
				do
					holy_shit=$(($holy_shit+1))
				done
				
				if [ $holy_shit == 1 ]; then
					stillInComment=1
				fi
			fi
			# processing for //
			loop_index=0
			splitAtDoubleSlash="${line//$'//'/$newline}"
			holy_shit=0 # bash SHITS ':' in last for-loop ;;
		
			for seperatedString in $splitAtDoubleSlash:
			do
				holy_shit=$(($holy_shit+1))
			done
			
			if [[ ${line:0:1} = "/" && ${line:1:1} = "/" ]]; then # fucking bash
				extractedFile="$extractedFile$lineNumber "
				extractedFile="$extractedFile${line:2}$newline"
			elif [ $holy_shit != 1 ]; then
				extractedFile="$extractedFile$lineNumber "
				for seperatedString in $splitAtDoubleSlash:
				do
					if [ $(($loop_index+1)) == $holy_shit ]; then
						seperatedString=$(echo $seperatedString | rev)
						seperatedString=${seperatedString:1}
						seperatedString=$(echo $seperatedString | rev)
					fi
					if [ $loop_index != 0 ]; then
						extractedFile="$extractedFile//$seperatedString"
					fi
					loop_index=$(($loop_index+1))
				done
				extractedFile="$extractedFile$newline"
			fi
		else # this line is surrounded by /* and */
			extractedFile="$extractedFile$lineNumber "
			extractedFile="$extractedFile$line$newline"
			splitAtStarWithSlash="${line//$'*/'/$newline}"
			holy_shit=0 # bash SHITS ':' in last for-loop ;;
		
			for seperatedString in $splitAtStarWithSlash:
			do
				holy_shit=$(($holy_shit+1))
			done
			
			if [ $holy_shit != 1 ]; then
				stillInComment=0
			fi
		fi
	done < $file
	extension=$(echo $file | rev)
	extension=$(echo $extension | cut -d '.' -f 1)
	extension=$(echo $extension | rev)
	
	echo "extension : $extension"
	file=$(echo $file | rev)
	file=${file:${#extension}} # subtract extension
	file=$(echo $file | rev)
	file="subtracted_$(echo $file)$extension"
	echo "$subtractedFile" > "$file"
	echo "$subtractedFile"

	IFS=' '
}
function SC { # Subtract comments from source code ( C code )
	IFS=$'\n'
	local file="$1"
	local subtractedFile=""
	local lineExcludingComments
	local extension
	local -c lineNumber=0;
	if [ ! -e $file ]; then
		echo "There doesn't exist such file!"
	fi

	local code="$(cat $file)"
	local -c stillInComment=0 # Status refers that the line is in /**/
#for line in $code:
	while read line;
	do
		lineNumber=$(($lineNumber+1))
		if [ $stillInComment == 0 ]; then
			# processing for /**/
			local -c loop_index=0
			splitAtSlashWithStar="${line//$'/*'/$newline}"
			local -c holy_shit=0 # bash SHITS ':' in last for-loop ;;
		
			for seperatedString in $splitAtSlashWithStar:
			do
				if [ $holy_shit == 0 ]; then
					lineExcludingComments=$seperatedString
				fi
				holy_shit=$(($holy_shit+1))
			done
			
			if [ $holy_shit != 1 ]; then
				subtractedFile="$subtractedFile$lineExcludingComments$newline"

				splitAtStarWithSlash="${line//'*/'/$newline}"
				holy_shit=0 # bash SHITS ':' in last for-loop ;;
			
				for seperatedString in $splitAtStarWithSlash:
				do
					holy_shit=$(($holy_shit+1))
				done
				
				if [ $holy_shit == 1 ]; then
					stillInComment=1
				fi
			elif [[ ${line:0:1} = "/" && ${line:1:1} = "*" ]]; then
				splitAtStarWithSlash="${line//'*/'/$newline}"
				holy_shit=0 # bash SHITS ':' in last for-loop ;;
			
				for seperatedString in $splitAtStarWithSlash:
				do
					holy_shit=$(($holy_shit+1))
				done
				
				if [ $holy_shit == 1 ]; then
					stillInComment=1
				fi
				
			else
				# processing for //
				loop_index=0
				splitAtDoubleSlash="${line//$'//'/$newline}"
				holy_shit=0 # bash SHITS ':' in last for-loop ;;
			
				for seperatedString in $splitAtDoubleSlash:
				do
					if [ $holy_shit == 0 ]; then
						lineExcludingComments=$seperatedString
					fi
					holy_shit=$(($holy_shit+1))
				done
				if [[ ${line:0:1} = "/" && ${line:1:1} = "/" ]]; then # fucking bash
					continue
				elif [ $holy_shit == 1 ]; then
					lineExcludingComments=$(echo $lineExcludingComments | rev)
					lineExcludingComments=${lineExcludingComments:1}
					lineExcludingComments=$(echo $lineExcludingComments | rev)
				fi
				subtractedFile="$subtractedFile$lineExcludingComments$newline"
			fi
		else # this line is surrounded by /* and */
			splitAtStarWithSlash="${line//$'*/'/$newline}"
			holy_shit=0 # bash SHITS ':' in last for-loop ;;
		
			for seperatedString in $splitAtStarWithSlash:
			do
				holy_shit=$(($holy_shit+1))
			done
			
			if [ $holy_shit != 1 ]; then
				echo "exited surrounded section : $line"
				stillInComment=0
			fi
		fi
	done < $file

	extension=$(echo $file | rev)
	extension=$(echo $extension | cut -d '.' -f 1)
	extension=$(echo $extension | rev)
	
	echo "extension : $extension"
	file=$(echo $file | rev)
	file=${file:${#extension}} # subtract extension
	file=$(echo $file | rev)
	file="subtracted_$(echo $file)$extension"
	echo "$subtractedFile" > "$file"
	echo "$subtractedFile"
	IFS=' '
}

function _backup() {
	local source_dir=$1
	local destination_dir=$2

	timestamp=$(date +%Y%m%d%H%M%S)

	tar -czf "$destination_dir/backup_$timestamp.tar.gz" "$source_dir"
}

function _sysinfo() {
	local cpu_usage=$(top -bn1 | awk 'NR==3 {print $2}')
	local memory_usage=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')
	local disk_usage=$(df -h / | awk 'NR==2{print $5}')

	echo "CPU Usage: $cpu_usage"
	echo "Memory Usage: $memory_usage"
	echo "Disk Usage: $disk_usage"
}

function gitoverwrite() {
	git fetch origin
	git reset --hard origin/main
	git clean -fd
}

function cats {
    local iter=1
    for f in $@
    do
        echo $iter: $f
        cat $f
        echo ''
        ((iter++))
    done
}

findsym() {
    local search_path=".."
    local symbol=""

    if [[ $# -eq 1 ]]; then
        symbol="$1"
    elif [[ $# -ge 2 ]]; then
        search_path="$1"
        symbol="$2"
    else
        echo "사용법: findsym [검색경로] <심볼이름>"
        echo "예: findsym .. httpcon_auth"
        echo "예: findsym httpcon_auth   (기본 검색경로: ..)"
        return 1
    fi

    find "$search_path" -type f -name "*.so*" -print0 2>/dev/null \
    | while IFS= read -r -d '' f; do
        nm -D "$f" 2>/dev/null | grep -qw -- "$symbol" && echo "$f"
      done
}
alias dz='rm *.Identifier'
check_needed() {
    local file="$1"

    if [[ -z "$file" ]]; then
        echo "사용법: check_needed <파일>"
        return 1
    fi

    readelf -d "$file" 2>/dev/null | grep NEEDED
}

check_symbol() {
    local file="$1"
    local symbol="$2"

    if [[ -z "$file" || -z "$symbol" ]]; then
        echo "사용법: check_symbol <파일> <심볼이름>"
        return 1
    fi

    readelf -Ws "$file" 2>/dev/null | grep -w -- "$symbol"
}
findsym_def() {
    local path="${1:-..}"
    local symbol="$2"
    if [[ -z "$symbol" ]]; then
        echo "사용법: findsym_def [경로] <심볼>"
        return 1
    fi

    find "$path" -type f -name "*.so*" -print0 2>/dev/null \
    | while IFS= read -r -d '' f; do
        # UND는 제외하고(=정의만)
        readelf -Ws "$f" 2>/dev/null \
        | awk -v s="$symbol" '$8==s && $7!="UND" {found=1} END{exit !found}' \
        && echo "$f"
      done
}

od_func() {
    local bin="$1"
    local func="$2"

    if [[ -z "$bin" || -z "$func" ]]; then
        echo "사용법: od_func <바이너리> <함수이름>"
        echo "예: od_func login_handler.cgi main"
        echo "예: od_func login_session.cgi get_value_post"
        return 1
    fi

    # '<func>:' 라벨부터 시작해서 다음 '<...>:' 라벨 나오기 전까지 출력
    mips-linux-gnu-objdump -D -EL "$bin" 2>/dev/null \
    | awk -v f="$func" '
        $0 ~ "<" f ">:" {p=1}
        p {print}
        p && $0 ~ /^0[0-9a-fA-F]+ <[^>]+>:/ && $0 !~ "<" f ">:" {exit}
    '
}
od_addr() {
    local bin="$1"
    local addr="$2"
    local A="${3:-50}"
    local B="${4:-50}"

    if [[ -z "$bin" || -z "$addr" ]]; then
        echo "사용법: od_addr <바이너리> <주소/패턴> [A] [B]"
        echo "예: od_addr login_handler.cgi 400a88 50 50"
        echo "예: od_addr login_handler.cgi 400a88 100 20"
        return 1
    fi

    mips-linux-gnu-objdump -D -EL "$bin" 2>/dev/null \
    | grep -n -A "$A" -B "$B" -- "$addr"
}
find_gp() {
    if [[ $# -lt 1 ]]; then
        echo "사용법: find_gp <파일|글롭패턴|디렉토리>"
        echo "예: find_gp libcgi.so"
        echo "예: find_gp '*.so*'"
        echo "예: find_gp .    (현재 디렉토리 내 파일들 대상)"
        return 1
    fi

    local target="$1"

    if [[ -d "$target" ]]; then
        # 디렉토리면 안의 모든 파일 대상
        find "$target" -type f -print0 2>/dev/null \
        | while IFS= read -r -d '' f; do
            readelf -sW "$f" 2>/dev/null \
            | egrep ' _gp$|__gnu_local_gp' >/dev/null \
            && { echo "== $f =="; readelf -sW "$f" 2>/dev/null | egrep ' _gp$|__gnu_local_gp'; }
          done
    else
        # 파일/글롭패턴이면 그대로 확장해서 처리
        for f in $target; do
            [[ -f "$f" ]] || continue
            readelf -sW "$f" 2>/dev/null \
            | egrep ' _gp$|__gnu_local_gp' >/dev/null \
            && { echo "== $f =="; readelf -sW "$f" 2>/dev/null | egrep ' _gp$|__gnu_local_gp'; }
        done
    fi
}


hsd() {
    if [[ $# -ne 2 ]]; then
        echo "사용법: hex_sub_dec <hex> <dec>"
        echo "예: hex_sub_dec 0x10 10"
        return 1
    fi

    local hex=${1#0x}
    local dec=$2

    local result=$(( 0x$hex - dec ))

    printf "dec: %d\nhex: 0x%X\n" "$result" "$result"
}
qemu_mips_dbg() {
    local bin="$1"
    local rootfs="${2:-$HOME/iptime/extractions/a3004t_kr_12_102(1).bin.extracted/0/a3004t.bin.extracted/35E334/squashfs-root}"
    local port="${3:-1234}"

    if [[ -z "$bin" ]]; then
        echo "사용법: qemu_mips_dbg <binary> [rootfs] [port]"
        return 1
    fi

    rootfs="$(readlink -f "$rootfs")" || return 1
    bin="$(readlink -f "$bin")" || return 1

    if [[ ! -e "$bin" ]]; then
        echo "[!] 바이너리가 없습니다: $bin"
        return 1
    fi
    if [[ ! -d "$rootfs" ]]; then
        echo "[!] rootfs 디렉터리가 없습니다: $rootfs"
        return 1
    fi

    local qemu="qemu-mips"
    if readelf -h "$bin" 2>/dev/null | grep -qi 'little endian'; then
        qemu="qemu-mipsel"
    fi

    local interp="/lib/ld-uClibc.so.0"
    local interp_host="$rootfs${interp}"
    local libpath="$rootfs/lib"

    local log="/tmp/qemu_mips_dbg.$(basename "$bin").$port.log"
    : > "$log"

    echo "[*] qemu:   $qemu"
    echo "[*] rootfs: $rootfs"
    echo "[*] bin:    $bin"
    echo "[*] port:   $port"
    echo "[*] interp: $interp"
    echo "[*] log:    $log"

    if [[ ! -e "$interp_host" ]]; then
        echo "[!] 인터프리터가 rootfs에 없습니다: $interp_host"
        return 1
    fi

    # 포트 점유 확인
    if command -v ss >/dev/null 2>&1 && ss -lnt 2>/dev/null | grep -q ":$port "; then
        echo "[!] 포트가 이미 사용 중입니다: $port"
        return 1
    fi

    # 핵심: 로더를 직접 실행 + library-path 강제 (ld.so.cache 우회)
    (cd "$rootfs" && \
        "$qemu" -L "$rootfs" -g "$port" "./lib/ld-uClibc.so.0" --library-path "./lib" "./${bin#$rootfs/}" \
        2>>"$log") &
    local qemu_pid=$!

    # 포트 열림 대기 (최대 20초)
    local ok=0
    for _ in $(seq 1 200); do
        kill -0 "$qemu_pid" 2>/dev/null || break
        if command -v ss >/dev/null 2>&1; then
            ss -lntp 2>/dev/null | grep -q ":$port " && { ok=1; break; }
        fi
        sleep 0.1
    done

    if [[ "$ok" -ne 1 ]]; then
        echo "[!] gdb 포트(:$port)가 열리지 않았습니다."
        echo "---- 최근 로그 ----"
        tail -n 120 "$log"
        echo "-------------------"
        kill "$qemu_pid" >/dev/null 2>&1
        return 1
    fi

    gdb-multiarch "$bin" \
        -ex "set architecture mips" \
        -ex "set pagination off" \
        -ex "target remote 127.0.0.1:$port"

    kill "$qemu_pid" >/dev/null 2>&1
}
