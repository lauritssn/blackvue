#!/bin/bash

pid_file="/tmp/blackvue.pid";
/opt/bin/find $pid_file -type f -mtime +2 -exec rm {} \;

if [ -f $pid_file ]; then
    echo "PID file exists."
    exit 0
fi

touch $pid_file

cd /share/MD0_DATA/Recordings/blackvue/
IPADDRESS="BLACKVUE_IPADDRESS_HERE"
re="([0-9]+_[0-9]+_[E,M])"
re2="([0-9]+_[0-9]+_[P,N,M,E])"

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

for file in `curl -s http://$IPADDRESS/blackvue_vod.cgi | sed 's/^n://' | sed 's/F.mp4//' | sed 's/R.mp4//' | sed 's/,s:1000000//' | sed $'s/\r//'`;
do
  # echo $file
  FILENAMES+=($file)
done

SORTEDFILENAMES=$(Sort ${FILENAMES[@]});

for dlfile in ${SORTEDFILENAMES[@]};
do
  file_previous_2=$file_previous_1;
  file_previous_1=$dlfile;
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  # echo $dlfile
  # echo $file_previous1
  # echo $file_previous2
  echo $timestamp ": Checking: "$dlfile >> /tmp/blackvue.log;

  if [[ $dlfile =~ $re ]]; then
    echo $timestamp ": Downloading: "$dlfile >> /tmp/blackvue.log;
    wget -c http://$IPADDRESS$dlfile\F.mp4;
    wget -c http://$IPADDRESS$dlfile\R.mp4;
    wget -nc http://$IPADDRESS$dlfile\F.thm;
    wget -nc http://$IPADDRESS$dlfile\R.thm;
    wget -nc http://$IPADDRESS$dlfile.gps;
    wget -nc http://$IPADDRESS$dlfile.3gf;

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
