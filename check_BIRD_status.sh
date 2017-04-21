#!/usr/bin/env bash

#Set script name
SCRIPT=`basename ${BASH_SOURCE[0]}`

#Set default values
protocol=IPv4

# help function
function printHelp {
  echo -e "Nagios check for BIRD routing daemon v1.0"
  echo -e "Help for $SCRIPT"
  echo -e "Basic usage: $SCRIPT -p {protocol}"
  echo -e "-p Sets process check for given protocol: IPv4 or IPv6"
  echo -e "-h Displays this help message"
  echo -e "Example: $SCRIPT -p IPv4"
  echo -e "Author: Rafal Dwojak, rafal@dwojak.com"
  echo -e "Github: https://github.com/rafaldwojak/check_BIRD_status"
  exit 1
}

re='^IPv([4|6]+)$'
while getopts :p:h FLAG; do
  case $FLAG in
    p)
      if ! [[ $OPTARG =~ $re ]] ; then
        echo "error: Invalid parameter" >&2; exit 1
      else
        protocol=$OPTARG
      fi
      ;;
    h)
      printHelp
      ;;
    \?)
      echo -e "Option -$OPTARG not allowed.\\n"
      printHelp
      exit 2
      ;;
  esac
done

shift $((OPTIND-1))

if [ "$protocol" == "IPv4" ]; then
readarray -t array <<< "$(birdc show status)"
else
readarray -t array <<< "$(birdc6 show status)"
fi

if [ "$protocol" == "IPv4" ]; then
readarray -t array <<< "$(birdc show status)"
else
readarray -t array <<< "$(birdc6 show status)"
fi

processStatus=${array[6]}

if [ "$processStatus" == "Daemon is up and running" ]; then
    echo -e "OK: BIRD $protocol $processStatus"
    exit 0
else
    echo -e "CRITICAL: BIRD $protocol $processStatus"
    exit 2
fi
