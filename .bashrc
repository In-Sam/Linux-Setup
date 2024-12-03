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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\][\t] \u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
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
alias g='gcc -o'
alias s='source'
alias b='cd -'

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
			
			if [ $holy_shit != 1 ] || [[ ${line:0:1} = "/" && ${line:1:1} = "*" ]] then # fucking bash
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
