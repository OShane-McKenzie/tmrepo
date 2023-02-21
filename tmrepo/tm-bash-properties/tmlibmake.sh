fpath="$1"
fsize="$2"
fname="$3"

function print_help ()
{
echo "
	10000=1mb
	1000=100kb
	100=10kb
	10=1kb

	cmd \"path\" size \"filename\"
"
exit
}

function numCheck ()
{

	local test="$1"
	if [ -z "$fsize" ]
	then
	  	echo "No numeric value specified"
	    print_help
	fi

if [ "$fsize" -ne "$fsize" ] 2>/dev/null
then
 	print_help
fi
}

if [ "$fpath" == "--help" ]
	then
	print_help
fi

if [ -z "$fpath" ]
	then
	  	echo "No path specified"
	    print_help
fi

numCheck $fsize

if [ -z "$fname" ]
	then
	echo "No file name specified"
	print_help
fi

dd if=/dev/urandom of="$fpath"/"$fname" bs="$fsize" count=100
#made by TeamMajor t.me/litecodzofficial