#!/bin/bash
echo "将fill.txt文件转换为json文件"

OUTPUT="fill2.json"				# 新生成文件

if [[ -e $OUTPUT ]]; then
	rm $OUTPUT
	cp fill.txt $OUTPUT
else
	cp fill.txt $OUTPUT
fi

if $(sed -Ei 's_^[0-9]{1,3}、(.*)_{"Q":"\1",\n"A":[]},\n_' $OUTPUT); then
	echo "转换成功"
	echo "为不损坏原来的文件(fill.json)，新生成的文件为'$OUTPUT'"
	echo "需手动在首位添加方括号，使JSON数据转变为数组"
	if [[ ! $(jsonlint $OUTPUT) ]]; then
		echo "'$OUTPUT'文件内部还有些格式不正确"
	fi
fi
