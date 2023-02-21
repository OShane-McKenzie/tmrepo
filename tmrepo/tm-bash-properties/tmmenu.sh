function print_help ()
{
	echo ""
	echo "tmmenu [\"Title\"] [Title Colour] [\"Top Border Char\"] [Top Border Length] [Top Border Colour] [\"Bottom Border Char\"] [Bottom Border Length] [Bottom Border Colour] [Body Colour] \"menu items\" \"menu items\" ..."
	echo ""
	echo "Example:  tmmenu \"Test Menu\" -r \"+\" 15 -g \"=\" 15 -g -c \"Start         1\" \"Stop          2\" \"Quit          3\""
	echo ""
	echo "Availible Colours: red -r, green -g, cyan -c, none -n"
	echo ""
	exit
}

function checkCompat ()
{
	local test="$1"
	case $test in

	  \")
	    echo "Unsupported Character"
	    print_help
	    ;;

	  "\\")
	    echo "Unsupported Character"
	    print_help
	    ;;

	  \')
	    echo "Unsupported Character"
	    print_help
	    ;;

	   "\`")
	    echo "Unsupported Character"
	    print_help
	    ;;

	   "\$")
	    echo "Unsupported Character"
	    print_help
	    ;;
	    *)
		compt=1
	    ;;
	esac
}


function numCheck ()
{

	local test="$1"
	if [ -z "$test" ]
	then
	  	echo "No numeric value specified"
	    print_help
	fi

	if echo "$test" | grep -qE '^[1-9]+$'; then
	   tVal=1
	else
	   echo "number must be an integer > 0"
	   print_help
	fi
}

function clrCheck ()
{
	local test="$1"
	if [ "$test" != "-c" ] && [ "$test" != "-g" ] && [ "$test" != "-r" ] && [ "$test" != "-n" ]
	then
		echo "Incorrect colour arg"
		print_help
	fi
}


titleTxt="$1"
checkCompat $titleTxt
titleColour="$2"
clrCheck $titleColour
topChar="$3"
checkCompat $topChar
topSize="$4"
numCheck $topSize
topColour="$5"
clrCheck $topColour

btmChar="$6"
checkCompat $btmChar
btmSize="$7"
numCheck $btmSize
btmColour="$8"
clrCheck $btmColour

bodyColour="$9"
clrCheck $bodyColour

cy='\033[0;36m'
gr='\033[0;32m'
re='\033[0;31m'
no='\033[0m'

function setColour ()
{
	local colour="$1"
	local cy='\033[0;36m'
	local gr='\033[0;32m'
	local re='\033[0;31m'
	local no='\033[0m'

	if [ "$colour" == "-c" ]
	then
		echo -e -n ${cy}
	fi
	if [ "$colour" == "-g" ]
	then
		echo -e -n ${gr}
	fi

	if [ "$colour" == "-r" ]
	then
		echo -e -n ${re}
	fi

	if [ "$colour" == "-n" ]
	then
		echo -e -n ${no}
	fi
}

setColour $titleColour;echo "$titleTxt"
echo -e "${no}"
i=$topSize
while [ "$i" -gt 0 ]
do
	if [ "$i" -eq 1 ]
	then
		setColour $topColour;echo "$topChar"
		#echo -e "${no}"
		echo -e "${no}"
		let "i-=1"
	else
		setColour $topColour;echo -n "$topChar"
		let "i-=1"
	fi
done

for var in "$@"
do
if [ "$var" != "$1" ] &&  [ "$var" != "$2" ] &&  [ "$var" != "$3" ] &&  [ "$var" != "$4" ] &&  [ "$var" != "$5" ] &&  [ "$var" != "$6" ] &&  [ "$var" != "$7" ] &&  [ "$var" != "$8" ] && [ "$var" != "$9" ]
then
	setColour $bodyColour;echo -n "$var"
	echo -e "${no}"
	echo -e "${no}"
fi
done
j=$btmSize
while [ "$j" -gt 0 ]
do
	if [ "$i" -eq 1 ]
	then
		setColour $btmColour;echo "$btmChar"
		echo -e "${no}"
		let "j-=1"
	else
		setColour $btmColour;echo -n "$btmChar"
		let "j-=1"
	fi
done
echo -e "${no}"
#made by TeamMajor t.me/litecodzofficial
