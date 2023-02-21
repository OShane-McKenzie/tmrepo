param="$1"
param2="$2"
function print_help ()
{
	echo "usage: tmperm <option> [permissions] files/directories"
	echo ""
	echo "any number of files or directories separated by single space"
	echo ""
	echo "-ro set permission to read-only
-R Recursively set permissions
-rw set permission to read-write
-wx set permission to write-execute
-rwx set permission to read-write-execute
-n remove permission
		 "
if [ "$param" == "--help" ]
then
    print_help
    exit
fi
}
	if [ "$param" != "-ro" ] && [ "$param" != "-rw" ] && [ "$param" != "-rwx" ] && [ "$param" != "-wx" ] && [ "$param" != "-n" ] && [ "$param" != "-R" ]
    then

    	print_help
    	exit
	fi

	if [ -z "$param2" ]
	then
	    print_help
	    exit
	fi

Recursive=0

for rec in "$@"
do
    if [ "$rec" == "-R" ]
    then
        let "Recursive += 1"
    fi
done

if [ "$Recursive" -gt 0 ]
then
    case $param2 in

    -n)
        lvl=000
        ;;

    -ro)
        lvl=444
        ;;

    -rw)
        lvl=644
        ;;

    -wx)
        lvl=555
        ;;

    -rwx)
        lvl=775
        ;;

    *)
        print_help
        exit
        ;;
    esac
else
    case $param in

    -n)
        lvl=000
        ;;

    -ro)
        lvl=444
        ;;

    -rw)
        lvl=644
        ;;

    -wx)
        lvl=555
        ;;

    -rwx)
        lvl=775
        ;;

    *)
        print_help
        exit
        ;;
    esac
fi

i="0"

for var in "$@"
do
    if [ "$var" != "-ro" ] && [ "$var" != "-rw" ] && [ "$var" != "-rwx" ] && [ "$var" != "-n" ] && [ "$var" != "-wx" ] && [ "$var" != "-R" ]
    then
    	if [ -f "$var" ] || [ -d "$var" ]
    	then
            if [ "$Recursive" -gt 0 ]
            then
                chmod -R $lvl $var
                let "i+=1"
            else
                chmod $lvl $var
                let "i+=1"
            fi
	    else
	    	echo "$var: No such file or directory"
	    fi
    fi
done
echo "$i permission(s) set"
#made by TeamMajor t.me/litecodzofficial
