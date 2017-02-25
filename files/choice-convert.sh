#!/bin/bash
echo "将choice.txt文件转换为json文件"

OUTPUT="choice2.json"				# 新生成文件

if [[ -e $OUTPUT ]]; then
	rm $OUTPUT
	cp choice.txt $OUTPUT
else
	cp choice.txt $OUTPUT
fi

if $(sed -Ei 's_^[0-9]{1,3}、[[:space:]]*([^[:space:]]+)[[:space:]]*（(.*)*）.*_]},\n\n{"Q":"\1",\n"A":"\2",\n"S":[_' $OUTPUT); then # 转换问题和答案
	echo "问题转换成功"
	# 将文本中间的空格去除
	# sed -Ei 's_([^[:space:]]+)([[:space:]]+)([^[:space:]]+)_\1\3_g' $OUTPUT
	if $(sed -Ei 's_[A-F][、.][[:space:]]*([^[:space:]]+)_"\1",_g' $OUTPUT); then # 转换选项
		sed -Ei 's_(".*),$_\1_' $OUTPUT
		# 选项转换分下列情况：
		# 1. 都在一行
		# 2. 分2行
		# 3. 每个选项一行
		# 4. 只有4个选项
		# 5. 有6个选项
		echo "选项转换成功"
	fi
fi
