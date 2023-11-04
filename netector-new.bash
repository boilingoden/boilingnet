#!/bin/bash

# netector

echo "⚠️"
echo "⚠️"
echo "⚠️"
echo "⚠️"
echo ""
echo "                           📶 netector"
echo ""
echo ""
echo "                            dig + curl"
echo ""
echo ""
echo ""
echo ""
echo "      ensure you have at least 100 * 40 character window size"
echo "⚠️"
echo "⚠️"
echo "⚠️"
echo "⚠️"
echo ""
sleep 3
domain='gmail.com'
path='/generate_204'

redbg="\033[0;41m"
greenbg="\033[0;42m"
red="\033[0;31m"
redb="\033[0;91m"
yellow="\033[0;33m"
yellowb="\033[0;93m"
greenb="\033[0;92m" #9xm & 10xm = light
green="\033[0;32m"  #3xm & 4xm = dark
cyan="\033[0;36m"
cyanb="\033[0;96m"
gray="\033[0;37m"
darkgray="\033[0;90m"
clear="\033[0m"

lastDisconnectTime=0
lastConnectTime=0

maxmsec=1000
yellowmsec=800
greenmsec=500


dnsmaxmsec=200
dnsyellowmsec=150
dnsgreenmsec=80


tcpmaxmsec=150
tcpyellowmsec=100
tcpgreenmsec=50


tlsmaxmsec=300
tlsyellowmsec=250
tlsgreenmsec=200


# function floatToDigit() (printf '%.0f' $1)
function floatToDigit() (echo ${1%\.*})

# function percent() (echo "$(awk 'BEGIN{print '$1'/'$2'*100}')")
function percent() {
    local val=$(echo "$1/$2*100" | bc -l)
    floatToDigit $val
}


function convertToChartVlaue() {
    if [[ $1 -gt 3 ]]; then
        local totalTimePercentage=$(percent $1 $2) # value maxValue
        # to fit the chart with 33 character hight window
        totalTimePercentage=$(echo "$totalTimePercentage/3" | bc -s)
        echo $totalTimePercentage
    else
        echo $1
    fi
}

# echo "working 10%"
totalREDVALUE=$CHARTLINE
totalYELLOWVALUE=$(convertToChartVlaue $yellowmsec $maxmsec)
totalGREENVALUE=$(convertToChartVlaue $greenmsec $maxmsec)
# echo "working 20%"
dnsREDVALUE=$(convertToChartVlaue $dnsmaxmsec $maxmsec)
dnsYELLOWVALUE=$(convertToChartVlaue $dnsyellowmsec $maxmsec)
dnsGREENVALUE=$(convertToChartVlaue $dnsgreenmsec $maxmsec)
# echo "working 30%"
tcpREDVALUE=$(convertToChartVlaue $tcpmaxmsec $maxmsec)
tcpYELLOWVALUE=$(convertToChartVlaue $tcpyellowmsec $maxmsec)
tcpGREENVALUE=$(convertToChartVlaue $tcpgreenmsec $maxmsec)
# echo "working 40%"
tlsREDVALUE=$(convertToChartVlaue $tlsmaxmsec $maxmsec)
tlsYELLOWVALUE=$(convertToChartVlaue $tlsyellowmsec $maxmsec)
tlsGREENVALUE=$(convertToChartVlaue $tlsgreenmsec $maxmsec)
# echo "working 50%"
CHARTLINE=$(convertToChartVlaue $maxmsec $maxmsec) # get the highest value for chart
REDVALUE=$CHARTLINE
YELLOWVALUE=$totalYELLOWVALUE
GREENVALUE=$totalGREENVALUE
# echo "working 60%"

function colors() {
    if [[ $1 -eq 2 ]]; then
        REDVALUE=$totalREDVALUE
        YELLOWVALUE=$totalYELLOWVALUE
        GREENVALUE=$totalGREENVALUE
    elif [[ $1 -eq 3 ]]; then
        REDVALUE=$dnsREDVALUE
        YELLOWVALUE=$dnsYELLOWVALUE
        GREENVALUE=$dnsGREENVALUE
    elif [[ $1 -eq 4 ]]; then
        REDVALUE=$tcpREDVALUE
        YELLOWVALUE=$tcpYELLOWVALUE
        GREENVALUE=$tcpGREENVALUE
    elif [[ $1 -eq 5 ]]; then
        REDVALUE=$tlsREDVALUE
        YELLOWVALUE=$tlsYELLOWVALUE
        GREENVALUE=$tlsGREENVALUE
    fi
}

function alert() {
    printf "\7"
    sleep 0.15
    printf "\7"
    sleep 0.15
    printf "\7"
}

function getColor() {
    if [[ $1 -lt $greenmsec ]]; then
        echo -n $greenb
    elif [[ $1 -lt $yellowmsec ]]; then
        echo -n $cyanb
    elif [[ $1 -lt $maxmsec ]]; then
        echo -n $yellowb
    else
        echo -n $redb
    fi
}

function chart() {
    local VALUES=($@)              # all values in an array
    while [ $CHARTLINE -gt 0 ]; do # start the first line
        ((CHARTLINE--))
        local REDUCTION=$(($CHARTLINE)) # subtract this from the VALUE
        local colorSelectCounter=0
        local chartShape='▓'
        for VALUE in ${VALUES[@]}; do
            ((colorSelectCounter++))
            # colors -- color for total,dns,tcp,tls
            [[ colorSelectCounter -gt 1 ]] && colors colorSelectCounter
            # [[ colorSelectCounter -gt 2 ]] && chartShape='▒' || chartShape='▓'
            [[ colorSelectCounter -gt 2 ]] && chartShape='▓' || chartShape='◙'
            [[ colorSelectCounter -eq 5 ]] && colorSelectCounter=0
            # CHARTVALUE=$(convertToChartVlaue $VALUE $maxmsec)
            local CHUNCK=$(($VALUE - $REDUCTION))
            if [[ $VALUE -eq -123456789 ]]; then
                echo -en "${darkgray} \`${gray}"
            elif [[ $CHUNCK -le 0 ]]; then # check new VALUE
                echo -en "${gray} "
            elif [[ $VALUE -le 0 ]]; then
                echo -en "${red}  -- ${gray}" # never happens
            elif [[ $VALUE -lt $GREENVALUE ]]; then
                echo -en "${green}${chartShape}${gray}"
            elif [[ $VALUE -lt $YELLOWVALUE ]]; then
                echo -en "${cyan}${chartShape}${gray}"
            elif [[ $VALUE -lt $REDVALUE ]]; then
                echo -en "${yellow}${chartShape}${gray}"
            else
                echo -en "${red}${chartShape}${gray}"
            fi
        done
        echo
    done
    echo
}

# function headtext() {
#     local signalQuality=$1
#     local minvalue=$2
#     local alertValue=$3
#     local alertPoint=$4
#     local mute=$5
#     printf "  | ${yellowb} $alertValue${gray} (-$alertPoint)"
#     printf " | ${redb}$minvalue${gray} | mute: $mute\n"
# }

#testcmd=$(dig +timeout=3 +retry=1 google.com @8.8.8.8 | grep "Query time"| awk '{print ($4+0)}')
#testcmd=$(curl -o /dev/null -m3 -sw "%{time_total}" https://gmail.com/generate_204)

# curl will cache the DNS requests for 60 seconds and there is no way to ovoid it:
# https://stackoverflow.com/a/25681164
# and in the default installation there is no way of using the external DoUDP servers:
# https://everything.curl.dev/usingcurl/connections/name#name-resolve-tricks-with-c-ares
function digcmd() {
    dig +timeout=1 +retry=0 "$domain" @8.8.8.8 | grep "Query time"| awk '{print ($4+0)}'
}

function curlcmd() {
    # user-agent: https://datatracker.ietf.org/doc/html/rfc9309#name-the-user-agent-line
    local userAgent="user-agent: curl/7.88.1 "
    userAgent+="(compatible; ConnectivityCheckBot/0.1; https://soon.example.com/bot/)"
    curl -o /dev/null -4H "$userAgent" -m2 -sw "%{json}\n" https://"$domain$path"
}

function toMiliSec() {
    local inputValue=0
    if [ "$#" -ne 0 ]; then
        inputValue=$1
    else
        inputValue=$(</dev/stdin)
    fi
    local testvalue=$(bc <<<$inputValue*1000) #seconds to miliseconds
    floatToDigit $testvalue                   #trim: ~ float to integer
}

function setTitleConnected() {
    printf '\e]2;%s\a' "Netector | $1 ms -- uptime $2 | mute: $3"
}

function setTitleDisconnected() {
    printf '\e]2;%s\a' "Netector | downtime $1 | mute: $2"
}

function clearInput() (while read -r -t 0; do read -r -t 3; done)

function toChartValues() {
    local VALUES=($@)
    local CHARTVALUES=()
    for VALUE in ${VALUES[@]}; do
        CHARTVALUES+=($(convertToChartVlaue $VALUE $maxmsec))
    done
    echo ${CHARTVALUES[@]}
}

function netector() {
    # tput smcup
    SECONDS=1
    local dis=false
    # local disTemp=false
    local tailValues=()
    local chartValues=()
    local maxarray=16
    local mute=0
    local showGraph=1
    local secondsTemp
    while true; do
        # echo
        secondsTemp=$SECONDS
        local resultdig=$(digcmd)
        [[ resultdig -eq '' ]] && resultdig=0
        # local result=$(
        #     { stdout=$(curlcmd); returncode=$?; } 2>&1
        #     printf ". . . - - - . . .\n"
        #     printf "%s\n" "$stdout"
        #     exit "$returncode"
        # )
        # local var_out=${result#*this line is the separator$'\n'}
        # local var_err=${result%$'\n'this line is the separator*}
        # local returncode=$?
        local resultjson=$(curlcmd)
        local exitCode=$(echo $resultjson | jq .exitcode)
        local errorMsg=$(echo $resultjson | jq .errormsg)

        local lookupTime=$(echo $resultjson | jq .time_namelookup | toMiliSec)
        local tcpHandshakeTime=$(
            echo $resultjson | jq .time_connect | toMiliSec | awk -v dnstime="$lookupTime" '{print $1-dnstime}'
        )
        local sslHandshakeTime=$(
            echo $resultjson | jq .time_appconnect | toMiliSec | awk -v ssltime="$tcpHandshakeTime" '{print $1-ssltime}'
        )
        # local untilHttpStartTime=$(echo $resultjson | jq .time_starttransfer | toMiliSec)
        local totalTime=$(
            echo $resultjson | jq .time_total | toMiliSec | awk -v dnstime="$resultdig" '{print $1+dnstime}'
        )
        # local totalTime=$(echo $resultjson | jq .time_total | toMiliSec)

        # local downloadSpeed=$(echo $resultjson | jq .speed_download)
        # local uploadSpeed=$(echo $resultjson | jq .speed_upload)

        # local responseCode=$(echo $resultjson | jq .response_code)
        # local remoteIp=$(echo $resultjson | jq .remote_ip)
        # local certs=$(echo $resultjson | jq .certs)
        # printf "\n\n"
        # clear
        local graphValue=0
        local txtColor=$gray
        local sleepValue=0
        local outputHead1=''
        local outputChart=''
        local outputTail=''
        local chartValue=0
        local chartValuedns=0
        local chartValuetcp=0
        local chartValuessl=0
        if [[ $exitCode -gt 0 ]] || [[ resultdig -eq 0 ]] && [[ $dis = false ]]; then
            lastConnectTime=$SECONDS
            # skip the first error (where there is a lot of noise)
            # if [[ $disTemp = false ]]; then
            #     disTemp=true
            #     SECONDS=3 # set terminal's second counter to 3
            # else
            #     dis=true
            #     [[ $mute -eq 0 ]] && alert
            #     SECONDS=6
            # fi
            dis=true
            [[ $mute -eq 0 ]] && alert
            SECONDS=$(($SECONDS - $secondsTemp))
            outputHead1=$(printf "${redbg} ❌ disconnected!!! :(( ${clear}")
            outputHead1+=$(printf "${red} ⚠️ $exitCode: $errorMsg ${clear}\n")
            tailValue=-1
            if [[ $showGraph -eq 1 ]]; then
                chartValue=-1
                [[ $resultdig -gt 0 ]] && chartValuedns=$(convertToChartVlaue $resultdig $maxmsec)
                #[[ $lookupTime -gt 0 ]] && chartValuedns=$(convertToChartVlaue $lookupTime $maxmsec)
                [[ $tcpHandshakeTime -gt 0 ]] && chartValuetcp=$(convertToChartVlaue $tcpHandshakeTime $maxmsec)
                [[ $sslHandshakeTime -gt 0 ]] && chartValuessl=$(convertToChartVlaue $sslHandshakeTime $maxmsec)
            fi
        elif [[ $exitCode -gt 0 ]] || [[ resultdig -eq 0 ]]; then
            [[ $mute -eq 0 ]] && printf "\7"
            dis=true
            outputHead1=$(printf "${yellow} ❌ still disconnected!!! :(( ${clear}")
            outputHead1+=$(printf "${red} ⚠️ $exitCode: $errorMsg ${clear}\n")
            tailValue=-1
            if [[ $showGraph -eq 1 ]]; then
                chartValue=-1
                [[ $resultdig -gt 0 ]] && chartValuedns=$(convertToChartVlaue $resultdig $maxmsec)
                #[[ $lookupTime -gt 0 ]] && chartValuedns=$(convertToChartVlaue $lookupTime $maxmsec)
                [[ $tcpHandshakeTime -gt 0 ]] && chartValuetcp=$(convertToChartVlaue $tcpHandshakeTime $maxmsec)
                [[ $sslHandshakeTime -gt 0 ]] && chartValuessl=$(convertToChartVlaue $sslHandshakeTime $maxmsec)
            fi
            sleepValue=8
        elif [[ $dis = true ]]; then
            lastDisconnectTime=$SECONDS
            dis=false
            disTemp=false
            SECONDS=$(($SECONDS - $secondsTemp))
            [[ $mute -eq 0 ]] && alert
            outputHead1=$(printf "${greenbg} 📶 connected! :D ${clear}")
            txtColor=$cyanb
            tailValue=$totalTime
            if [[ $showGraph -eq 1 ]]; then
                chartValue=$(convertToChartVlaue $totalTime $maxmsec)
                [[ $resultdig -gt 3 ]] && chartValuedns=$(convertToChartVlaue $resultdig $maxmsec)
                #[[ $lookupTime -gt 3 ]] && chartValuedns=$(convertToChartVlaue $lookupTime $maxmsec)
                [[ $tcpHandshakeTime -gt 3 ]] && chartValuetcp=$(convertToChartVlaue $tcpHandshakeTime $maxmsec)
                [[ $sslHandshakeTime -gt 3 ]] && chartValuessl=$(convertToChartVlaue $sslHandshakeTime $maxmsec)
            fi
            sleepValue=1
        else
            disTemp=false
            tailValue=$totalTime
            if [[ $showGraph -eq 1 ]]; then
                chartValue=$(convertToChartVlaue $totalTime $maxmsec)
                [[ $resultdig -gt 3 ]] && chartValuedns=$(convertToChartVlaue $resultdig $maxmsec)
                #[[ $lookupTime -gt 3 ]] && chartValuedns=$(convertToChartVlaue $lookupTime $maxmsec)
                [[ $tcpHandshakeTime -gt 3 ]] && chartValuetcp=$(convertToChartVlaue $tcpHandshakeTime $maxmsec)
                [[ $sslHandshakeTime -gt 3 ]] && chartValuessl=$(convertToChartVlaue $sslHandshakeTime $maxmsec)
            fi
            txtColor=$(getColor $totalTime)
            sleepValue=1
        fi
        local elapsed=$(date -ud @${SECONDS} +"%H:%M:%S")
        local elapsedDisconnect=$(date -ud @${lastDisconnectTime} +"%H:%M:%S")
        local elapsedConnect=$(date -ud @${lastConnectTime} +"%H:%M:%S")
        if [[ $exitCode -eq 0 ]]; then
            outputHead1+=$(printf "${txtColor} 🔄 Total time: $totalTime ms ")
            outputHead1+=$(printf "  🔄 DNS time: $resultdig ms ")
            outputHead1+=$(printf "  🔄 TCPH time: $tcpHandshakeTime ms ")
            outputHead1+=$(printf "  🔄 TLSH time: $sslHandshakeTime ms ")
            outputHead1+=$(printf "${clear}\n")
            outputHead1+=$(setTitleConnected $totalTime $elapsed $mute)
        else
            outputHead1+=$(setTitleDisconnected $elapsed $mute)
        fi
        local outputHead2=$(printf "${gray} 🔌 current time: $elapsed ")
        outputHead2+=$(printf "  ${gray}❌ last Disconnect time: $elapsedDisconnect ")
        outputHead2+=$(printf "  ${gray}📶 last Connect time: $elapsedConnect ")
        outputHead2+=$(printf "${clear}\n")
        local tailValues+=($tailValue)
        if [[ $showGraph -eq 1 ]]; then
            chartValues+=(-123456789)
            chartValues+=($chartValue)
            chartValues+=($chartValuedns)
            chartValues+=($chartValuetcp)
            chartValues+=($chartValuessl)
        fi
        if [[ ${#tailValues[@]} -gt $maxarray ]]; then
            tailValues=("${tailValues[@]:1}")
            chartValues=("${chartValues[@]:5}")
        fi
        if [[ $showGraph -eq 1 ]]; then
            # echo
            outputChart=$(chart ${chartValues[@]})
            outputTail=$(printf '  %-4s' "${tailValues[@]}")
        fi
        read -r -t .1 -sn 1 input
        if [[ $input == "m" ]] || [[ $input == "M" ]]; then
            ((mute ^= 1))
            clearInput
        elif [[ $input == "g" ]] || [[ $input == "G" ]]; then
            ((showGraph ^= 1))
            chartValues=($(toChartValues ${tailValues[@]}))
            # printf ' %-4s' "${chartValues[@]}"
            clearInput
            echo
        elif [[ $input == "q" ]] || [[ $input == "Q" ]]; then
            echo
            break
        else
            clearInput
        fi
        # read -d '' -t 0.6 -n 10000
        # sleep .4
        # tput clear
        [[ $showGraph -eq 1 ]] && printf "\n\n"
        echo "$outputHead"
        echo "$outputHead1"
        echo "$outputHead2"
        if [[ $showGraph -eq 1 ]]; then
            echo
            echo "$outputChart"
            echo
            echo -n "$outputTail"
        fi
        sleep $sleepValue
    done
    # tput rmcup
    exit
}

netector