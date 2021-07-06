#!/usr/bin/env bash

# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme

# Place the folder that listed on github: Folder -> Files to download
folder=("actions" "apps" "devices" "emblems" "emotes" "mimetypes" "places" "status")
# URL to folder
url_folder="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/tree/master/Papirus/48x48/"
# URL to download each files inside folder
url_svg="https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/Papirus/48x48/"
# Target files storage location
#target="~/.local/share/icons/Papirus-Custom"
target="/home/qwerty/Downloads/Github/downPapirusRaw/Papirus-Custom"
# Reset target if want to repeat this script
[[ -d $target ]] && rm -rf $target
mkdir $target

bar() {
    # The progress bar with arrow ( 8 bit )
    # In future will updated with unicode ( 16 bit )
    # Here: https://en.wikipedia.org/wiki/Block_Elements#Character_table

    # Number of Array length ( al )
    local al=$1
    # Terminal width
    local tw=$(tput cols)
    # Array items name, length & iteration
    local items_name=$2
    local items_length=$3
    local iteration=$4
    # Pad width
    local pw=$(($tw-$items_length-1-1-6))
    # Total arrow length for pad ( numArrow )
    local numArrow=$(($pw/$(($al+1))*$iteration))
    local pad=$(for((x=1; x<=$numArrow; x++)); do echo -n ">"; done)
    # Procentase number
    local prosnum=$(($iteration*10))
    if [[ $iteration -eq $al ]]; then
        printf "%-${items_length}s %-${pw}s %6s\r" $items_name $pad "[$numArrow%]"
        sleep 1
        pad=$(for((x=1; x<=$pw; x++)); do echo -n ">"; done)
        prosnum="100"
        printf "%-${items_length}s %-${pw}s %6s\n" "Finishing" $pad "[$prosnum%]"
    else
        printf "%-${items_length}s %-${pw}s %6s\r" $items_name $pad "[$numArrow%]"
    fi
    sleep 1
}

sloa() {
    # Sort length of array ( sloa )
    # Length of array ( loarr )
    local loarr=$1
    # Most length of array's items ( mai )
    local mai=()
    # Array arr
    local arr=("$@")
    unset arr[0]
    for string in ${arr[@]}; do
        # Length of each item ( loei )
        loei=${#string}
        # Push
        mai+=($loei)
    done
    # Most length items ( mli )
    local mli=$(echo -n ${mai[@]} | xargs printf "%d\n" | sort -nur | head -n 1)
    echo $mli
}

main() {
    # Length of array ( loa )
    loa=${#folder[@]}
    # Sort result of most array items length ( mli )
    mli=$(sloa $loa "${folder[@]}")
    # Iteration for knowing "Where has the loop been?"
    i=1
    for string in ${folder[@]}; do
        bar $loa $string $mli $i
        curl -sSO "$url_folder$string" 
        while IFS= read -r line; do
            svg=$(echo $line | grep "js-navigation-open Link--primary" | cut -d "=" -f 4 | cut -d '"' -f 2)
            if [[ -n $svg ]]; then
                curl -sSO --create-dirs --output-dir "$target/$string" -X GET "$url_svg$string/$svg"
            fi
        done < $string
        ((i=i+1))
    done
}

main
