mount -o rw,remount / 2>/dev/null
mount -o rw,remount /dev/block/mmcblk0p5 2>/dev/null

action="$1"

img_type="$2"

img_path="$3"

mnt_path="$4"

u_path="$2"


function print_help ()
{
	echo ""
	echo "Usage: tmmounter [-m] [image file system] [image path] [mount point]"
	echo "Usage: tmmounter [-u] [mount point]"
	echo ""
	echo "options: -m (mount)"
	echo ""
	echo "options: -u (unmount)"
	echo ""
	echo "File system: ext2 or ext3 or ext4"
	echo ""
}

if [ "$1" == "--help" ]
then
	print_help
	exit
fi

if [ "$action" != "-m" ] && [ "$action" != "-u" ]
then
	echo "Invalid or Missing arguments"
	print_help
	exit
fi

function validate ()
{
	local val_type="$1"

if [ "$val_type" -eq 1 ]
then
	if [ -z "$u_path" ]
	then
		echo "Missing arguments"
		print_help
		exit
	fi
fi
	if [ "$val_type" -eq 2 ]
	then
		
		if [ -z "$img_type" ] || [ -z "$img_path" ] || [ -z "$mnt_path" ]
		then
			echo "Missing arguments"
			print_help
			exit
		fi

		case $img_type in
			"ext2")
				t="true"
				;;
			"ext3")
				t="true"
				;;
			"ext4")
				t="true"
				;;
			*)
				t="false"
				echo "invalid or no arguments"
				print_help
		esac
	fi
}

function mnter ()
{
	local i_t="$1"
	local i_p="$2"
	local m_p="$3"

	if [ ! -b /dev/block/loop250 ]
	then
		mknod /dev/block/loop250 b 7 250 2>/dev/null
	fi

	losetup /dev/block/loop250 "$i_p" 2>/dev/null 

	mount -t "$i_t" /dev/block/loop250 "$m_p"
}

function umnter
{
	local m_p="$1"
	umount "$m_p" 2>/dev/null
	losetup -d /dev/block/loop250 2>/dev/null
}

function main ()
{
	
	if [ "$action" == "-m" ]
	then
		validate 2
		mnter "$img_type" "$img_path" "$mnt_path"
	elif [ "$action" == "-u" ]
	then
		validate 1
		umnter "$u_path"
	else
		echo "Unkown error"
		exit
	fi
}

main 2>/dev/null
