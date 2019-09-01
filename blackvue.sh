#!/bin/bash

pid_file="/tmp/blackvue.pid"
/opt/bin/find $pid_file -type f -mtime +2 -exec rm {} \;

if [ -f $pid_file ]; then
    echo "PID file exists."
    exit 0
fi

touch $pid_file

cd /share/MD0_DATA/Recordings/blackvue/
IPADDRESS="BLACKVUE_IP_ADDRESS_HERE"
re="([0-9]+_[0-9]+_[E,M])"
re2="([0-9]+_[0-9]+_[P,N])"

# Sort function
Sort()
  {
    for item in $@;
      do
        echo $item;
      done |
    sort
   }

FILENAMES=()

# These variables are for downloading before event recordings.
file_previous_1=""
file_previous_2=""

for file in `curl http://$IPADDRESS/blackvue_vod.cgi | sed 's/^n://' | sed 's/F.mp4//' | sed 's/R.mp4//' | sed 's/,s:1000000//' | sed $'s/\r//'`;
do
  # echo $file
  FILENAMES+=($file)
done

SORTEDFILENAMES=$(Sort ${FILENAMES[@]});

for file in "${SORTEDFILENAMES[@]}";
do
  echo -e "SORTED: "$file\n
  file_previous_2=$file_previous_1;
  file_previous_1=$file;
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  # echo $timestamp ": Checking: "$file >> /tmp/blackvue.log;

  if [[ $file =~ $re ]]; then
    echo $timestamp ": Downloading: "$file >> /tmp/blackvue.log;
    wget -c http://$IPADDRESS$file\F.mp4;
    wget -c http://$IPADDRESS$file\R.mp4;
    wget -nc http://$IPADDRESS$file\F.thm;
    wget -nc http://$IPADDRESS$file\R.thm;
    wget -nc http://$IPADDRESS$file.gps;
    wget -nc http://$IPADDRESS$file.3gf;

    if [[ $file_previous_2 =~ $re2 ]]; then
      echo $timestamp ": Downloading: "$file_previous_2 >> /tmp/blackvue.log;
      wget -c http://$IPADDRESS$file_previous_2\F.mp4;
      wget -c http://$IPADDRESS$file_previous_2\R.mp4;
      wget -nc http://$IPADDRESS$file_previous_2\F.thm;
      wget -nc http://$IPADDRESS$file_previous_2\R.thm;
      wget -nc http://$IPADDRESS$file_previous_2.gps;
      wget -nc http://$IPADDRESS$file_previous_2.3gf;
    fi

    if [[ $file_previous_1 =~ $re2 ]]; then
      echo $timestamp ": Downloading: "$file_previous_1 >> /tmp/blackvue.log;
      wget -c http://$IPADDRESS$file_previous_1\F.mp4;
      wget -c http://$IPADDRESS$file_previous_1\R.mp4;
      wget -nc http://$IPADDRESS$file_previous_1\F.thm;
      wget -nc http://$IPADDRESS$file_previous_1\R.thm;
      wget -nc http://$IPADDRESS$file_previous_1.gps;
      wget -nc http://$IPADDRESS$file_previous_1.3gf;
    fi
  fi
done

/bin/rm -f $pid_file
