#!/bin/bash
#
# A simple script for exporting cards for the Catima Android App
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
#UBCARDS_WALLET="$( dirname $0 )/wallet.ini"

CATIMA_CSV="$( dirname $0 )/catima.csv"
CATIMA_ZIP="$( dirname $0 )/catima.zip"


echo "Importing data from the wallet.ini: "

if [ ! -e ${UBCARDS_WALLET} ]
then
  echo "${UBCARDS_WALLET} does not exist!"
  exit 1
fi

echo "2" > ${CATIMA_CSV}
echo "" >> ${CATIMA_CSV}
echo "_id" >> ${CATIMA_CSV}
cat ${UBCARDS_WALLET} | grep "^category" | awk -F"=" '{print $2}' | sort | uniq >> ${CATIMA_CSV}
echo "" >> ${CATIMA_CSV}
echo "_id,store,note,validfrom,expiry,balance,balancetype,cardid,barcodeid,barcodetype,headercolor,starstatus,lastused,archive" >> ${CATIMA_CSV}

for id in $( seq 1 1 $( cat ${UBCARDS_WALLET} | grep "^text=" | wc -l ) )
do
  echo "Procesing Card ID: $id"
  
  name=$( cat ${UBCARDS_WALLET} | grep "^name=" | awk -F"=" '{print $2}'| head -n $id | tail -n 1 )
  cardid=$( cat ${UBCARDS_WALLET} | grep "^text=" | awk -F"=" '{print $2}'| head -n $id | tail -n 1 )
  type=$( cat ${UBCARDS_WALLET} | grep "^type=" | awk -F"=" '{print $2}'| head -n $id | tail -n 1 )
  category=$( cat ${UBCARDS_WALLET} | grep "category=" | awk -F"=" '{print $2}' | head -n $id | tail -n 1 )
  
  if [ "$type" = "EAN-13" ]
  then
    barcodetype="EAN_13"
  elif [ "$type" = "QR-Code" ]
  then
    barcodetype="QR_CODE"
  elif [ "$type" = "CODE-39" ] || [ "$type" = "libre-CODE-39" ] 
  then
    barcodetype="CODE_39"
  elif [ "$type" = "EAN-8" ] 
  then
    barcodetype="EAN_8"
  elif [ "$type" = "DataBar" ] 
  then
    barcodetype="DATA_MATRIX"
  elif [ "$type" = "I2/5" ] 
  then
    barcodetype="CODABAR"
  elif [ "$type" = "PICTURE" ] 
  then
    barcodetype="QR_CODE"
  else
    barcodetype="CODE_128"
  fi
  
  # Color
  if [ "$category" = "shopping" ]
  then
    color="$( echo "ibase=16; 7fd6ca" | bc -l )"
  elif [ "$category" = "car" ]
  then
    color="$( echo "ibase=16; f97fbf" | bc -l )"
  elif [ "$category" = "health" ]
  then
    color="$( echo "ibase=16; babfe7" | bc -l )"
  elif [ "$category" = "sport" ]
  then
    color="$( echo "ibase=16; f7d47f" | bc -l )"
  elif [ "$category" = "travel" ]
  then
    color="$( echo "ibase=16; 8184bf" | bc -l )"
  elif [ "$category" = "restaurant" ]
  then
    color="$( echo "ibase=16; cacabf" | bc -l )"
  elif [ "$category" = "garden" ]
  then
    color="$( echo "ibase=16; 80b381" | bc -l )"
  elif [ "$category" = "education" ]
  then
    color="$( echo "ibase=16; 7f7f7f" | bc -l )"
  else
    color="$( echo "ibase=16; 7fd6ca0" | bc -l )"
  fi
  
  echo "$id,$name,,,,,,$cardid,,$barcodetype,$color,,," >> ${CATIMA_CSV}

done

echo "" >> ${CATIMA_CSV}
echo "cardId,groupId" >> ${CATIMA_CSV}

for id in $( seq 1 1 $( cat ${UBCARDS_WALLET} | grep "^category=" | wc -l ) )
do
  echo "Procesing Card IDs' category: $id"
  
  category=$( cat ${UBCARDS_WALLET} | grep "category=" | awk -F"=" '{print $2}' | head -n $id | tail -n 1 )
  
  if [ "$category" = "generic" ] || [ "$category" = "" ]
  then
    continue
  fi
  
  echo "$id,$category" >> ${CATIMA_CSV}

done


# TODO handle PICTURES

echo "Creating ${CATIMA_ZIP} file:"
rm ${CATIMA_ZIP}
zip ${CATIMA_ZIP} ${CATIMA_CSV}

echo "Done!"

exit 0
