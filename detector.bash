#!/bin/bash

# dettector

redbg="\033[0;41m"
greenbg="\033[0;42m"
red="\033[0;31m"
redb="\033[0;91m"
yellow="\033[0;33m"
yellowb="\033[0;93m"
greenb="\033[0;92m" #9xm & 10xm = light
green="\033[0;32m" #3xm & 4xm = dark
cyan="\033[0;36m"  
gray="\033[0;37m"
clear="\033[0m"

function median() {
    local data=($@)
    IFS=$'\n' sorted_data=($(sort <<<"${data[*]}"))
    local num_elements=${#sorted_data[@]}
    if (($num_elements % 2 == 1)); then # Odd number of elements
        ((middle = $num_elements / 2))
        local val="${sorted_data[$(($num_elements / 2))]}"
    else # Even number of elements
        ((before_middle = $num_elements / 2 - 1))
        ((after_middle = $num_elements / 2))
        local tval="(${sorted_data[$before_middle]} + ${sorted_data[$after_middle]})/2"
        local val=$(echo "$tval" | bc -s) # bc -l
    fi
    # remove trailing zeros
    #echo $val | sed -r 's/\.([0-9]*[1-9])0*$/\.\1/; s/\.0*$//;'
    echo $val # ${val%\.*} or `function floatToDigit() {printf '%.0f' $1}`
}

function alert() {
    printf "\7"
    sleep 0.2
    printf "\7"
}

function convertToChartVlaue() {
    echo $(($1 / 3)) # to fit the chart with 33 character hight window
}

function chart() {
    local CHARTLINE=$1 # get the highest value
    shift
    local YELLOWVALUE=$1
    shift
    local REDVALUE=$1
    shift
    local VALUES=($@)                    # all values in an array
    while [ $CHARTLINE -gt 0 ]; do # start the first line
        ((CHARTLINE--))
        local REDUCTION=$(($CHARTLINE)) # subtract this from the VALUE
        for VALUE in ${VALUES[@]}; do
            # CHARTVALUE=$(convertToChartVlaue $VALUE)
            local CHARTVALUE=$(($VALUE - 20))
            local CHUNCK=$(($CHARTVALUE - $REDUCTION))
            if [ $CHUNCK -le 0 ]; then # check new VALUE
                echo -en "${gray}    "
            elif [ $VALUE -lt $REDVALUE ]; then
                echo -en "${red} ▓▓ ${gray}"
            elif [ $VALUE -lt $YELLOWVALUE ]; then
                echo -en "${yellow} ▓▓ ${gray}"
            else
                echo -en "${green} ▓▓ ${gray}"
            fi
        done
        echo
    done
    echo
}

function setTitle() {
    printf '\e]2;%s\a' "Detector | $1 | mute: $2"
}

function headtext() {
    local signalQuality=$1
    local minvalue=$2
    local alertValue=$3
    local alertPoint=$4
    local mute=$5
    local detected=''
    if [[ $signalQuality -lt $(($minvalue)) ]]; then
        printf "${gray}Quality: ${red}$signalQuality${gray}/70"
        setTitle "detected!" $mute
    elif [[ $signalQuality -lt $alertValue ]]; then
        printf "${gray}Quality: ${yellowb}$signalQuality${gray}/70"
        setTitle "detected!" $mute
    else
        printf "${gray}Quality: $signalQuality/70"
        setTitle "none" $mute
    fi
    printf "  | ${yellowb} $alertValue${gray} (-$alertPoint)"
    printf " | ${redb}$minvalue${gray} | mute: $mute\n"
}

function clearInput() (while read -r -t 0; do read -r -t 3; done)

function detector() {
    # tput smcup
    local chartMaxValue=33
    local minvalue=20
    local alertpoint=5
    local maxarray=15
    local medianlenght=$(($maxarray - 5))
    local alertpointmax=48
    local mute=0
    local showGraph=1
    local values=()
    while true; do
        # echo
        local signalQuality=$(awk 'END {print ($3+0)}' /proc/net/wireless)
        local medianValue=$signalQuality
        local alertValue=$(($medianValue - $alertpoint))
        if [[ ${#values[@]} -gt $medianlenght ]]; then
            medianValue=$(median "${values[@]: -$medianlenght}")
            if [[ $medianValue -gt $alertpointmax ]]; then
                alertpoint=5
            else
                alertpoint=3
            fi
            alertValue=$(($medianValue - $alertpoint))
        fi
        # signalGraph=$(($signalQuality - 20))
        # echo
        # tput clear
        local outputHead=$(headtext $signalQuality $minvalue $alertValue $alertpoint $mute)
        if [[ $signalQuality -lt $(($minvalue)) ]]; then
            [[ $mute -eq 0 ]] && alert
        elif [[ $signalQuality -lt $alertValue ]]; then
            [[ $mute -eq 0 ]] && printf "\7"
        fi
        values+=($signalQuality)
        if [[ ${#values[@]} -gt $maxarray ]]; then
            values=("${values[@]:1}")
        fi
        if [[ $showGraph -eq 1 ]]; then
            outputChart=$(chart $chartMaxValue $alertValue $minvalue ${values[@]})
            outputTail=$(printf ' %-3s' "${values[@]}")
        fi
        # clearInput
        read -r -t .1 -sn 1 input
        if [[ $input == "m" ]] || [[ $input == "M" ]]; then
            ((mute ^= 1))
            clearInput
        elif [[ $input == "g" ]] || [[ $input == "G" ]]; then
            ((showGraph ^= 1))
            clearInput
            echo
        elif [[ $input == "q" ]] || [[ $input == "Q" ]]; then
            echo
            break
        else
            clearInput
        fi
        # read -d '' -t 0.6 -n 10000

        # tput clear
        [[ $showGraph -eq 1 ]] && printf "\n\n"
        echo "$outputHead"
        if [[ $showGraph -eq 1 ]]; then
            echo
            echo "$outputChart"
            echo
            echo -n "$outputTail"
        fi
        sleep 1
    done
    # tput rmcup
}

detector

# values=(103 22 33 44 50 65 76 15 )
# echo $(median "${values[@]}")
