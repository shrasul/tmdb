import subprocess
import csv
import json
import MySQLdb
#==============================================================
#Excecuting Api call .sh file which will generate josn results
#==============================================================
Api_start_time = datetime.datetime.now()
print("Api Call Initialted Start Date/Time: ",Api_start_time)
shellscript = subprocess.Popen(["/home/tmdbuser/tmdb_toprated.sh"],
stdin=subprocess.PIPE, stdout=subprocess.PIPE, 
stderr=subprocess.PIPE) stdout, 
stderr = shellscript.communicate("yes\n") # blocks until shellscript is done
returncode = shellscript.returncode
#==========================================
print("Api Call Ended at Date/Time: ",datetime.datetime.now())
print('It took: {}'.format(datetime.datetime.now()-Api_start_time),'to fetch files')

#=============================
#parsing json file to csv file
#=============================

parse_start_time = datetime.datetime.now()
print("Api Call Initialted Start Date/Time: ",parse_start_time)

result = []
with open('/home/tmdbuser/tmdb_toprated.json', encoding="latin-1") as f:
    content = json.loads(f.read())
    for element in content:
        result.append(','.join([str(y[1]) for y in element['results']]))

with open('/home/tmdbuser/tmdb_toprated.csv', 'w') as f:
    f.write('\n'.join(result))
#=====================================================================
print("Json Parsing Ended at Date/Time: ",datetime.datetime.now())
print('It took: {}'.format(datetime.datetime.now()-parse_start_time),'to parse the files')

#========================================================================================
# loading CSV to mysql table
#========================================================================================
print("Insert Statement Start Date/Time: ",parse_start_time)
db = MySQLdb.connect(host="localhost",  # localhost
                     user="admin",      # username
                     passwd="admin",  	# password
                     db="tmdb")         # name of the data base

cur = db.cursor()
csv_data = csv.reader(file('/home/tmdbuser/tmdb_toprated.csv'), delimiter=',')
count = 0
    next(csv_data, None)
    for row in csv_data:
        if count < 1:
            continue
        else:
            cur.execute ("INSERT INTO part_table_test (popularity,vote_count,video,poster_path,id,adult,backdrop_path,original_language,original_title,genre_ids,title,vote_average,overview,release_date) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,%s",row)
        count+=1
db.close()
#===============================================================================================
print("Data Insertion Ended at Date/Time: ",datetime.datetime.now())
print('It took: {}'.format(datetime.datetime.now()-parse_start_time),'to Insert data into table')