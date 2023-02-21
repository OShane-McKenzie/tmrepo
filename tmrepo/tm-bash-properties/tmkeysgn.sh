mount -o rw,remount /
subject="$1"
modifier1="$2"
modifier2="$3"

function print_help ()
{
	# -gsfid -deviceid -set (--random-deviceid/--custom-deviceid) -keymatch -idrestore
	echo "Requires at least one (1) option"
	echo ""
	echo "Usage: tmkeysgn [options] [options] [options]"
	echo ""
	echo "-gsfid 		displays Google Services Framework ID"
	echo ""
	echo "-uid 		displays app user id"
	echo ""
	echo "-deviceid 	displays Android Device ID"
	echo ""
	echo "-set 		--random-deviceid OR --custom-deviceid (change device id as specified)"
	echo ""
	echo "-idrestore 	restores original device id"
	echo ""
	echo "-keymatch 	matches a saved key against a mapped gsfid"
	echo ""
	exit
}

function get_gsf_id ()
{
	raw_gsf_id=$(tmsqlite3 /data/data/com.google.android.gsf/databases/gservices.db \ "select * from main where name = \"android_id\";")

	gsf_id=$(echo "$raw_gsf_id" | cut -d'|' -f 2)
}

function userID ()
{
  pkg="$1"
  if [ -d /data/data/"$pkg" ]
  then
         dumpsys package "$pkg"|grep -A0 userId=|cut -d"=" -f 2|head -1
  else
         echo "cannot locate package "$pkg""
         return 1
   fi
}

function random_id_gen ()
{
	a=$(($RANDOM % 88+10))
	b=$(($RANDOM % 8888+1000))
	c=$(($RANDOM % 88+10))
	d=$(($RANDOM % 8888+1000))

	part1=$(echo "${a}"|base64)
	part2="$b"
	part3=$(echo "${c}"|base64)
	part4="$d"

	new_android_id=$(cat /proc/sys/kernel/random/uuid | tr -dc 'a-zA-Z0-9' | fold -w ${1:-16} | head -n 1)
}


function get_android_id ()
{
	old_android_id=$(settings get secure android_id)
}

id_bkp_f="/data/system/tmid.bkp"

function set_random_android_id ()
{
	get_android_id
	echo "current andorid id: $old_android_id"
	random_id_gen
	echo "New androd id: $new_android_id"
	
	if [ ! -f "$id_bkp_f" ]
	then
		touch $id_bkp_f
		echo "$old_android_id" > $id_bkp_f
	fi
	settings put secure android_id $new_android_id
	touch $id_bkp_f
}

function set_custom_android_id ()
{
	custom_android_id="$1"
	get_android_id
	echo "current andorid id: $old_android_id"
	echo ""
	echo "New androd id: $custom_android_id"
	
	if [ ! -f "$id_bkp_f" ]
	then
		touch $id_bkp_f
		echo "$old_android_id" > $id_bkp_f
	fi
	settings put secure android_id $custom_android_id
	touch $id_bkp_f
}


function id_restore ()
{
	if [ -f "$id_bkp_f" ]
	then
		ori_id=$(cat $id_bkp_f)
		settings put secure android_id $ori_id
		echo "android id restored"
	else
		echo "No id backup to restore"
	fi
}

function key_matcher ()
{
	user_key="$1"
	get_gsf_id
	g_id=$gsf_id
	key_f="$2"
	key_eval=$(awk -v uid="${user_key}" '$0 ~ uid {print $2}' ${key_f})

	if [ "$g_id" == "$key_eval" ]
	then
		match=1
	else
		match=0
	fi

	echo "$match"
}

function main ()
{
        # -gsfid -deviceid -set (--random-deviceid/--custom-deviceid) -keymatch -idrestore
    param="$subject"
    case $param in
    "-gsfid")

        get_gsf_id
        echo "$gsf_id"
            ;;

    "-deviceid")

        get_android_id
        echo "$old_android_id"
            ;;

    "-set")

        if [ "$modifier1" == "--random-deviceid" ]
        then
            set_random_android_id
        elif [ "$modifier1" == "--custom-deviceid" ]
        then
            if [ -z "$modifier2" ]
            then
                echo "custom id not provided"
                exit
            else
                set_custom_android_id $modifier2
            fi
        else
            echo "invalid or no arguments"
            print_help
        fi
            ;;

    "-idrestore")

        id_restore
            ;;

    "-keymatch")

        p1="$modifier1"
        p2="$modifier2"
        if [ -z "$p1" ] || [ -z "$p2" ]
        then
            echo "invalid or no arguments"
            print_help
        else
            key_matcher $modifier1 $modifier2
        fi
            ;;

    "-uid")
        if [ -z "$modifier1" ]
        then
                echo "missing arguments"
                print_help
        else
            userID "$modifier1"
        fi
            ;;
    "--help")
            print_help
            ;;

            *)
            echo "invalid or no arguments"
            print_help
    esac
}

main
