#!/bin/bash

for i in $(seq -f "%05g" 1 400)
do
  stuff=$(openssl rand -base64 5)
  ticketNo=RCB-02062018-$stuff$i
  echo $ticketNo
  cat << EOF | qrencode -o ticket$i.png
BEGIN:VCARD
VERSION:3.0
N:Bunnik Fair;ShelterBox-Action-2018;;;
ORG:Rotary International
TITLE:TICKET $ticketNo
EMAIL:rcbunnik@gmail.com
NOTE: Hartelijk Bedankt Bunnik
URL:https://www.shelterbox.org
URL:https://www.rotary.nl/bunnik
URL:http://bunnikszomerfeest.nl
END:VCARD
EOF

 barcode -umm -p10x30 -b "$ticketNo" -o barcode$i.ps
 convert barcode$i.ps barcode$i.png
 rm barcode$i.ps
 sed -e "s/ticket00001/ticket$i/g" -e "s/barcode00001/barcode$i/g" templateticket.fodt > ticket$i.fodt
done
