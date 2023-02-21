paath="$1"
target="$2"
newtarget="$3"

function print_help ()
{
	echo ""
	echo "Usage: [path/to/target] [target] [\"new name for target\"]"
	echo ""
	echo "Where ther are spaces between names or path, enclose in quotes: \"\""
	echo ""
	exit
}

if [ "$paath" == "--help" ]; then print_help;fi

if [ -z "$paath" ]
then
  	echo "Path to target is unspecified"
  	echo ""
    print_help
fi

if [ -z "$target" ]
then
  	echo "Target is unspecified"
  	echo ""
    print_help
fi

if [ -z "$newtarget" ]
then
  	echo "New target name is unspecified"
  	echo ""
    print_help
fi


mv "$paath"/"$target" "$paath"/"$newtarget"
#made by TeamMajor t.me/litecodzofficial
