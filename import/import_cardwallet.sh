#!/bin/bash
#
# A simple script for importing cards from the cardwallet
#

UBCARDS_WALLET=~/.local/share/ubcards/wallet.ini
#CARDWALLET_DATA="~/.local/share/cardwallet.applee/Local\\ Storage/leveldb/"

echo "Create backup of the wallet: "
cp ${UBCARDS_WALLET} ${UBCARDS_WALLET}~

echo "Geting data from the cardwallet: "

if [ ! -d ~/.local/share/cardwallet.applee/Local\ Storage/leveldb/ ]
then
  echo "~/.local/share/cardwallet.applee/Local Storage/leveldb/ does not exist!"
  exit 1
fi

for line in $( cat ~/.local/share/cardwallet.applee/Local\ Storage/leveldb/*.log | grep -a "\"cards\":\[" | sed "s/cards\":/\n/g" | tail -n 1 | tr -d "[" | tr -d "]" | sed "s/},{/\n/g" | tr -d "{" | tr -d "}" )
do
  name=$( echo "$line" | awk -F"," '{print $1}' | awk -F":" '{print $2}' | tr -d "\"" )
  value=$( echo "$line" | awk -F"," '{print $2}' | awk -F":" '{print $2}' | tr -d "\"" )
  typeIn=$( echo "$line" | awk -F"," '{print $3}' | awk -F":" '{print $2}' | tr -d "\"" )
  
  if [ "$value" = "" ]
  then
    continue
  fi
  
  if [ "$name" = "" ]
  then
    name="Unknown Card"
  fi
  
  case $typeIn in
    3|4)
    type="EAN-13"
    ;;
    5)
    type="I2/5"
    ;;
    6)
    type="CODE-39"
    ;;
    *)
    type="CODE-128"
    ;;
  esac
  
  echo "  - processing: $name, $value, $typeIn, $type"

  uuid=$( python3 <<< 'import uuid;print(uuid.uuid4())' )
  
  echo "" >> ${UBCARDS_WALLET}
  echo "[$uuid]"  >> ${UBCARDS_WALLET}
  echo "cathegory=generic" >> ${UBCARDS_WALLET}
  echo "name=$name" >> ${UBCARDS_WALLET}
  echo "text=$value" >> ${UBCARDS_WALLET}
  echo "timestamp=@DateTime(\0\0\0\x10\0\0\0\0\0\0%\x00\x00\x00\x00\00\0)" >> ${UBCARDS_WALLET}
  echo "type=$type" >> ${UBCARDS_WALLET}

  sed -i "/all=/ s/\$/ ,$uuid/" ${UBCARDS_WALLET}
  
done

echo "Done!"

exit 0
