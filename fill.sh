#!/bin/bash
# 填空题脚本
FILE=files/fill.json

question=						# 问题
answer=							# 答案
answer_num=						# 答案个数
COUNT=$(jq '.|length' $FILE)			# 题目数量
index=0									# 当前第几题
# motion=									# 下一步动作

# 退出
function quit {
	echo "再见！"
	exit
}

# 去除答案和问题中的双引号
function trim_quote {
	echo $(echo $1 | sed 's/"//g')
}

# 打印问题
function render_question {
	printf "\n\n"
	question=$(trim_quote $question)

	# 蓝色
	printf "$((index + 1)). %s\n\n" $(blue $question)
}

# 打印输入提示
function render_prompt {
	cat <<EOF
q) 退出
h) 提示
n) 下一题
Enter) 检查答案
EOF

	echo
	read -p "答： "
}

function after_hint_render {
    cat <<EOF
q) 退出
n) 下一题
r) 重做
EOF

	local motion 				# 选择
	read -p "> " motion

	case $motion in
		q|Q) quit
			 ;;
		n|N) ((index++))
			 play
			 ;;
		r|R) play
			 ;;
		*) after_hint_render
		   ;;
	esac
}

# 显示正确答案
function render_hint {
	echo -e "\n正确答案为："
	for((i=0; i < answer_num; i++)); do
		printf "%s " $(trim_quote $(blue $(echo $answer | jq ".[$i]" )))
	done
	printf "\n\n"

	after_hint_render
}

# 检查答案
function suply_answer {
	# echo "你的答案为： $REPLY"
	local correct=true				# 答案是否正确

	for((i=0; i < answer_num; i++)); do
		if [[ ! $(echo $REPLY | grep $(trim_quote $(echo $answer | jq ".[$i]")) ) ]]; then
			# echo $(trim_quote $i)
			# echo $REPLY
			correct=false
			break
		fi
	done

	if $correct; then			# 答案正确
		after_answer_correct
	else						# 答案错误
		after_answer_incorrect
	fi

}

function after_answer_correct {
	echo $(blue "√√√")
	cat <<EOF
q) 退出
n) 下一题
EOF

	local motion
	read -p "> " motion

	case $motion in
		q|Q) quit
			 ;;
		n|N) ((++index))
			 play
			 ;;
		*) after_answer_correct
		   ;;
	esac
}

function after_answer_incorrect {
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
		r|R) play
			 ;;
		h|H) render_hint
			 ;;
		*) after_answer_incorrect
		   ;;
	esac

}

function play {
	clear
	question=$(jq ".[$index]" $FILE | jq '.Q')
   	answer=$(jq ".[$index]" $FILE | jq '.A')
	answer_num=$(echo $answer | jq '.|length')
	render_question
	render_prompt

	# 处理输入内容

	case $REPLY in
		q|Q) quit
			 ;;
		h|H) render_hint 		# 不会做给出答案
			 ;;
		n|N) ((++index))			# 跳过此题
			 play
			 ;;
		*) suply_answer 		# 提交答案
	esac

}

play
