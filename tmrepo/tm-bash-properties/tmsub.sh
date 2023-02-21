mount -o rw,remount /
mode="$1" #-r = reverse substitution, -d = default substitution
aggression="$2" #-f = force overwrite files in bkp dir, -s do not overwrite
srcLocation="$3"
modLocation="$4"
bkpLocation="$5"
prem1="$6" #-ro = 444, -rw = 644, -rwx 755, --default = no change
prem2="$7" #-ro = 444, -rw = 644, -rwx 755, --default = no change
timer="$8" #0 for no timing
launcher="$9"
function print_help () {
	echo "cmd [mode] [force/no overwrite] [source location] [modfile-file location] [backup location] [1st permission] [2nd permission] [timer] [launcher option] [list of files]"
	echo ""
	echo "example: tmsub -r -s /data/data /data/new /data/original -rwx --default 4 com.myapp.play lib1.so lib2.so lib3.so"
	echo ""
	echo "-r = reverse substitution, -d = default substitution"
	echo ""
	echo "Launcher options: -n for no app launch OR simply enter package name"
	echo ""
	echo "-f = force overwrite files in bkp dir, -s do not overwrite"
	echo ""
	echo "permissions:-ro = 444, -rw = 644, -rwx 755, --default = no change"
	echo ""
	echo "timer 0 for no timing"
	#exit
}

if [ "$mode" == "--help" ];then print_help && echo "00" && exit;fi
case $mode in

  -r)
    modeVal=1
    timerOverwrite=1
    ;;

  -d)
    modeVal=0
    timerOverwrite=0
    ;;

  *)
	echo "Mode argument incorrect"
	echo ""
    print_help
    echo "1"
    exit
    ;;
esac

case $launcher in

  -n)
    launchVal=0
    ;;
    
  *)
	if [ ! -d "/data/data/$launcher" ]
	then
	       echo "cannot find target $launcher"
            exit
      else
            launchVal=1
      fi
    ;;
esac


if [ "$timer" == "0" ]
then
       timerOverwrite=0
fi


case $aggression in

  -f)
    aggVal=1
    ;;

  -s)
    aggVal=0
    ;;

  *)
	echo "overwrite argument incorrect"
	echo ""
    print_help
    echo "2"
    exit
    ;;
esac

if [ -z "$srcLocation" ]
  then
  	  echo "No source Location specified"
  	  echo ""
      print_help
      echo "3"
      exit
  fi

  if [ -z "$modLocation" ]
  then
  	  echo "No modified-file Location specified"
  	  echo ""
      print_help
      echo "4"
      exit
  fi

  if [ -z "$bkpLocation" ]
  then
  	  echo "No backup Location specified"
  	  echo ""
      print_help
      echo "5"
      exit
  fi

case $prem1 in

  -ro)
    lvl=444
    ;;

  -rw)
    lvl=644
    ;;

  -rwx)
    lvl=755
    ;;

  --default)
    lvl=0
    ;;
  *)
	echo "Permission argument incorrect"
	echo ""
    print_help
    echo "6"
    exit
    ;;
esac

case $prem2 in

  -ro)
    lvl2=444
    ;;

  -rw)
    lvl2=644
    ;;

  -rwx)
    lvl2=755
    ;;

  --default)
    lvl2=0
    ;;
  *)
	echo "Permission argument incorrect"
	echo ""
    print_help
    echo "7"
    exit
    ;;
esac

  if [ -z "$timer" ]
  then
  	  echo "No timer value specified"
  	  echo ""
      print_help
      echo "8"
      exit
  fi

if echo "$timer" | grep -qE '^[0-9]*\.?[0-9]+$'; then
   tVal=1
else
    echo "Timer must be a number 0 or more"
   	print_help
    echo "9"
    exit
fi

i="0"
cd "$srcLocation"
for var in "$@"
do
if [ "$var" != "$1" ] &&  [ "$var" != "$2" ] && [ "$var" != "$3" ] && [ "$var" != "$4" ] && [ "$var" != "$5" ] && [ "$var" != "$6" ] && [ "$var" != "$7" ] && [ "$var" != "$8" ] &&  [ "$var" != "$9" ]
then
		if [ "$aggVal" -eq 1 ]
		then
			cp -f "$srcLocation"/"$var" "$bkpLocation"
			rm -rf "$srcLocation"/"$var"
			cp -f "$modLocation"/"$var" "$srcLocation"
			if [ "$lvl" -gt 0 ];then chmod $lvl "$srcLocation"/"$var";fi
			let "i+=1"
		fi
		if [ "$aggVal" -eq 0 ]
		then
			cp -n "$srcLocation"/"$var" "$bkpLocation"
			rm -rf "$srcLocation"/"$var"
			cp -f "$modLocation"/"$var" "$srcLocation"
			if [ "$lvl" -gt 0 ];then chmod $lvl "$srcLocation"/"$var";fi
               let "i+=1"
		fi
fi
done

if [ "$launchVal" -eq 1 ]
then
       monkey -p "$launcher" -c android.intent.category.LAUNCHER 1
fi

if [ "$modeVal" -eq 1 ]
then
   sleep $timer
   for var in "$@"
   do
   if [ "$var" != "$1" ] &&  [ "$var" != "$2" ] &&  [ "$var" != "$3" ] &&  [ "$var" != "$4" ] &&  [ "$var" != "$5" ] &&  [ "$var" != "$6" ] &&  [ "$var" != "$7" ] &&  [ "$var" != "$8" ] &&  [ "$var" != "$9" ]
   then
	rm -rf "$srcLocation"/"$var"
	cp -f "$bkpLocation"/"$var" "$srcLocation"
	if [ "$lvl2" -gt 0 ];then chmod $lvl2 "$srcLocation"/"$var";fi
    fi
done
fi

echo "$i file(s) were substituted"
#made by TeamMajor t.me/litecodzofficial
