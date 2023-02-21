rm -rf /system/bin/tprop.log
for FILE in tm*
do
	cp -f $FILE /system/bin;chmod 755 /system/bin/$FILE
	echo "$FILE" >> /system/bin/tprop.log
done

echo "Done"
