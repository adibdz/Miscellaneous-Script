#!/usr/bin/env bash

## Description: This is bash script for automation git push with "main" origin.
## Usage: 
## 1. Download this to any_name.sh
## 2. Give 755 permission
## 3. Place to your */bin/

de() {
  echo "[+] $1"
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

git config --global user.email "YOUR GITHUB EMAIL"
git config --global user.name "YOUR GITHUB USERNAME"

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
  git push -q -u origin main
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
