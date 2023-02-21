loc="$1"
fls="$2"
dest="$3"
bkloc="$4"
logs="$5"

function print-help ()
{
	echo ""
	echo "Requires five (5) arguments"
	echo ""
	echo "usage: cpbk [/path/to/files/directory] [files-(eg: file.txt or *.txt etc)] [destination directory] [Back up location] -l/-n" 
	echo ""
}


if [ -z "$loc" ]
  then
      print-help
      exit
  fi

if [ -z "$fls" ]
  then
      print-help
      exit
  fi

if [ -z "$dest" ]
  then
      print-help
      exit
  fi

if [ -z "$bkloc" ]
  then
      print-help
      exit
  fi

if [ -z "$logs" ]
  then
      print-help
      exit
  fi


if [ "$loc" == "--help" ]
then
    print-help
    exit
fi

if [ "$logs" != "-n" ] && [ "$logs" != "-l" ]
then
    print-help
    exit
fi

if [ ! -d "$bkloc" ]
then
	mkdir -p $bkloc
fi

c=0
cd "$loc"
for FILE in $fls
do
	if [ -f "$dest/$FILE" ]
	then
		mv $dest/$FILE $bkloc
		mv $loc/$FILE $dest
		echo "Matched file: $dest/$FILE" >> $bkloc/cpbk.log
		let "c+=1"
	else
		mv $loc/$FILE $dest
		echo "Unique file: $dest/$FILE" >> $bkloc/cpbk.log
		let "c+=1"
	fi
done
function clog ()
{
  echo "$c file(s) were backed up and replaced on $(date "+%d/%m/%y %H:%M:%S")" >> $bkloc/cpbk.log
  echo "" >> $bkloc/cpbk.log
  echo "" >> $bkloc/cpbk.log
  echo "$c file(s) were backed up and replaced"
}

if [ "$logs" == "-l" ];then clog;fi
if [ "$logs" == "-n" ];then rm -rf $bkloc/cpbk.log;fi
#made by TeamMajor t.me/litecodzofficial
