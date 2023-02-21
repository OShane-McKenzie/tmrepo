log=/system/bin/tprop.log

while IFS= read -r line
do
	rm -rf /system/bin/$line
done < "$log"

echo "Done"
