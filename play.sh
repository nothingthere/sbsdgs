#!/bin/bash
#题库测试总脚本
function usage {
	echo "${0##*/} [-t|--type [f|c|y|n|p]] [-n|--number 正整数]" >&2
	cat <<EOF
--type参数的值中：
f表示填空题
c表示选择题
y表示判读题
n表示简答题
p表示陈述题
EOF

	exit 1
}

type=f							#题型可为f、c、y、n或p
DIR=files/						# 存放题库文件的文件夹
file=fill.json							# 题库文件
count=			# 题目和答案数量
num=1			# 第几题（输入索引）
index=$(( num - 1))									# 当前第几题（数组索引）

question=						# 问题
answer=							# 答案
select=							# 如果是选择题，用来存放选项
answer_num=						# 答案个数

# 通过参数确定题型
while [[ -n $1 ]]; do
	# echo "\$1 = $1" #TEST
	case $1 in
		-t|--type) shift
				   if [[ $1 =~ ^[fcynp]$ ]];then
					   type=$1
				   else
					   echo "题型参数不正确" # TEST
					   usage
				   fi
				   ;;
		-n|--number) shift
					 if [[ $1 =~ ^[1-9][0-9]*$ ]]; then
						 num=$1
					 else
						 echo "数字参数不正确" # TEST
						 usage
					 fi
					 ;;
		*) usage
		   ;;
	esac

	shift
done
# echo "\$type = $type, \$index = $index" #TEST

# 根据type变量确定题库文件
if [[ ! -d $DIR ]]; then
	echo "存放题库文件的文件夹'$DIR'不存在" >&2
	exit 1
fi

case $type in
 	f) file=fill.json
	   ;;
	c) file=choice.json
	   ;;
	y) file=correct.json
	   ;;
	n) file=notes.json
	   ;;
	p) file=presentation.json
	   ;;
esac

file=${DIR}$file

if [[ ! ( -e $file && -r $file) ]]; then
	echo "当前文件夹中'$file'文件不存在或不可读！" >&2
	exit 1
fi

# 再根据文件确定其中题目的个数
count=$(jq '.|length' $file)
# 以此再判断index的值是否合法（已过滤为正整数）
if (( num > count )); then
	echo "最多只有'$count'道题，第'$num'题不存在" >&2
	exit 1
fi
index=$(( num - 1))				# 确定数组索引

###############
# 原材料准备完毕，接下来为打印和逻辑判断
###############

# 去除答案和问题中的双引号
function trim_quote {
	echo $(echo $1 | sed 's/"//g')
}

# 正常退出
function quit {
	echo "再见！"
	exit
}

function print_hint {
	printf "\n正确答案是："

	# 如果是填空题，答案为数组，循环打印
	if [[ $type == f ]]; then
		for((i=0; i < answer_num; i++)); do
			printf "%s " $(blue $(trim_quote $(echo $answer | jq ".[$i]")))
		done
		printf "\n"
	else # 其他类型题目答案为字符串，打印即可
		echo $(blue $(trim_quote $answer))
		printf "\n"
	fi

	after_print_hint
}

# 显示正确答案后的交互
function after_print_hint {
    cat <<EOF
q)退出
r)重做
n)下一题
EOF
	local motion
	read -p "> " motion

	case $motion in
		q|Q) quit
			 ;;
		n|N) ((index++))
			 main
			 ;;
		r|R) main
			 ;;
		*) after_print_hint
		   ;;
	esac
}

# 检查答案
function check_answer {
	echo "你的回答是：$1" # TEST
	# echo "正确答案是：$answer"	# TEST
	local correct=true

	if [[ $type == f ]]; then 	# 如果是填空题，则逐个检查
		# 逐个检查answer中数组元素是否都出现在提交的答案内
		# 此算法存在的问题：
		# 1. 填空的顺序错误也认为是正确
		# 2. 每个空的答案不间隔开也可能判断为正确答案
		for((i=0; i < answer_num; i++)); do
			if [[ ! $(echo $1 | grep $(trim_quote $(echo $answer | jq ".[$i]"))) ]]; then
				correct=false
				break
			fi
		done
	else						# 否则比较答案与提交字符串即可
		if [[ ! ($1 == $(trim_quote $answer)) ]]; then
			correct=false
		fi
	fi

	# 更加答案正确与否提供交互
	if $correct; then
		when_answer_correct
	else
		when_answer_incorrect
	fi
}

# 答案正确后的交互
function when_answer_correct {
	echo $(blue "√√√")
	cat <<EOF
q)退出
n)下一题
EOF

	local motion=
	read -p "> " motion
	case $motion in
		q|Q) quit
			 ;;
		n|N) ((++index))
			 main
			 ;;
		*) when_answer_correct
	esac
}

#答案错误后的交互
function when_answer_incorrect {
	echo -e "\a" $(yellow "XXX")
	cat <<EOF
q) 退出
r) 重做
h) 提示
EOF

	local motion
	read -p "> " motion

	case $motion in
		q|Q) quit
			 ;;
		r|R) main
			 ;;
		h|H) print_hint
			 ;;
		*) when_answer_incorrect
		   ;;
	esac
}

# 打印问题
function print_question {
	# 蓝色打印问题
	printf "($((index + 1))/$count)： %s\n" $(blue $( trim_quote $question))

	# 如果是选择题，则打印选项
	local select_num=$(echo $select | jq '.|length')			# 选项个数
	local ICONS=(A B C D E F G H)
	if [[ $type == c ]]; then
		for((i=0; i < select_num; i++)); do
			printf "\t%s. %s\n" ${ICONS[$i]} $(blue $(trim_quote $(echo $select | jq ".[$i]")))
		done
	fi

	# 提示输入
	cat <<EOF
q) 退出
h) 提示
n) 下一题
Enter) 检查答案
EOF
	printf "\n"
	read -p "答： " reply

	# 处理输入答案
	case $reply in
		q|Q) quit
			 ;;
		h|H) print_hint 		# 不会做给出答案
			 ;;
		n|N) ((++index))			# 跳过此题
			 main
			 ;;
		*) check_answer "${reply[@]}"		# 提交答案
	esac

}

# 到最后一题时再继续的交互
function choice_at_last_test {
	cat <<EOF
q)退出
r)再做一遍
EOF

	local motion
	read -p "> " motion

	case $motion in
		q|Q) quit
			 ;;
		r|R) index=0
			 main
			 ;;
		*) choice_at_last_test
		   ;;
	esac
}

function main {
	#主函数
	if (( index == count)); then # 做到最后一题
		printf "\n已经是最后一题\n"
		choice_at_last_test
	fi

	clear
	local item=$(jq ".[$index]" $file)				# 单个题目

	question=$(echo $item | jq '.Q')
   	answer=$(echo $item | jq '.A')

	# echo "\$question = $question" # TEST
	# echo "\$answer = $answer"	  # TEST
	#如果答案是数组（即为填空题），获取答案数组长度

	if [[ $type == f ]]; then
		answer_num=$(echo $answer | jq '.|length')
		# echo "答案个数：$answer_num" # TEST
	fi

	# 如果是选择题（即JSON数据有key值"S"）获取选项
	if [[ $type == c ]]; then
		select=$(echo $item | jq '.S')
		# echo "\$select= $select" # TEST
	fi

	# 确定完成所有变量，开始打印题目和交互
	print_question

}
main
