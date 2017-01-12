#!/usr/bin/env bash
# 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
# 〈程式檔名〉 - 〈程式描述文字（一言以蔽之）〉
# 〈程式智慧財產權擁有者名諱、地址（選用）〉 © 〈智慧財產權生效年〉
# 〈更多程式描述文字〉

######## File scope variable definitions ########
# Defensive Bash Programming - not-overridable primitive definitions
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
# SC2155 - Declare and assign separately to avoid masking return values · koalaman/shellcheck Wiki
# https://github.com/koalaman/shellcheck/wiki/SC2155
GLOBAL_EXECUTABLE_FILENAME="$(basename "$0")"
readonly GLOBAL_EXECUTABLE_FILENAME

GLOBAL_EXECUTABLE_DIRECTORY="$(realpath --relative-to="$(pwd)" --no-symlinks "$(dirname "$0")")"
readonly GLOBAL_EXECUTABLE_DIRECTORY

declare -r GLOBAL_EXECUTABLE_PATH="${GLOBAL_EXECUTABLE_DIRECTORY}/${GLOBAL_EXECUTABLE_FILENAME}"

declare -ir GLOBAL_COMMANDLINE_ARGUMENT_NUMBER_ORIGINAL="${#}"

declare -a GLOBAL_COMMANDLINE_ARGUMENT_LIST_ORIGINAL
if [ "$GLOBAL_COMMANDLINE_ARGUMENT_NUMBER_ORIGINAL" -eq 0 ]; then
	GLOBAL_COMMANDLINE_ARGUMENT_LIST_ORIGINAL=(nothing)
else
	GLOBAL_COMMANDLINE_ARGUMENT_LIST_ORIGINAL=("$@")
fi
readonly GLOBAL_COMMANDLINE_ARGUMENT_LIST_ORIGINAL


## Unofficial Bash Script Mode
## http://redsymbol.net/articles/unofficial-bash-strict-mode/
# 將未定義的變數的參考視為錯誤
set -u

# Exit immediately if a pipeline, which may consist of a single simple command, a list, or a compound command returns a non-zero status.  The shell does not exit if the command that fails is part of the command list immediately following a `while' or `until' keyword, part of the test in an `if' statement, part of any command executed in a `&&' or `||' list except the command following the final `&&' or `||', any command in a pipeline but the last, or if the command's return status is being inverted with `!'.  If a compound command other than a subshell returns a non-zero status because a command failed while `-e' was being ignored, the shell does not exit.  A trap on `ERR', if set, is executed before the shell exits.
set -e

# If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
set -o pipefail

######## File scope variable definitions ended ########

######## Included files ########

######## Included files ended ########

######## Program ########
global_just_show_help=0
global_enable_debugging=0

# Defensive Bash Programming - main function, program entry point
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	process_commandline_arguments "${GLOBAL_COMMANDLINE_ARGUMENT_NUMBER_ORIGINAL}" "${GLOBAL_COMMANDLINE_ARGUMENT_LIST_ORIGINAL[@]}"

	# process global flags
	if [ 1 -eq $global_enable_debugging ]; then
		set -x
	fi
	if [ 1 -eq $global_just_show_help ]; then
		print_help_message "${GLOBAL_EXECUTABLE_PATH}"
		exit 0
	fi

	exit 0
}

process_commandline_arguments() {
	local argument_quantity="${1}"; shift
	if [ 0 -eq "${argument_quantity}" ]; then
		return
	fi
	#local arguments=("${@}")

	while :; do
		case ${1} in
			--help|-h)
				global_just_show_help=1
				;;
			--debug|-d)
				global_enable_debugging=1
				;;
			*)
				printf "錯誤：未知的「%s」命令列引數\n" "${1}" >&2
				global_just_show_help=1
				;;
		esac
		if [ "$((-- argument_quantity))" -eq 0 ]; then
			break
		fi
		shift
	done
	return
}
declare -fr process_commandline_arguments

print_help_message(){
	local command="$*"

	printf "# 使用方法 #\n"
	printf "%s 〈命令列選項〉\n" "${command}"
	printf "\n"
	printf "注意如果程式路徑包含空白字元，您可能需要把它們用單／雙引號包住，詳情請參考您使用的 shell 的使用手冊\n"
	printf "\n"
	printf "## 命令列選項 ##\n"
	printf "* --help / -h  \n"
	printf "\t印出幫助訊息\n"
	printf "\n"
	printf "* --debug / -d  \n"
	printf "\t啟用除錯模式\n"
	printf "\n"
	return
}

# 程式進入點
main
