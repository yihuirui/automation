#!/bin/sh
Path=/yi
[ -d "$Path" ] ||mkdir -p $Path
for n in `seq 10`
do
random=$(openssl rand -base64 40|sed 's#[^a-z]##g'|cut -c 2-11)
touch $Path/${random}_yi
