#!/usr/bin/env bash

## Description: This is bash script for automation git push with "main" origin.
## Usage: 
## 1. Download this to any_name.sh
## 2. Give 755 permission
## 3. Place to your */bin/
## 4. any_name.sh [m|M|master|Master]

BRNCH="main"
[[ $1 == "master" || $1 == "Master" || $1 == "m" || $1 == "M" ]] && BRNCH="master"

de() {
  local Lc="\e[96m\e[1m"
  local En="\e[21m\e[0m"
  echo -e "$Lc[+] $1$En"
}

if [[ -z $(git --version) ]]; then 
  de "Install Git first" 
  exit 1
fi

if [[ ! -d ".git" ]]; then 
  de "You are not in git repository ( or any of the parent directories): .git" 
  de "Exit"
  exit 1
fi

if [[ ! $(ping -q -c 1 -W 1 8.8.8.8 | grep rtt | wc -l) -eq 1 ]]; then
  de "Your internet is down"
  de "Exit"
  exit 1
fi

extp2g() {
  de "Git already clean :)"
  exit 1
}

arrAwk() {
  local outawk=$(echo $* | awk '{
    if ( $1 == "M") { $1 = "Modified"; }
    else if ( $1 == "??") { $1 = "Untracked"; }
    else if ( $1 == "A") { $1 = "New File"; }
    else if ( $1 == "D") { $1 = "Deleted"; }
    else if ( $1 == "R") { $1 = "Renamed"; }
    else if ( $1 == "C") { $1 = "Copied"; }
    else { $1 = "See you later"; }
    print $0
  }' | sed 's/"//g' | sort -u )
  echo $outawk
}

gitStatus() {
  totalArray=1
  while IFS= read -r line; do
    arr=("${arr[@]}" "$line")
    line=$(arrAwk $line)
    de "$totalArray $line"
    ((totalArray=totalArray+1))
  done < <(git status -s --porcelain)
  local tmp=$((totalArray-1))
  if [[ $tmp -le 0 ]]; then
    extp2g
  fi
}

defaultCommit() {
  read -r -p "Your message for commit: " message
  git commit -q -m "$message"
  # git commit -q -m "${message}"
  git push -q -u origin $BRNCH
  de "All done :)"
}

commitBy() {
  local l=$(($1-1))
  local r=$(echo "${arr[$l]}" | sed 's/"//g' | cut -c4- | sed 's/ /\\ /g')
  git add "$r"
  defaultCommit
}

commitAll() {
  git add .
  defaultCommit
}

welcome() {
  de "Default Branch is Main"
  de "You can can use Master Branch with ./puss2git master"
  echo
  echo
}

main() {
  welcome
  gitStatus
  read -r -p "Which number do you want to commit? ([ENTER] to commit all files): " number
  ((totalArray=totalArray-1))
  if [[ $number == $'\x000A' ]]; then
    commitAll
  elif [[ $number -gt 0 && $number -le $totalArray ]]; then
    commitBy $number
  else
    echo "Please select the correct number or press [ENTER]"
  fi
  exit 0
}

main
