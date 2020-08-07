#!/bin/bash
# Program:
#       This program is to query Boshiamy (Chinese input method) code.
# History:
# 2020/08/07	Honginho Chang	First release


###############################################
### Check if syntax correct ###################
###############################################
if [ $# -ne 1 ]; then
	echo "Usage: ./$(basename $0) KEYWORD"
	exit -1
fi


###############################################
### Variable setting ##########################
###############################################
COLOUR_HEAD="\e[0;35m"
COLOUR_TEXT="\e[0;33m"
COLOUR_CHECK="\e[0;36m"

curl=$(which curl)
outputfile="_bsm_webpage_$(date | shasum | awk '{print substr($0, 1, 8);}').txt"
keyword=$1
url="http://boshiamy.com/liuquery.php?q=$keyword&f=1"
category=('' '繁體中文模式' '簡體中文模式' '打繁出簡模式' '日文模式') # category of type mode


###############################################
### Dump webpage ##############################
###############################################
$curl -s -o $outputfile $url


################################################
### Check if error occur #######################
################################################
[ $? -ne 0 ] && echo "Error: Fail to download webpage..." && exit -1


################################################
### Get input method code result (with html) ###
################################################
result=($(grep "<tbody>" $outputfile | awk -F'<tbody>|<\/tbody>' '{print $2}' | sed 's/<td[^>]*>/<td>/g' | sed 's/<span[^>]*>/<span>/g' | sed 's/ //g' | awk -F'<td>|<\/td>' '{for (i=1; i<=NF; i++) { print $i "\n" } }'))
## check "$result" content
	# for i in "${result[@]}"; do
	# 	printf "$COLOUR_CHECK%s" $i
	# 	echo ""
	# done


################################################
### Clean result and output ####################
################################################
# remove first item: <tr>
result=("${result[@]:1}")
# remove last item: </tr>
result=("${result[@]::${#result[@]}-1}")

# show searched results
for ((i=1; i<=${#result[@]}-1; i++)); do # ${#result[@]}: length of result array
	# get input method code result of each mode
	each_result=($(echo "${result[$i]}" | awk -F'<ul>|<\/ul>' '{print $2}' | awk -F'<li>|<\/li>' '{for (i=1; i<=NF; i++) { print $i } }'))
	## check "$each_result" content
		# for k in "${each_result[@]}"; do
		# 	printf "$COLOUR_CHECK%s" $k
		# 	echo ""
		# done

	# clean input method code and put into array
	result_without_dirt=()
	for j in "${each_result[@]}"; do
		result_without_dirt+=($(echo $j | sed 's/.*<span>\([^\(<\/span>\)]*\)<\/span>.*/\1/'))
	done

	# show final results with colours
	printf "$COLOUR_HEAD%s\t" ${category[$i]}
	for j in "${result_without_dirt[@]}"; do
		printf "$COLOUR_TEXT%s\t" $j
	done
	echo "" # breakline
done


################################################
### Delete tmp file created by $curl command ###
################################################
rm $outputfile


################################################
### END  END  END  END  END  END  END  END #####
################################################
exit 0
