#!/bin/bash
###############################################################################
# This script downloads 2009 Data Expo airline on-time performance data files,
# uncompresses them, and concatenates them into one file with the header intact.
# Then removes extra fields not used in downstream analysis and cleans the data
# for unexpected escape characters.
# 
# Adapted from:
# http://www.bytemining.com/2010/08/taking-r-to-the-limit-part-ii-large-datasets-in-r/
###############################################################################
# This script makes 3 assumptions:
# 1) Bash is located at /bin/bash, if not, change the shebang.
# 2) wget is installed on your system.
# 3) THERE ARE NO OTHER FILES NAMED 19...csv or 20...csv IN THE DIRECTORY!
###############################################################################

# create a folder named `data` to hold the data and enter it
mkdir data
cd data

# download the flight data from the stat-computing.org website
for ((i=1987; i <= 2008 ; i++))
do
  	wget http://stat-computing.org/dataexpo/2009/$i.csv.bz2
done

# unzip downloaded flight data
for ((i=1987; i <= 2008 ; i++))
do
  	bunzip2 $i.csv.bz2
done

# Combine individual year files into one large file called `airline.csv`
head -1 1987.csv >> header.tmp
tail --lines=+2 -q *.csv >airline.tmp
cat header.tmp airline.tmp >airline.csv
rm airline.tmp

# create a subsample file from airline_subsample.csv
cat header.tmp > airline_subsample.csv
for file in $(ls ????.csv)
do
  	tail --lines=+2 -q $file | shuf -n 100000 >> airline_subsample.csv
done

# keep only the fields we need
cat airline_subsample.csv | cut -d "," -f 1,2,11,15,17 | sed s/\'// > airline.tmp
cat airline.tmp > airline_subsample.csv
rm airline.tmp

# create a small testing file called `airline_trunc.csv`
head -1 airline_subsample.csv > airline_trunc.csv
tail --lines=+2 -q airline_subsample.csv | shuf -n 1000 >> airline_trunc.csv

# clean up unneeded files
for ((i=1987; i <= 2008; i++))
do
  	rm $i.csv
done
rm header.tmp airline.tmp


