#!/bin/bash
# 上列為宣告執行 script 程式用的殼程式(shell)的 shebang
# 〈程式檔名〉 - 〈程式描述文字（一言以蔽之）〉
# 〈程式智慧財產權擁有者名諱、地址（選用）〉 © 〈智慧財產權生效年〉
# 〈更多程式描述文字〉

######## Included files ########

######## Included files ended ########

######## File scope variable definitions ########
# Defensive Bash Programming
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
readonly PROGRAM_FILENAME="$(basename "$0")"
readonly PROGRAM_DIRECTORY="$(realpath --no-symlinks "$(dirname "$0")")"
readonly PROGRAM_ARGUMENT_ORIGINAL_LIST="$@"
readonly PROGRAM_ARGUMENT_ORIGINAL_NUMBER=$#

######## File scope variable definitions ended ########

######## Program ########
# main function, program entry point
# Also from Defensive Bash Programming
# http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
main() {

	## 正常結束 script 程式
	exit 0
}
main
######## Program ended ########