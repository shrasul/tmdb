#!/bin/sh


baseenvdepth=`dirname $(readlink -f "$0") | awk 'BEGIN{FS="/"}; {print(NF)}'`
logdir=`dirname $(readlink -f "$0") | awk 'BEGIN{FS="/"}; {for (i = 2; i < NF; ++i) {printf("/%s",$i)}}; END{print("/logs")}'`
workingdir=`dirname $(readlink -f "$0") | awk 'BEGIN{FS="/"}; {for (i = 2; i < NF; ++i) {printf("/%s",$i)}}; END{print("/working/SO")}'`
Timestamp=`date "+%d%m%y_%H%M%S"`
run_log=$logdir/Get_tmdb_toprated.log

if [ $# -ne 1 ]
then
        echo "Script not called with 2 parameters. Start and end timestamp" >> $run_log
#        exit 10
fi

validate()
{
        if [ $1 -ne 0 ]
        then
                echo `date "+%F %T"` "[ERROR] Exit code $1 from $3" >> $2
                exit $1
        fi
}

//start_date=`echo $1 | awk '{print($0"%2b04:00")}'`

Temp_workingdir=$workingdir/$1

if [ -d $Temp_workingdir ]
then
	rm $Temp_workingdir/*
else
	mkdir $Temp_workingdir
	validate $? $run_log "Making working directory"
fi

Record_Start=1
Record_Range=200
Record_Max=200

curl -kD $Temp_workingdir/header.dat -o /dev/null -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxOTAwZjU0YWU5MTI1OTQ3OTU0MzZmZmI1NmJiN2IxMCIsInN1YiI6IjVkZDE0N2U5NTdkMzc4MDAxM2Q5MmQ2ZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fHFy4_ibTCXMX3rbY9LZm7a_GT1nyHcobYABBkxbUkc" https://api.themoviedb.org/3/movie/top_rated?language=en-US
validate $? $run_log "Fetching Header details to iterate paginated records"

Record_Count=`cat -v $Temp_workingdir/header.dat | sed 's/\^M//g' | grep Content-Range | awk 'BEGIN{FS="/"};{print($2)}'`
echo $Record_Count
validate $? $run_log "Fetching record count from response header"

while [ $Record_Start -le $Record_Count ]
do
	curl -k -o $Temp_workingdir/$Record_Max.json -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxOTAwZjU0YWU5MTI1OTQ3OTU0MzZmZmI1NmJiN2IxMCIsInN1YiI6IjVkZDE0N2U5NTdkMzc4MDAxM2Q5MmQ2ZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.fHFy4_ibTCXMX3rbY9LZm7a_GT1nyHcobYABBkxbUkc" -H "Range:items=$Record_Start-$Record_Max" https://api.themoviedb.org/3/movie/top_rated?language=en-US
	Record_Start=$((Record_Start + Record_Range))
	Record_Max=$((Record_Max + Record_Range))
done
