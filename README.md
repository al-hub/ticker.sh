# ticker.sh
This repository forked from https://github.com/pstadler/ticker.sh  
And I am combining with KS by script level.

> Real-time stock tickers from the command-line.

`ticker.sh` is a simple shell script using the Yahoo Finance API as a data source. It features colored output and is able to display pre- and post-market prices (denoted with `*`).

![ticker.sh](https://raw.githubusercontent.com/pstadler/ticker.sh/master/screenshot.png)

## Install

```sh
$ curl -o ticker.sh https://raw.githubusercontent.com/pstadler/ticker.sh/master/ticker.sh
```

Make sure to install [jq](https://stedolan.github.io/jq/), a versatile command-line JSON processor.

## Install JQ
```
$ curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /usr/local/bin/jq 
$ chmod a+x /usr/local/bin/jq 
$ jq -V
```

## Usage

```sh
# Single symbol:
$ ./ticker.sh AAPL

# Multiple symbols:
$ ./ticker.sh AAPL MSFT GOOG BTC-USD

# Read from file:
$ echo "AAPL MSFT GOOG BTC-USD" > ~/.ticker.conf
$ ./ticker.sh $(cat ~/.ticker.conf)

# Use different colors:
$ COLOR_BOLD="\e[38;5;248m" \
  COLOR_GREEN="\e[38;5;154m" \
  COLOR_RED="\e[38;5;202m" \
  ./ticker.sh AAPL

# Disable colors:
$ NO_COLOR=1 ./ticker.sh AAPL

# Update every five seconds:
$ watch -n 5 -t -c ./ticker.sh AAPL MSFT GOOG BTC-USD
# Or if `watch` is not available:
$ while true; do clear; ./ticker.sh AAPL MSFT GOOG BTC-USD; sleep 5; done
```

This script works well with [GeekTool](https://www.tynsoe.org/geektool/) and similar software:

```sh
PATH=/usr/local/bin:$PATH # make sure to include the path where jq is located
~/GitHub/ticker.sh/ticker.sh AAPL MSFT GOOG BTC-USD
```
