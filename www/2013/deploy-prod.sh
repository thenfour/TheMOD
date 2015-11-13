#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null

read -p "Username: " FTPUSER
read -s -p "Password: " FTPPASS
echo


for f in www/*.*
do
	echo "$f"
	curl -T "$f" "ftp://$FTPUSER:$FTPPASS@ftp.tridentloop.com/www/themod.be/"
done

for f in www/font/*.*
do
	echo "$f"
	curl -T "$f" "ftp://$FTPUSER:$FTPPASS@ftp.tridentloop.com/www/themod.be/font/"
done

for f in www/min/*.*
do
	echo "$f"
	curl -T "$f" "ftp://$FTPUSER:$FTPPASS@ftp.tridentloop.com/www/themod.be/min/"
done

for f in www/img/*.*
do
	echo "$f"
	curl -T "$f" "ftp://$FTPUSER:$FTPPASS@ftp.tridentloop.com/www/themod.be/img/"
done

for f in www/style/*.*
do
	echo "$f"
	curl -T "$f" "ftp://$FTPUSER:$FTPPASS@ftp.tridentloop.com/www/themod.be/style/"
done



popd >/dev/null
