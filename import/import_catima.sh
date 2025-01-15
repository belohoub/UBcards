#!/bin/bash
#
# A simple script for importing cards from the Catima Android App
#
#
# Copyright (C) 2025 Jan Belohoubek, it@sfortelem.cz                      
#                                                                         
# This file is part of UBcards, the fork of tagger                        
#                                                                         
# This prject is free software: you can redistribute it and/or modify     
# it under the terms of the GNU General Public License as published by    
# the Free Software Foundation, either version 3 of the License, or       
# (at your option) any later version.                                     
#                                                                         
# This project is distributed in the hope that it will be useful,         
# but WITHOUT ANY WARRANTY; without even the implied warranty of          
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           
# GNU General Public License for more details.                            
#                                                                         
# You should have received a copy of the GNU General Public License       
# along with this program.  If not, see <http://www.gnu.org/licenses/>.   
#


UBCARDS_WALLET=~/.local/share/ubcards/wallet.ini
# The Test File
#UBCARDS_WALLET="$( dirname $0 )/catima.ini"

CATIMA_CSV="$( dirname $0 )/catima.csv"


echo "Create backup of the wallet: "
cp ${UBCARDS_WALLET} ${UBCARDS_WALLET}~

echo "Importing data from the catima.csv: "

if [ ! -e ${CATIMA_CSV} ]
then
  echo "${CATIMA_CSV} does not exist!"
  exit 1
fi

level="0"

while IFS= read -r line
do
  if [ "$level" = "0" ]
  then
    if [ "$line" = "_id" ]
    then
      categories=""
      level="1"
      continue
    fi
  elif [ "$level" = "1" ]
  then
    # Scaning Categories
    echo "$line" | grep "^_id" >> /dev/null
    if [ "$?" = "0" ]
    then
      cards=0
      level="2"
      continue
    fi
    
    categories="${categories};$line"
    
  elif [ "$level" = "2" ]
  then
    # Scaning Cards
    if [ "$line" = "cardId,groupId" ]
    then
      level="3"
      continue
    fi
    
    if [ "$line" = "" ]
    then
      continue
    fi
    
    id=$( echo "$line" | awk -F"," '{print $1}' )
    name=$( echo "$line" | awk -F"," '{print $2}' )
    value=$( echo "$line" | awk -F"," '{print $8}' )
    typeIn=$( echo "$line" | awk -F"," '{print $10}' )
    
    if [ "$typeIn" = "EAN_13" ]
    then
      type="EAN-13"
    elif [ "$typeIn" = "QR_CODE" ]
    then
      type="QR-Code"
    elif [ "$typeIn" = "CODE_39" ]
    then
      type="CODE-39"
    else
      type="CODE-128"
    fi
    
    echo "  - processing: $id, $name, $value, $typeIn, $type"
      
    uuid=$( python3 <<< 'import uuid;print(uuid.uuid4())' )
    
    echo "" >> ${UBCARDS_WALLET}
    echo "[$uuid]"  >> ${UBCARDS_WALLET}
    echo "category=[category_${id}]" >> ${UBCARDS_WALLET}
    echo "name=$name" >> ${UBCARDS_WALLET}
    echo "text=$value" >> ${UBCARDS_WALLET}
    echo "timestamp=@DateTime(\0\0\0\x10\0\0\0\0\0\0%\x00\x00\x00\x00\00\0)" >> ${UBCARDS_WALLET}
    echo "type=$type" >> ${UBCARDS_WALLET}
    
    sed -i "/all=/ s/\$/ ,$uuid/" ${UBCARDS_WALLET}
    
    cards=$(( $cards + 1 ))
    
  else
  
    # get card cateory - these are user-defined in Catima ... just try to convert few generic names
    id=$( echo "$line" | awk -F"," '{print $1}' )
    category=$( echo "$line" | awk -F"," '{print $2}' )
  
    if [ "$category" = "Fashion" ]
    then
      category="shopping"
    elif [ "$category" = "Food" ]
    then
      category="restaurant"
    elif [ "$category" = "Health" ]
    then
      category="health"
    else
      category="generic"
    fi
  
    echo "  - processing categories: $id, $category"
  
    sed -i "s/\[category_${id}\]/${category}/g" ${UBCARDS_WALLET}
  
  fi

done < ${CATIMA_CSV}

# replace unknown categories
sed -i "s/\[category_[[:digit:]]*\]/generic/g" ${UBCARDS_WALLET}

echo "Done!"

exit 0
