# 填空题转换
BEGIN { print "["
}

{
	build_qustion = "sed -E 's/^[[:digit:]]{1,}、(.*)/\"A\":\"\\1\",/'"
	remove_space = "sed -E 's/[[:space:]]//g'"
	print  $1  | remove_space  |  build_qustion # 好像不能载管道中连续传递

}

END { print "]"}
