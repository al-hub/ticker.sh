#!/bin/sh
#example) xml_parsing.sh KEC HMM
url=http://kind.krx.co.kr/corpgeneral/corpList.do?method=download 
FILE=company.txt

#wget
corpList=download$(date +_%F)
if [ ! -e $corpList ]; then
	wget -O $corpList $url
fi

#parameter check
if [ $# -ne 0 ]; then
	param=`echo $@ | sed 's/ /\\\|/g'`
elif [ -e $FILE ]; then
	param=`cat $FILE`
	param=`echo $param | sed 's/ /\\\|/g'`
else
	param='$'
fi

iconv -f euc-kr -t utf-8 $corpList \
	| sed 's|td[^>]*>|td>|g' | tr -d ' \n\t\015' \
	| sed 's/<tr>/\n<tr>/g'  | awk -F "<td>|</td>" '{print $2, $4}' \
	| sed '/^[[:space:]]*$/d'  | grep $param 
