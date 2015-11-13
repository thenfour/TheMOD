#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null

read -p "Username: " FTPUSER
read -s -p "Password: " FTPPASS
echo


for f in www/*.*
do
	echo "$f"
	curl -T "$f" "ftp://$FTPUSER:$FTPPASS@ftp.tridentloop.com/www/themod.be/test/"
done

for f in www/font/*.*
do
	echo "$f"
	curl -T "$f" "ftp://$FTPUSER:$FTPPASS@ftp.tridentloop.com/www/themod.be/test/font/"
done

for f in www/min/*.*
do
	echo "$f"
	curl -T "$f" "ftp://$FTPUSER:$FTPPASS@ftp.tridentloop.com/www/themod.be/test/min/"
done

for f in www/img/*.*
do
	echo "$f"
	curl -T "$f" "ftp://$FTPUSER:$FTPPASS@ftp.tridentloop.com/www/themod.be/test/img/"
done

for f in www/style/*.*
do
	echo "$f"
	curl -T "$f" "ftp://$FTPUSER:$FTPPASS@ftp.tridentloop.com/www/themod.be/test/style/"
done



popd >/dev/null
