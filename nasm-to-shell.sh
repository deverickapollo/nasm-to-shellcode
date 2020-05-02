#!/bin/bash
#Requires objdump and nasm
helpDescription()
{
   echo ""
   echo "Usage: $0 -a arch -i input -o output"
   echo -e "\t-a Architecture intel or att - Default is intel"
   echo -e "\t-i Input .asm file path"
   echo -e "\t-o Output .txt file"

   exit 1 # Exit script after printing help
}

while getopts "a:i:o:" opt
do
   case "$opt" in
      a ) arch="$OPTARG";;
      i ) input="$OPTARG" ;;
      o ) output="$OPTARG" ;;
      ? ) helpDescription ;; # Print helpDescription
   esac
done

# Print helpDescription when missing
if [ -z "$input" ] || [ -z "$output" ];
then
   echo "Please verify input parameters";
   helpDescription
fi

if [ -z "$arch" ] || [ "$arch" != "att" ] ;
then
   echo "Architecture set to intel"
   arch="intel"
fi

# Begin script
nasm -f elf "${input}"
 
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

filename=$(echo "$input" | cut -f 1 -d '.')
filename="${filename}.o"

if [[ ${machine} == "Mac" ]]; then
   objdump -d -x86-asm-syntax="$arch" "${filename}"|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'
elif [[ ${machine} == "Linux" ]]; then
   objdump -d -M "$arch" "${filename}"|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'
else 
   #Blind attempt -- Guessing Linux
   objdump -d -M "$arch" "${filename}"|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'
fi