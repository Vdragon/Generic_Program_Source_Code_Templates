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

GLOBAL_EXECUTABLE_PATH="${GLOBAL_EXECUTABLE_DIRECTORY}/${GLOBAL_EXECUTABLE_FILENAME}"
readonly GLOBAL_EXECUTABLE_PATH

GLOBAL_COMMANDLINE_ARGUMENT_NUMBER_ORIGINAL="${#}"
readonly GLOBAL_COMMANDLINE_ARGUMENT_NUMBER_ORIGINAL

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
	elif [ 1 -eq $global_just_show_help ]; then
		print_help_message "${GLOBAL_EXECUTABLE_PATH}"
		exit 0
	fi

	exit 0
}

process_commandline_arguments() {
	# Defensive Bash Programming - Command line arguments
	# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
	# FIXME: 目前的設計不支援含空白字元的參數
	local argument_quantity="${1}"; shift
	if [ 0 -eq "${argument_quantity}" ]; then
		return
	fi
	local arguments=("${@}")

	# 所有目前已經翻譯為短選項的命令列參數（一開始是空字串，有東西之後，結尾總是會有參數分隔字元（也就是空白））
	local arguments_translated=""

	# 翻譯長版本選項為短版本選項
	for argument in "${arguments[@]}"; do # $arguments 是有意不要被引號括住的，才會被 for 迴圈一一走訪
		local delimiter=""
		local argument_separater=" "

		case "${argument}" in
			--help)
				arguments_translated="${arguments_translated}-h${argument_separater}"
			;;
			--debug)
				arguments_translated="${arguments_translated}-d${argument_separater}"
			;;
			# pass anything else
			*)
				# 報錯所有不認識的長選項
				if [ "${argument:0:2}" == "--" ]; then
					printf "錯誤：%s 命令列選項不存在！\n" "${argument}" 1>&2
					printf "錯誤：請執行「%s --help」命令以查詢所有可用的命令列選項。\n" "${GLOBAL_EXECUTABLE_PATH}" 1>&2
					exit 1
				fi

				# 如果參數不是「-」開頭（不是命令列選項）就將 $delimiter 改為「雙引號"」，不然的話維持「（空字串）」
				# -e -> ${arguments_translated}-e${argument_separater}
				# et -> ${arguments_translated}"et"${argument_separater}
				[[ "${argument:0:1}" == "-" ]] || delimiter="\""
				arguments_translated="${arguments_translated}${delimiter}${argument}${delimiter}${argument_separater}"
			;;
		esac
	done

	#Reset the positional parameters to the short options
	eval set -- "${arguments_translated}"

	while getopts "dh" short_argument; do
		case "${short_argument}" in
			d)
				global_enable_debugging=1
			;;
			h)
				global_just_show_help=1
			;;
		esac
	done

	# 如果參數未設定的話採用預設值

	return
}
declare -fr process_commandline_arguments

print_help_message(){
	local command="$*"

	printf "## 使用方法 ##\n"
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
