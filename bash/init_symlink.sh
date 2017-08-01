#!/bin/ksh

function create_link {
   source=$1
   source_absolute=$(echo "/$source/" | sed 's@^//*@/@')
   cible=$2
   cible_absolute=$(echo "/$cible/" | sed 's@^//*@/@')
   link=$3
   relative_link=$(echo "/$link" | sed 's@^//*@@')

   if [[ -h ${source_absolute}${relative_link} ]]
   then
      echo "Link ${source_absolute}${relative_link} already created"
   elif [[ -d ${source_absolute}${relative_link} ]]
   then
      echo "Repository ${source_absolute}${relative_link} already exists : impossible to create link!"
   else
      mkdir -p ${cible_absolute}${relative_link}
      ln -s ${cible_absolute}${relative_link} ${source_absolute}${relative_link}
      echo "Link ${source_absolute}${relative_link} created"
   fi
}

if [[ $# -ne 3 ]]
then
   echo "Usage : $0 <source> <cible> <chemin1>[,<chemin2>,...]"
   echo "Create /<source>/<chemin> to /<cible>/<chemin>"
   exit 12
fi

source=$1
cible=$2
les_chemins="$3"

for c in $(echo "$les_chemins" | sed 's@,@ @g')
    do
       create_link $source $cible $c
    done
