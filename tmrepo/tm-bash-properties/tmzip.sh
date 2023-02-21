mount -o rw,remount /
mount -o rw,remount /system 2>/dev/null
#mount -o rw,remount /data 2>/dev/null

parzip="$1"
parzip2="$2"
parzip3="$3"
parzip4="$4"

function print-help ()
{
  echo "usage: tmzip [-d or -c] [-N or -F or -D ] path/to/files-or-directories Destination"
  echo ""
  echo "-d to decompress-(requires -N), -c to compress-(requires -F OR -D, for file or directory respectively)"
  echo ""
}

if [ "$parzip" == "--help" ]
then
    print_help
    exit
fi

if [ -z "$parzip" ]
  then
      print-help
      exit
  fi

if [ -z "$parzip2" ]
  then
      print-help
      exit
  fi

if [ -z "$parzip3" ]
  then
      print-help
      exit
  fi

if [ -z "$parzip4" ]
  then
      print-help
      exit
  fi


case $parzip in

  -d)
    typ=1
    ;;

  -c)
    typ=2
    ;;

  *)
    print-help
    exit
    ;;
esac

if [ "$parzip" == "-c" ]
then
    if [ "$parzip2" != "-F" ] && [ "$parzip2" != "-D" ]
    then
        print-help
        exit
    fi
fi

if [ "$parzip" == "-d" ]
then
    if [ "$parzip2" != "-N" ]
    then
        print-help
        exit
    fi
fi

if [ ! -d "$parzip4" ]
then
       mkdir -p $parzip4
fi

if [ "$typ" -eq 1 ] && [ "$parzip2" == "-N" ]
then
    cd $parzip4
    unzip -o $parzip3
fi

if [ "$typ" -eq 2 ] && [ "$parzip2" == "-F" ]
then
    parent=$(dirname "$parzip3")
    child=$(basename "$parzip3")
    cd "$parent"
    zip ${child}.zip $parzip3
    mv $parent/${child}.zip $parzip4
elif [ "$typ" -eq 2 ] && [ "$parzip2" == "-D" ]
then
    parent=$(dirname "$parzip3")
    child=$(basename "$parzip3")
    cd $parent
    zip -r ${child}.zip $parzip3
    mv $parent/${child}.zip $parzip4
else
    exit
fi
