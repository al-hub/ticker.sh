#!/bin/bash
set -e

LANG=C
LC_NUMERIC=C

SYMBOLS=("$@")

FILE=xml_parsing.sh
if [ -e $FILE ] && [ $# -eq 0 ]; then
	SYMBOLS=$(sh $FILE | cut -d ' ' -f 2 | sed 's|\(.*\)|\1.ks \1.kq|g')
fi

if ! $(type jq > /dev/null 2>&1); then
  echo "'jq' is not in the PATH. (See: https://stedolan.github.io/jq/)"
  exit 1
fi

if [ -z "$SYMBOLS" ]; then
  echo "Usage: ./ticker.sh AAPL MSFT GOOG BTC-USD 009150.ks"
  exit
fi

FIELDS=(symbol marketState regularMarketPrice regularMarketChange regularMarketChangePercent \
  preMarketPrice preMarketChange preMarketChangePercent postMarketPrice postMarketChange postMarketChangePercent)
API_ENDPOINT="https://query1.finance.yahoo.com/v7/finance/quote?lang=en-US&region=US&corsDomain=finance.yahoo.com"

if [ -z "$NO_COLOR" ]; then
  : "${COLOR_BOLD:=\e[1;37m}"
  : "${COLOR_GREEN:=\e[32m}"
  : "${COLOR_RED:=\e[31m}"
  : "${COLOR_RESET:=\e[00m}"
  : "${COLOR_BLUE:=\e[34m}"
fi

symbols=$(IFS=,; echo "${SYMBOLS[*]}")
fields=$(IFS=,; echo "${FIELDS[*]}")

if [ -e $FILE ] && [ $# -eq 0 ]; then
	symbols=$(echo $SYMBOLS | tr -s ' ' ',')
	symbols=${symbols:0:9*1000} #limitation max 1000 company
fi

results=$(curl --silent "$API_ENDPOINT&fields=$fields&symbols=$symbols" \
  | jq '.quoteResponse .result')

query () {
  echo $results | jq -r ".[] | select(.symbol == \"$1\") | .$2"
}

for symbol in $(IFS=' '; echo "${SYMBOLS[*]}" | tr '[:lower:]' '[:upper:]'); do

  marketState="$(query $symbol 'marketState')"

  if [ -z $marketState ]; then
    #printf 'No results for symbol "%s"\n' $symbol
    continue
  fi

  preMarketChange="$(query $symbol 'preMarketChange')"
  postMarketChange="$(query $symbol 'postMarketChange')"

  if [ $marketState == "PRE" ] \
    && [ $preMarketChange != "0" ] \
    && [ $preMarketChange != "null" ]; then
    nonRegularMarketSign='*'
    price=$(query $symbol 'preMarketPrice')
    diff=$preMarketChange
    percent=$(query $symbol 'preMarketChangePercent')
  elif [ $marketState != "REGULAR" ] \
    && [ $postMarketChange != "0" ] \
    && [ $postMarketChange != "null" ]; then
    nonRegularMarketSign='*'
    price=$(query $symbol 'postMarketPrice')
    diff=$postMarketChange
    percent=$(query $symbol 'postMarketChangePercent')
  else
    nonRegularMarketSign=''
    price=$(query $symbol 'regularMarketPrice')
    diff=$(query $symbol 'regularMarketChange')
    percent=$(query $symbol 'regularMarketChangePercent')
  fi

  if [ "$diff" == "0" ] || [ "$diff" == "0.0" ]; then
    color=
  elif ( echo "$diff" | grep -q ^- ); then
    color=$COLOR_BLUE
  else
    color=$COLOR_RED
  fi

  if [ "$price" != "null" ]; then

    if [ -e $FILE ] && [ $# -eq 0 ]; then
	symbol=$(sh $FILE | grep ${symbol:0:6} | cut -d ' ' -f 1)
    fi
 
    printf "%-15s$COLOR_BOLD\t%8.0f$COLOR_RESET" $symbol $price
    printf "$color%10.2f%12s$COLOR_RESET" $diff $(printf "(%.2f%%)" $percent)
    printf " %s\n" "$nonRegularMarketSign"

  fi

done
