#!/bin/bash
echo "将notes.txt转换为json文件"
OUTPUT="correct2.json"

if [[ -e $OUTPUT ]]; then
	rm $OUTPUT
	cp correct.txt $OUTPUT
else
	cp correct.txt $OUTPUT
fi

if $(sed -Ei 's_^[[:digit:]]{1,}、[[:space:]]*([^[:space:]]+)_{"Q":"\1",\n_' $OUTPUT); then
	if $(sed -Ei 's_（[[:space:]]*√[[:space:]]*）_"A":"yes"\n},\n_' $OUTPUT); then
		if $(sed -Ei 's_（[[:space:]]*×[[:space:]]*）_"A":"no"\n},_' $OUTPUT); then
			echo "转换成功"
		fi
	fi
fi
