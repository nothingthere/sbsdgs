#!/bin/bash
echo "将notes.txt转换为json文件"
OUTPUT="notes2.json"

if [[ -e $OUTPUT ]]; then
	rm $OUTPUT
	cp notes.txt $OUTPUT
else
	cp notes.txt $OUTPUT
fi

if $(sed -Ei 's_^[[:digit:]]{1,}、*([^[:space:]]+)_"},\n\n{"Q":"\1",\n"A":"_' $OUTPUT); then
	echo "问题转换成功"
	# if $(sed -Ei 's_^"},$_"\n},_' $OUTPUT ); then
	if $(sed -Ei 's_^答：(.*)_\1_' $OUTPUT); then
		echo "转换成功"
	fi
	# fi
fi
