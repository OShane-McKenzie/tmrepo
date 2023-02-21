
loc="$1"
tym="$2"
anim="$3"

function print_help ()
{
	echo ""
	echo "Requires three (3) arguments"
	echo ""
	echo "usage: tmanimate [\"/path/to/directory\"] [Time delay between frame] [\"animation files\"]" 
	echo ""
}


function numCheck ()
{

	local test="$1"
	if [ -z "$test" ]
	then
	  	echo "No numeric value specified"
	    print_help
	fi

	if echo "$test" | grep -qE '^[0-9]*\.?[0-9]+$'; then
	   tVal=1
	else
	   echo "number must be an number > 0"
	   print_help
	fi
}

numCheck $tym

if [ -z "$loc" ]
  then
      print_help
      exit
  fi

if [ -z "$anim" ]
  then
      print_help
      exit
  fi

if [ "$loc" == "--help" ]
then
    print_help
    exit
fi


if [ ! -d "$loc" ]
then
	echo "Location Not found"
	print_help
fi

cd "$loc"
for var in "$@"
do
	if [ "$var" != "$1" ] && [ "$var" != "$2" ]
	then
		clear
		cat "$loc"/"$var"
		sleep $tym
	fi
done
#made by TeamMajor t.me/litecodzofficial
