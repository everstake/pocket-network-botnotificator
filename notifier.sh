#!/bin/bash -x
poktcheck ()
{
NAME=`echo $IP |awk -F ";" '{print $1}' | sed 's/NODE=//g'`
IPN=`echo $IP | awk -F ";" '{print $2}'`
for (( ITERATION=1; ITERATION<=$ITERATIONS; ITERATION++ )); do
        GET=`curl --insecure --connect-timeout 6 --max-time 6  -s http://${IPN}/abci_info | grep 'last_block_height' | awk -F ":" '{print $2}' | sed 's/"//g' | sed 's/,//g'`
        if [ -z $GET ]; then
                sleep 20;
                continue
        else
                break
        fi
done
if [ -z $GET ]; then
        echo "node is down"
        curl -s -X POST https://api.telegram.org/bot$BOTNUMBER/sendMessage -d chat_id=$CHATID -d text="☠️ Node $NAME $IPN doesn't work. Please check http://$IPN/abci_info"
fi
}


PWD=$PWD
ITERATIONS=3
while true; do
        ITERATIONS=`cat ${PWD}/pocket.ini | grep -v "#" | grep "ITERATIONS" | awk -F "=" '{print $2}'`
        CHATID=`cat ${PWD}/pocket.ini | grep -v "#" | grep "CHATID" | awk -F "=" '{print $2}'`
        BOTNUMBER=`cat ${PWD}/pocket.ini | grep -v "#" | grep "BOTNUMBER" | awk -F "=" '{print $2}'`
        NODEIP=`cat ${PWD}/pocket.ini | grep -v "#" | grep "NODE"`
        for IP in $NODEIP
        do
                poktcheck $IP
        done
        sleep 120;
done

