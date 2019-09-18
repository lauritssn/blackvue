#!/bin/bash

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo $timestamp ": Start script." >> /tmp/blackvue.log

pid_file="/tmp/blackvue.pid"
/opt/bin/find $pid_file -type f -mtime +2 -exec rm {} \;

if [ -f $pid_file ]; then
    echo $timestamp ": PID file exists." >> /tmp/blackvue.log
    exit 0
fi

touch $pid_file

cd /share/MD0_DATA/Recordings/blackvue/
IPADDRESS="BLACKVUE_IPADRESS_HERE"
re="([0-9]+_[0-9]+_[E,M])"
re2="([0-9]+_[0-9]+_[P,N,M,E])"

# Sort function
Sort()
  {
    for item in $@;
      do
        echo $item
      done |
    sort
   }

FILENAMES=()

# These variables are for downloading before event recordings.
file_previous_1=""
file_previous_2=""

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo $timestamp ": Running Curl." >> /tmp/blackvue.log

for file in `curl --retry 5 --retry-delay 30 -s http://$IPADDRESS/blackvue_vod.cgi | sed 's/^n://' | sed 's/F.mp4//' | sed 's/R.mp4//' | sed 's/,s:1000000//' | sed $'s/\r//'`;
do
  echo $timestamp ": Filename: "$file >> /tmp/blackvue.log
  FILENAMES+=($file)
done

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo $timestamp ": Sorting filenames." >> /tmp/blackvue.log

SORTEDFILENAMES=$(Sort ${FILENAMES[@]})

# echo $timestamp ": Sorted filenames: " SORTEDFILENAMES[@] >> /tmp/blackvue.log

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo $timestamp ": Looping files for download." >> /tmp/blackvue.log

for dlfile in ${SORTEDFILENAMES[@]};
do
  file_previous_2=$file_previous_1
  file_previous_1=$dlfile
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo $timestamp ": Checking: "$dlfile >> /tmp/blackvue.log
  # echo $file_previous1
  # echo $file_previous2
  echo $timestamp ": Checking: "$dlfile >> /tmp/blackvue.log

  if [[ $dlfile =~ $re ]]; then
    echo $timestamp ": Downloading: "$dlfile >> /tmp/blackvue.log
    wget -c http://$IPADDRESS$dlfile\F.mp4
    wget -c http://$IPADDRESS$dlfile\R.mp4
    wget -nc http://$IPADDRESS$dlfile\F.thm
    wget -nc http://$IPADDRESS$dlfile\R.thm
    wget -nc http://$IPADDRESS$dlfile.gps
    wget -nc http://$IPADDRESS$dlfile.3gf

    if [[ $file_previous_2 =~ $re2 ]]; then
      echo $timestamp ": Downloading: "$file_previous_2 >> /tmp/blackvue.log
      wget -c http://$IPADDRESS$file_previous_2\F.mp4
      wget -c http://$IPADDRESS$file_previous_2\R.mp4
      wget -nc http://$IPADDRESS$file_previous_2\F.thm
      wget -nc http://$IPADDRESS$file_previous_2\R.thm
      wget -nc http://$IPADDRESS$file_previous_2.gps
      wget -nc http://$IPADDRESS$file_previous_2.3gf
    fi

    if [[ $file_previous_1 =~ $re2 ]]; then
      echo $timestamp ": Downloading: "$file_previous_1 >> /tmp/blackvue.log
      wget -c http://$IPADDRESS$file_previous_1\F.mp4
      wget -c http://$IPADDRESS$file_previous_1\R.mp4
      wget -nc http://$IPADDRESS$file_previous_1\F.thm
      wget -nc http://$IPADDRESS$file_previous_1\R.thm
      wget -nc http://$IPADDRESS$file_previous_1.gps
      wget -nc http://$IPADDRESS$file_previous_1.3gf
    fi
  fi
done

/bin/rm -f $pid_file

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
echo $timestamp ": End script." >> /tmp/blackvue.log
