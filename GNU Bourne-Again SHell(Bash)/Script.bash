#!/usr/bin/env bash
#shellcheck disable=SC2034
# The above line will be obselute after ShellCheck releases 0.4.6, refer https://github.com/koalaman/shellcheck/wiki/Ignore for more info.
# 〈程式描述文字〉
# 〈程式智慧財產權擁有者名諱、地址（選用）〉 © 〈智慧財產權生效年〉
# The name of this program, presenting to user
declare -r PROGRAM_NAME="Unnamed Program"
# The identifier of this program, usage of characters are limited due to certain platform restrictions
declare -r PROGRAM_NAME_IDENTIFIER=unnamed-program
# The name of the software this program reside in, presenting to user
declare -r SOFTWARE_NAME="Unnamed Software"
# The identifier of the package this program reside in, usage of characters are limited due to certain platform restrictions
declare -r SOFTWARE_NAME_IDENTIFIER=unnamed-package
# An action to let user get help from developer or other sources when error occurred
declare -r SOFTWARE_SUPPORT_METHOD_IMPERATIVE_SENTENCE="contact developer"
# The Software Directory Configuration this software uses, refer below section for more info
declare SOFTWARE_DIR_CONF="SHC"

## Notes
### realpath's commandline option, `--strip` will be replaced in favor of `--no-symlinks` after April 2019(Ubuntu 14.04's Support EOL)

## Makes debuggers' life easier - Unofficial Bash Strict Mode
## http://redsymbol.net/articles/unofficial-bash-strict-mode/
### Exit immediately if a pipeline, which may consist of a single simple command, a list, or a compound command returns a non-zero status.  The shell does not exit if the command that fails is part of the command list immediately following a `while' or `until' keyword, part of the test in an `if' statement, part of any command executed in a `&&' or `||' list except the command following the final `&&' or `||', any command in a pipeline but the last, or if the command's return status is being inverted with `!'.  If a compound command other than a subshell returns a non-zero status because a command failed while `-e' was being ignored, the shell does not exit.  A trap on `ERR', if set, is executed before the shell exits.
set -o errexit
#### Trigger trap if program prematurely exited due to an error, collect all information useful to debug
trap_warn_before_errexit_abort(){
	local -ir line_error_location=${1}; shift # The line number that triggers the error
	local -r failing_command="${1}"; shift # The failing command
	local -ir failing_command_return_status=${1} # The failing command's return value

	# No need to debug abort script
	set +o xtrace

	printf "ERROR: %s has encountered an error and is ending prematurely, %s for support.\n" "${PROGRAM_NAME}" "${SOFTWARE_SUPPORT_METHOD_IMPERATIVE_SENTENCE}" 1>&2

	printf "\n" # Separate paragraphs

	printf "Technical information:\n"
	printf "\n" # Separate list title and items
	printf "	* The error happens at line %s\n" "${line_error_location}"
	printf "	* The failing command is \"%s\"\n" "${failing_command}"
	printf "	* Failing command's return status is %s\n" "${failing_command_return_status}"
	printf "	* Intepreter info: GNU Bash v%s on %s platform\n" "${BASH_VERSION}" "${MACHTYPE}"
	printf "\n" # Separate list and further content

	printf "Goodbye.\n"
	return
}
readonly -f trap_warn_before_errexit_abort
trap 'trap_warn_before_errexit_abort ${LINENO} "${BASH_COMMAND}" ${?}' ERR

### Treat unset variables and parameters other than the special parameters `@' or `*' as an error when performing parameter expansion.  An error message will be written to the standard error, and a non-interactive shell will exit.
set -o nounset

### If set, any trap on `ERR' is inherited by shell functions, command substitutions, and commands executed in a subshell environment.  The `ERR' trap is normally not inherited in such cases.
set -o errtrace

### If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.  This option is disabled by default.
set -o pipefail

## Defensive Bash Programming - not-overridable primitive definitions
## http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
### Determine/Guess script's filename and path and calling command
### BashFAQ/How do I determine the location of my script? I want to read some config files from the same place. - Greg's Wiki
### http://mywiki.wooledge.org/BashFAQ/028
if [ ! -v BASH_SOURCE ]; then
	SOFTWARE_DIR_CONF=FHS
	RUNTIME_SCRIPTNAME="${PROGRAM_NAME_IDENTIFIER}"
	RUNTIME_COMMAND_BASE="${RUNTIME_SCRIPTNAME}"
else
	# Script's filename
	RUNTIME_SCRIPTNAME="$(basename "${BASH_SOURCE[0]}")"
	readonly RUNTIME_SCRIPTNAME

	# Absolute path of the directory which the script are located
	RUNTIME_SCRIPTDIR="$(realpath --strip "$(dirname "${BASH_SOURCE[0]}")")"
	readonly RUNTIME_SCRIPTDIR

	# Absolute path of the script
	RUNTIME_SCRIPTPATH="$(realpath --strip "${BASH_SOURCE[0]}")"
	readonly RUNTIME_SCRIPTPATH

	# Relative path (to the working directory) of the script
	RUNTIME_SCRIPTPATH_RELATIVE="$(realpath --relative-to="${PWD}" --strip "${RUNTIME_SCRIPTPATH}")"
	readonly RUNTIME_SCRIPTPATH_RELATIVE

	# RUNTIME_COMMAND_BASE: The guessed user input command's executable (without the arguments), this is handy when showing help, where the proper command base can be displayed
	# If ${RUNTIME_SCRIPTDIR} is in ${PATH}, this would be ${RUNTIME_SCRIPTNAME}, if not this would be ./${RUNTIME_SCRIPTPATH_RELATIVE}
	declare RUNTIME_COMMAND_BASE
	declare -a RUNTIME_PATH_DIRECTORIES=()
	IFS=':' read -r -a RUNTIME_PATH_DIRECTORIES <<< "${PATH}" || true # Without this `read` will return 1
	readonly RUNTIME_PATH_DIRECTORIES

	declare pathdir
	for pathdir in "${RUNTIME_PATH_DIRECTORIES[@]}"; do
		#printf "PATH: \"%s\"\n" "${pathdir}"
		if [ "${RUNTIME_SCRIPTDIR}" == "${pathdir}" ]; then
			RUNTIME_COMMAND_BASE="${RUNTIME_SCRIPTNAME}"
			break
		fi
	done
	unset pathdir
	readonly RUNTIME_COMMAND_BASE="${RUNTIME_COMMAND_BASE:-./${RUNTIME_SCRIPTPATH_RELATIVE}}"
fi

### Collect command-line arguments
declare -ir RUNTIME_COMMANDLINE_ARGUMENT_NUMBER="${#}"
declare -a RUNTIME_COMMANDLINE_ARGUMENT_LIST
if [ "${RUNTIME_COMMANDLINE_ARGUMENT_NUMBER}" -eq 0 ]; then
	RUNTIME_COMMANDLINE_ARGUMENT_LIST=(nothing)
else
	RUNTIME_COMMANDLINE_ARGUMENT_LIST=("$@")
fi
readonly RUNTIME_COMMANDLINE_ARGUMENT_LIST

## Software Directories Configuration(S.D.C.)
## This section defines and determines the directories used by the software
declare -r SOFTWARE_DIR_CONF=${SOFTWARE_DIR_CONF:-FHS}

case "${SOFTWARE_DIR_CONF}" in
	FHS)
		# Filesystem Hierarchy Standard(F.H.S.) configuration paths
		# http://refspecs.linuxfoundation.org/FHS_3.0/fhs
		## Software installation directory prefix, should be overridable by configure/install script
		declare -r FHS_PREFIX_DIR="/usr/local"

		declare -r SDC_EXECUTABLE_DIR="${FHS_PREFIX_DIR}/bin"
		declare -r SDC_LIBRARY_DIR="${FHS_PREFIX_DIR}/lib"
		declare -r SDC_SHARED_RES_DIR="${FHS_PREFIX_DIR}/share/${SOFTWARE_NAME_IDENTIFIER}"
		declare -r SDC_I18N_DATA_DIR="${FHS_PREFIX_DIR}/share/locale"
		declare -r SDC_SETTINGS_DIR="/etc/${SOFTWARE_NAME_IDENTIFIER}"
		declare -r SDC_TEMP_DIR="/tmp/${SOFTWARE_NAME_IDENTIFIER}"
		;;
	SHC)
		### Self-contained Hierarchy Configuration(S.H.C.) paths
		### This is the convention when F.H.S. is not possible(not a F.H.S. compliant UNIX-like system) or not desired, everything is put under package's DIR(and for runtime-generated files, in user's directory) instead.
		#### Software installation directory prefix, should be overridable by configure/install script
		#declare -r SHC_PREFIX_DIR="${HOME}/Applications/${SOFTWARE_NAME}"
		source "${RUNTIME_SCRIPTDIR}/SOFTWARE_INSTALLATION_PREFIX_DIR.source.bash" || true
		SHC_PREFIX_DIR="$(realpath --strip "${RUNTIME_SCRIPTDIR}/${SOFTWARE_INSTALLATION_PREFIX_DIR:-..}")" # By default we expect that the software installation directory prefix is one level out of the scripts's directory
		readonly SHC_PREFIX_DIR

		declare -r SDC_EXECUTABLE_DIR="${SHC_PREFIX_DIR}/Executables"
		declare -r SDC_LIBRARY_DIR="${SHC_PREFIX_DIR}/Libraries"
		declare -r SDC_SHARED_RES_DIR="${SHC_PREFIX_DIR}/Resources"
		declare -r SDC_I18N_DATA_DIR="${SHC_PREFIX_DIR}/Resources/I18N"
		declare -r SDC_SETTINGS_DIR="${SHC_PREFIX_DIR}/Settings"
		declare -r SDC_TEMP_DIR="${HOME}/.local/tmp/${SOFTWARE_NAME_IDENTIFIER}" # Not sure about this yet, any userdir standards?
		;;
	STANDALONE)
		### Standalone Configuration
		### This program don't rely on any directories, make no attempt defining them
		;;
	*)
		printf "Error: Unknown software directories configuration, program can not continue.\n" 1>&2
		exit 1
		;;
esac

## Runtime configurations, configured by process_commandline_arguments()
#setting_name=setting_value

## Drop first element from array and shift remaining elements 1 element backward
util_array_shift(){
	local -n array_ref=${1}

	# Check input validity
	if [ "${#array_ref[@]}" -eq 0 ]; then
		printf "Error: array is empty!\n" 1>&2
		return 1
	fi

	# Unset the 1st element
	unset "array_ref[0]"

	# Repack array if element still available
	if [ "${#array_ref[@]}" -ne 0 ]; then
		array_ref=("${array_ref[@]}")
	fi

	return 0
}
readonly -f util_array_shift

## Process commandline arguments and initialize global configurations
process_commandline_arguments() {
	local -ir argument_quantity="${1}" # Number of commandline arguments
	shift
	if [ 0 -eq "${argument_quantity}" ]; then
		return
	fi
	local -a arguments=("${@}")

	while :; do
		case "${arguments[0]}" in
			--debug|-d)
				# Print a trace of simple commands, `for' commands, `case' commands, `select' commands, and arithmetic `for' commands and their arguments or associated word lists after they are expanded and before they are executed.  The value of the `PS4' variable is expanded and the resultant value is printed before the command and its expanded arguments.
				set -o xtrace
				;;
			--help|-h)
				print_help_message "${RUNTIME_COMMAND_BASE}"
				exit 0
				;;
			*)
				printf "錯誤：未知的「%s」命令列引數\n" "${1}" >&2
				print_help_message "${RUNTIME_COMMAND_BASE}"
				exit 1
				;;
		esac
		util_array_shift arguments
		if [ "${#arguments[@]}" -eq 0 ]; then
			break
		fi
	done
	return 0
}
readonly -f process_commandline_arguments

## Print helpful usage message to user, upon request or syntax error detected
print_help_message(){
	local -r command_base="${1}" # The base executable name/path of a command

	printf "# 使用方法 #\n"
	printf "%s 〈命令列選項〉\n" "$(printf "%q" "${command_base}")"
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
readonly -f print_help_message

## Defensive Bash Programming - main function, program's entry point
## http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {
	process_commandline_arguments "${RUNTIME_COMMANDLINE_ARGUMENT_NUMBER}" "${RUNTIME_COMMANDLINE_ARGUMENT_LIST[@]}"

	exit 0
}
main
