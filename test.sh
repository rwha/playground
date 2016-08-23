#!/bin/bash
RED='\033[0;31m'
ORG='\033[0;33m'
GRN='\033[1;32m'
LBL='\033[1;34m'
CYN='\033[1;36m'
PRP='\033[1;35m'
CLR='\033[0m'

finish(){
	echo -e "${CLR}"
}

trap finish EXIT

echo; 
echo -e "
This script performs various actions by default.

First it will create a ${LBL}bin${CLR} directory in your home folder (if one doesn't exist) 
and add it to your \$PATH variable (via ${CYN}.bash_profile${CLR} or ${CYN}.bashrc${CLR}).

It will then create a ${LBL}.templates${CLR} directory in your home folder with various
template files for use with ${GRN}new${CLR}. 

The ${GRN}new${CLR} command is added to ${LBL}${HOME}/bin${CLR} and is used to create a
new file based on a template within the above mentioned ${LBL}.templates${CLR} directory. 
It will then exit into your default editor. If no default editor is defined within your 
profile it will exit into vim or nano, whichever is found first (checked in that order).

You have five seconds to exit this script with ^c (CTRL + c)..."
echo

for i in {5..1}; do
  echo -en "${RED}${i}${CLR} ";
  sleep 1
done

echo

[ -d ${HOME}/bin ] && echo -e "\t ${ORG}${HOME}/bin exists${CLR}" || { mkdir ${HOME}/bin; echo -e "\t ${LBL}${HOME}/bin created${CLR}"; }

[ -d ${HOME}/.templates ] && echo -e "\t ${ORG}${HOME}/.templates exists${CLR}" || { mkdir ${HOME}/.templates; echo -e "\t ${LBL}${HOME}/.templates created${CLR}"; }

[ ! -f ${HOME}/bin/new ] && {
cat << EONF > ${HOME}/bin/new
#!/bin/bash

[ -x \$(which vim) ] && EDITOR=\${EDITOR:-\$(which vim)} || EDITOR=\${EDITOR:-\$(which nano)}

usage() {
echo -e "
USAGE: new [type] [(path/)filename]

Create a new file [filename] from an existing template.
 [type] must match an existing template in 
 your \${HOME}/.templates directory.
 Currently available templates:
"

 for t in \${HOME}/.templates/*; do
   echo "    \$(basename \${t})"
 done

echo -e "
(path/) is relative to your current directory and any
 directories in this path must already exist.
"
exit
 
}

[ \$# -lt 2 ] && usage

[ ! -f "\${HOME}/.templates/\$1" ] && { echo "\$1 template does not exist"; exit 1; }

cp "\${HOME}/.templates/\$1" "\${2}"

exec \$EDITOR \$2
EONF

chmod +x "${HOME}/bin/new"
echo -e "\t ${GRN}${HOME}/bin/new created${CLR}"
}


[ ! -f ${HOME}/.templates/shell ] && {
cat << EOTSF > ${HOME}/.templates/shell
#!/bin/bash


exit
EOTSF

chmod +x ${HOME}/.templates/shell
echo -e "\t template ${PRP}shell${CLR} added"
}

[ ! -f ${HOME}/.templates/python ] && {
cat << EOTPF > ${HOME}/.templates/python
#!/usr/bin/env python

import os
import sys

def main():
    

##
if __name__ == '__main__':
  main()

EOTPF

chmod +x ${HOME}/.templates/python
echo -e "\t template ${PRP}pythone${CLR} added"
}

[ -f ${HOME}/.bash_profile ] && PROF=${HOME}/.bash_profile

[ -f ${HOME}/.bashrc ] && PROF=${PROF:-${HOME}/.bashrc}

echo "$PATH" | grep -q "${HOME}/bin" || {
	echo 'export PATH=${PATH}:${HOME}/bin' >> ${PROF};
}

echo -e "\t added ${HOME}/bin to user \$PATH"

echo

echo -e "Completed. Test now by running ${GRN}new${CLR} ${PRP}shell${CLR} ${LBL}bin/test${CLR}"

exit
