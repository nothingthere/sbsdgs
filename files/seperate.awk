/填空题/, /单选题/ {
	print > "fill.txt"
}

/单选题/, /判断题/ {
	print > "choice.txt"
}

/判断题/, /问答题/ {
	print > "correct.txt"
}

# 不知道怎样匹配到文本末，需手动复制粘贴
/问答题/ {
	print > "notes.txt"
}
