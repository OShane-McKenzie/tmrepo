mount -o rw,remount /;mount -o rw,remount /system

#Dev: Lite Riyusaki t.me/litecodzofficial
#TeamMajor
#Provided Free
#Help improve this project by contributing to it
#contact Lite Riyusaki t.me/litecodzofficial


#GLOBAL
#=================================================
main_dir=/data/system/tmrepo
pkg_dir=$main_dir/package
cache_dir=$main_dir/cache
data_dir=$main_dir/data
ver_dir=$data_dir/versions
upg_dir=$data_dir/upgrade
rep_dir=$data_dir/repos
unins_dir=$data_dir/unis
updt_dir=$data_dir/svr

CYN='\033[0;36m'
GRN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

svr_f=$updt_dir/svr.tmr
repo_f=$rep_dir/tmrepo.info
doc_f=$ver_dir/documentation.info

#=================================================

#cli_args=========================================
take="$1"
subject="$2"
modify="$3"
#=================================================
my_version=4
#Global_modifiers=================================
multiple=0
autoconfirm=0
total_size=0
userconfirmed=0
rinstall=0
cleani=0
cremove=0
depp=0
upg=0
#=================================================

#control_modifiers================================

m_chk=0
a_chk=0
c_chk=0
r_chk=0
u_chk=0
up_chk=0
#=================================================

function print_help ()
{
	echo -e ${CYN}
	echo "Usage: tmr [options] [options] (-y or -m)"
	echo ""
	echo "--install :  Installs package (-m for multiple installations -y for auto-confirmation) [ tmr --install -m -y package1 package2 ]"
	echo ""
	echo "--update :  Update repository"
	echo ""
	echo "--upgrade :  Update installed tmr packages"
	echo ""
	echo "--search [keyword] look for specific info in package database: --search --all : displays entire package database"
	echo ""
	echo "--remove :  remove package, --remove -c: to remove package from cache" 
	echo ""
	echo "--reinstall :  reinstall package from repository${NC}"
	echo ""
	exit
}

function reins_chk ()
{
	for var7 in "$@"
	do
		if [ "$var7" == "--reinstall" ]
		then
			let "rinstall += 1"
		fi
	done
}


function clean_chk ()
{
	for var10 in "$@"
	do
		if [ "$var10" == "-c" ]
		then
			let "cremove += 1"
		fi
	done
}

function autocon_chk ()
{
	for var in "$@"
	do
		if [ "$var" == "-y" ]
		then
			let "autoconfirm += 1"
		fi
	done
}

function multi_chk ()
{
	for var5 in "$@"
	do
		if [ "$var5" == "-m" ]
		then
			let "multiple += 1"
		fi
	done
}

function size_chk ()

{
	for var2 in "$@"
	do
		t_size=$(awk -v apps="${var2}" '$0 ~ apps {print $3}' ${repo_f} 2>/dev/null)
		app_n=$(awk -v appn="${var2}" '$0 ~ appn {print $1}' ${repo_f} 2>/dev/null)
		if [ "$var2" == "$app_n" ]
		then
			let "total_size += $t_size"
		fi
	done
}

function err_chk ()
{
	for err in "$@"
	do
		if [ "$err" == "-y" ]
		then
			let "a_chk += 1"
		fi

		if [ "$err" == "-m" ]
		then
			let "m_chk += 1"
		fi

		if [ "$err" == "--reinstall" ]
		then
			let "r_chk += 1"
		fi

		if [ "$err" == "--update" ]
		then
			let "u_chk += 1"
		fi

		if [ "$err" == "--upgrade" ]
		then
			let "up_chk += 1"
		fi

		if [ "$err" == "-c" ]
		then
			let "c_chk += 1"
		fi 
	done

	if [ "$a_chk" -gt 1 ]; then echo -e "${RED}Error too many (-y), number is $a_chk ${NC}" && exit 1;fi
	if [ "$m_chk" -gt 1 ]; then echo -e "${RED}Error too many (-m), number is $m_chk ${NC}" && exit 1;fi
	if [ "$c_chk" -gt 1 ]; then echo -e "${RED}Error too many (-c), number is $c_chk ${NC}" && exit 1;fi
	if [ "$r_chk" -gt 1 ]; then echo -e "${RED}Error too many (--reinstall), number is $r_chk ${NC}" && exit 1;fi
	if [ "$u_chk" -gt 1 ]; then echo -e "${RED}Error too many (--update), number is $u_chk ${NC}" && exit 1;fi
	if [ "$up_chk" -gt 1 ]; then echo -e "${RED}Error too many (--upgrade), number is $up_chk ${NC}" && exit 1;fi

}

function get_dependencies ()
{
	
echo -e "${CYN}Getting dependencies${NC}"
    
let "depp += 1"
if [ "$multiple" -eq 0 ];then multi_chk "$@";fi

if [ "$multiple" -gt 0 ]
then
	#size and auto-confirmation check for multiple installations
	size_chk "$@"
	if [ "$autoconfirm" -eq 0 ];then autocon_chk "$@";fi
	

	if [ "$autoconfirm" -lt 1 ]
	then
		echo "After this operation, $total_size KB of additional disk space will be used."
		echo -e "Do you want to continue? [${GRN}Y/${RED}n${NC}] Default ${RED}n${NC}"
		read choiz
	else
		choiz="y"
	fi

	#[HC] handling choice
	#[HC]===================================================================================
	case $choiz in
	"Y" | "y")
	
	#performing multiple instalations
	for var3 in "$@"
	do
		dpp_n2=$(awk -v dppm="${var3}" '$0 ~ dppm {print $1}' ${repo_f} 2>/dev/null)

		if [ "$var3" == "$dpp_n2" ]
		then
			let "userconfirmed += 1"
			     tstall "$dpp_n2"

		fi
	done
	     ;;
	     

	"N" | "n")
	echo "${RED}Abort${NC}"
		exit
		 ;;

		*)
	echo -e "${RED}Abort"
	echo "Could not get required dependencies${NC}"
     rm -rf $pkg_dir/${app_name}.zip 2>/dev/null;rm -rf $pkg_dir/$app_name 2>/dev/null;rm -rf $cache_dir/${app_name}.zip 2>/dev/null
	let "depp = 0"
	esac
fi
}

function tstall ()
{
	#reset size variable
	let "total_size = 1-1"

	#[PP] parse package name, url and size
	#[PP]==================================================
	local app_name="$1"

	local get_app=$(awk -v appg="${app_name}" '$0 ~ appg {print $5}' ${repo_f} 2>/dev/null)

	local app_size=$(awk -v appz="${app_name}" '$0 ~ appz {print $3}' ${repo_f} 2>/dev/null)
	#[PP]==================================================

#[AF] Whether or not user input auto-confirmation flag (-y)
#[AF]========================================================================================================================
	if [ "$autoconfirm" -lt 1 ]
	then
		#[TC] taking Manual confirmation
		#[TC]=============================================================================
		if [ "$userconfirmed" -lt 1 ] && [ "$rinstall" -lt 1 ]
		then
			echo "After this operation, $app_size KB of additional disk space will be used."
			echo -e "Do you want to continue? [${GRN}Y/${RED}n${NC}] Default ${RED}n${NC}"
			read choice
		else
			choice="y"
		fi

		case $choice in
		"Y" | "y")
			conf=1
		;;

		"N" | "n")
			conf=0
		;;

		*)
		conf=0
		esac
		#[TC]=============================================================================

		#[EC] evaluating Manual confirmation
		#[EC]=============================================================================
		if [ "$conf" -eq 1 ]
		then
			#if package not already in cache!
			if [ ! -f "$cache_dir/${app_name}.zip" ] || [ "$cleani" -gt 0 ]
			then
				#Is there network access or is server available?
				wget -q --spider $get_app 2>/dev/null
				if [ $? -ne 0 ]
				then
		       		echo "${RED}Cannont Connect to server${NC}"
		       		echo "${RED}Failed to install $app_name${NC}"
		       		exit 1
		    	fi

		    	#[DM] download and install package manual confirmation
		    	#[DM]========================================================================
		    	wget -P $pkg_dir $get_app 2>/dev/null
		    	cd $pkg_dir 2>/dev/null
		    	cp -f $pkg_dir/${app_name}.zip $cache_dir 2>/dev/null
		    	echo -e ${GRN}

		    	unzip -o ${app_name}.zip 2>/dev/null
		    	if [ -f "$pkg_dir/$app_name/main" ]
		    	then
		    		cd $pkg_dir/$app_name
		    		if [ -f "$pkg_dir/$app_name/dependencies.txt" ]
		    		then
		    		       get_dependencies $(cat $pkg_dir/$app_name/dependencies.txt)
		    		fi
		    		if [ -f "$pkg_dir/$app_name/dependencies.txt" ]
		    		then
		    			if [ "$depp" -lt 1 ]
		    			then
		    				echo -e "${RED}Could not get required dependencies${NC}"
		    				rm -rf $pkg_dir/${app_name}.zip 2>/dev/null;rm -rf $pkg_dir/$app_name 2>/dev/null;rm -rf $cache_dir/${app_name}.zip 2>/dev/null
		    				exit 1
		    			fi
		    		fi
		    		rm -rf $pkg_dir/${app_name}.zip 2>/dev/null
		    		chmod 777 $pkg_dir/$app_name/main 2>/dev/null
		    		
		    		if [ -f "$unins_dir/${app_name}.unins" ] && [ "$upg" -lt 1 ]
                    then
                          echo -e "${CYN}${app_name} was already installed${NC}"
	                else
	                       mv $pkg_dir/${app_name}/${app_name}.unins $unins_dir 2>/dev/null
	                       chmod 777 $unins_dir/${app_name}.unins 2>/dev/null
		    		       $pkg_dir/$app_name/main
		    		       if [ $? -ne 0 ]
		    		       then
		    		            run_good=1
		    		       else
		    		           run_good=0
		    		       fi
		    		       local app_ver=$(awk -v appz="${app}" '$0 ~ appz {print $4}' ${repo_f} 2>/dev/null)
			            echo -n "$app_ver" > $ver_dir/"${app}".vr
			            if [ $run_good -le 0 ]
			            then
		    		    	echo -e "${GRN}$app_name has been installed${NC}"
		    		    else
		    		    	echo -e "${RED}$app_name may not have been correctly installed${NC}"
		    		    fi
		    		  fi
		    		  rm -rf $pkg_dir/$app_name 2>/dev/null
		    		
		    	else
		    		echo -e "${RED}Could not parse package $app_name${NC}"
		    		rm -rf $pkg_dir/${app_name}.zip 2>/dev/null;rm -rf $pkg_dir/$app_name 2>/dev/null;rm -rf $cache_dir/${app_name}.zip 2>/dev/null
		    		let "depp = 0"
		    		exit 1

		    	fi

		    	#[DM]========================================================================

			#if package is already in cache!
		    else
		    	#[CM] copy and install package
		    	#[CM]========================================================================
		    	cd $pkg_dir 2>/dev/null
		    	cp -f $cache_dir/${app_name}.zip $pkg_dir 2>/dev/null
		    	echo -e ${GRN}
		    	unzip -o ${app_name}.zip 2>/dev/null
		    	if [ -f "$pkg_dir/$app_name/main" ]
		    	then
		    		cd $pkg_dir/$app_name
		    		if [ -f "$pkg_dir/$app_name/dependencies.txt" ]
		    		then
		    		      get_dependencies $(cat $pkg_dir/$app_name/dependencies.txt)
		    		 fi
		    		 
		    		if [ -f "$pkg_dir/$app_name/dependencies.txt" ]
		    		then
		    			if [ "$depp" -lt 1 ]
		    			then
		    				echo -e "${RED}Could not get required dependencies${NC}"
		    				rm -rf $pkg_dir/${app_name}.zip 2>/dev/null;rm -rf $pkg_dir/$app_name 2>/dev/null;rm -rf $cache_dir/${app_name}.zip 2>/dev/null
		    				exit 1
		    			fi
		    		fi
		    		rm -rf $pkg_dir/${app_name}.zip 2>/dev/null
		    		chmod 777 $pkg_dir/$app_name/main 2>/dev/null
		    		
		    		if [ -f "$unins_dir/${app_name}.unins" ]  && [ "$upg" -lt 1 ]
                    then
                          echo -e "${CYN}${app_name} was already installed${NC}"
	                else
		    		       mv $pkg_dir/${app_name}/${app_name}.unins $unins_dir 2>/dev/null
	                      chmod 777 $unins_dir/${app_name}.unins 2>/dev/null
		    		       $pkg_dir/$app_name/main
		    		    if [ $? -ne 0 ]
		    		       then
		    		            run_good=1
		    		       else
		    		           run_good=0
		    		       fi
		    		    if [ $run_good -le 0 ]
			            then
		    		    	echo -e "${GRN}$app_name has been installed${NC}"
		    		    else
		    		    	echo -e "${RED}$app_name may not have been correctly installed${NC}"
		    		    fi
		    		  fi
		    		  rm -rf $pkg_dir/$app_name 2>/dev/null
		    	else
		    		echo -e "${RED}Could not parse package $app_name${NC}"
		    		rm -rf $pkg_dir/${app_name}.zip 2>/dev/null;rm -rf $pkg_dir/$app_name 2>/dev/null
		    		let "depp = 0"
		    		exit 1
		    	fi
		    	#[CM]========================================================================
		    fi
		else
			echo -e "${RED}Abort${NC}"
			let "upg -= 1"
			#exit
		fi
		#[EC]=============================================================================

	#[EC] using auto confirmation
	#[UA]=============================================================================

	
	elif [ "$autoconfirm" -eq 1 ]
	then
		#if package not already in cache!
		if [ ! -f "$cache_dir/${app_name}.zip" ]
		then
			#Is there network access or is server available?
			wget -q --spider $get_app 2>/dev/null
			if [ $? -ne 0 ]
			then
		       	echo -e "${RED}Cannont Connect to server${NC}"
		       	exit 1
		    fi

		    #[DA] download and install package auto confirmation
		    #[DA]========================================================================
		    wget -P $pkg_dir $get_app 2>/dev/null
		    cd $pkg_dir
		    cp -f $pkg_dir/${app_name}.zip $cache_dir 2>/dev/null
		    echo -e ${GRN}
		    unzip -o ${app_name}.zip 2>/dev/null
		    if [ -f "$pkg_dir/$app_name/main" ]
		    then
		    	cd $pkg_dir/$app_name
		    		if [ -f "$pkg_dir/$app_name/dependencies.txt" ]; then get_dependencies $(cat $pkg_dir/$app_name/dependencies.txt); fi
		    		if [ -f "pkg_dir/$app_name/dependencies.txt" ]
		    		then
		    			if [ "$depp" -lt 1 ]
		    			then
		    				echo -e "${RED}Could not get required dependencies${NC}"
		    				rm -rf $pkg_dir/${app_name}.zip 2>/dev/null;rm -rf $pkg_dir/$app_name 2>/dev/null;rm -rf $cache_dir/${app_name}.zip 2>/dev/null
		    				exit 1
		    			fi
		    		fi
		    	rm -rf $pkg_dir/${app_name}.zip 2>/dev/null
		    	chmod 777 $pkg_dir/$app_name/main 2>/dev/null
		    	
		    	if [ -f "$unins_dir/${app_name}.unins" ]  && [ "$upg" -lt 1 ]
                    then
                          echo -e "${CYN}${app_name} was already installed${NC}"
	                else
		    		       mv $pkg_dir/${app_name}/${app_name}.unins $unins_dir 2>/dev/null
	                      chmod 777 $unins_dir/${app_name}.unins 2>/dev/null
		    		       $pkg_dir/$app_name/main
		    		       if [ $? -ne 0 ]
		    		       then
		    		            run_good=1
		    		       else
		    		           run_good=0
		    		       fi
		    		       local app_ver=$(awk -v appz="${app}" '$0 ~ appz {print $4}' ${repo_f} 2>/dev/null)
			            echo -n "$app_ver" > $ver_dir/"${app}".vr

		    		    if [ $run_good -le 0 ]
			            then
		    		    	echo -e "${GRN}$app_name has been installed${NC}"
		    		    else
		    		    	echo -e "${RED}$app_name may not have been correctly installed${NC}"
		    		    fi
		    		  fi
		    		  rm -rf $pkg_dir/$app_name 2>/dev/null
		    else
		    	echo -e "${RED}Could not parse package $app_nameecho ${NC}"
		    	rm -rf $pkg_dir/${app_name}.zip 2>/dev/null;rm -rf $pkg_dir/$app_name 2>/dev/null;rm -rf $cache_dir/${app_name}.zip 2>/dev/null
		    	let "depp = 0"
		    	exit 1
		    fi
		    #[DA]========================================================================
		#if package is already in cache!
		else
	   		#[CM] copy and install package
		    #[CM]========================================================================
	   		cd $pkg_dir 2>/dev/null
	    	cp -f $cache_dir/${app_name}.zip $pkg_dir 2>/dev/null
	    	echo -e "${GRN}"
	    	unzip -o ${app_name}.zip 2>/dev/null
	    	if [ -f "$pkg_dir/$app_name/main" ]
	    	then
	    		cd $pkg_dir/$app_name
	    			if [ -f "$pkg_dir/$app_name/dependencies.txt" ]; then get_dependencies $(cat $pkg_dir/$app_name/dependencies.txt); fi
		    		if [ -f "$pkg_dir/$app_name/dependencies.txt" ]
		    		then
		    			if [ "$depp" -lt 1 ]
		    			then
		    				echo -e "${RED}Could not get required dependencies${NC}"
		    				rm -rf $pkg_dir/${app_name}.zip 2>/dev/null;rm -rf $pkg_dir/$app_name 2>/dev/null;rm -rf $cache_dir/${app_name}.zip 2>/dev/null
		    				exit 1
		    			fi
		    		fi
	    		rm -rf $pkg_dir/${app_name}.zip 2>/dev/null
	    		chmod 777 $pkg_dir/$app_name/main 2>/dev/null
	    		
	    		if [ -f "$unins_dir/${app_name}.unins" ]  && [ "$upg" -lt 1 ]
                    then
                          echo -e "${CYN}${app_name} was already installed${NC}"
	                else
		    		       mv $pkg_dir/${app_name}/${app_name}.unins $unins_dir 2>/dev/null
	                      chmod 777 $unins_dir/${app_name}.unins 2>/dev/null
		    		       $pkg_dir/$app_name/main
		    		    if [ $? -ne 0 ]
		    		       then
		    		            run_good=1
		    		       else
		    		           run_good=0
		    		       fi
		    		    if [ $run_good -le 0 ]
			            then
		    		    	echo -e "${GRN}$app_name has been installed${NC}"
		    		    else
		    		    	echo -e "${RED}$app_name may not have been correctly installed${NC}"
		    		    fi
		    		  fi
		    		  rm -rf $pkg_dir/$app_name 2>/dev/null
	    	else
	    		echo "${RED}Could not parse package $app_name${NC}"
	    		let "depp = 0"
	    		rm -rf $pkg_dir/${app_name}.zip 2>/dev/null;rm -rf $pkg_dir/$app_name 2>/dev/null
	    		exit 1
	    	fi
	    	#[CM]========================================================================
		fi
	#[UA]=============================================================================

	else
		echo -e "${RED}Unable to get confrimation${NC}"
		exit 2
	fi
#[AF]======================================================================================================================
}



function tremove ()
{
	local app_name="$1"
	local get_app=$(awk -v appg="${app_name}" '$0 ~ appg {print $5}' ${repo_f} 2>/dev/null)
	local app_size=$(awk -v appz="${app_name}" '$0 ~ appz {print $3}' ${repo_f} 2>/dev/null)


	if [ "$userconfirmed" -lt 1 ] && [ "$rinstall" -lt 1 ]
	then
		echo "After this operation, $app_size KB of disk space will be freed."
		echo -e "Do you want to continue? [${GRN}Y/${RED}n${NC}] Default ${RED}n${NC}"
		read rmve
	elif [ "$rinstall" -gt 0 ]
	then
		echo "Are you sure you want to reinstall $app_name? [${GRN}Y/${RED}n${NC}] Default ${RED}n${NC}"
		read rmve
	else
		rmve="y"
	fi

	case $rmve in
	"Y" | "y")
		rconf=1
	;;

	"N" | "n")
		rconf=0
	;;

	*)
	rmve=0
	esac

	if [ "$rconf" -eq 1 ] &&  [ -f "$unins_dir/${app_name}.unins" ]
	then
		$unins_dir/${app_name}.unins
		rm -rf $unins_dir/${app_name}.unins
		if [ "$cremove" -gt 0 ]; then rm -rf $cache_dir/${app_name}.zip; fi
		echo -e "${GRN}$app_name was successfully removed ${NC}"
	else
	    echo "${RED}${app_name} is not installed${NC}"
	    exit 1
	fi
}

function get_pkgList ()
{
          rm -rf $ver_dir/upgrd.lst
          cd $unins_dir
		for FILE in *.unins
		do
			
			local get_v=$(echo "$FILE" | cut -d'.' -f 1)
			local unis_n=$(echo -n $get_v)
               echo -n "${unis_n} " >> $ver_dir/upgrd.lst
		done
		#echo -n "-m" >> $ver_dir/upgrd.lst

}

function tupdate ()
{ 
	
	cp -f $repo_f $cache_dir 2>/dev/null
	cp -f $doc_f $cache_dir 2>/dev/null
	rm -rf $repo_f 2>/dev/null
	rm -rf $doc_f 2>/dev/null
	touch $repo_f 2>/dev/null

	cd $updt_dir
	echo "Contacting servers..."
	while IFS= read -r line
	do
		
		wget -q --spider $line 2>/dev/null
		if [ $? -ne 0 ]
		then
	     	if [ ! -z "$line" ]
		     then
       		echo -e "${RED}Connection error${NC}"
       	     fi
    	fi
    	wget -P $updt_dir $line

	done < "$svr_f"

    echo "processing information..."

	for FILE in *.repo
	do
		cat $FILE >> $repo_f
	done

	rm -rf $updt_dir/*.repo
	mv $updt_dir/documentation.info $ver_dir
     
	if [ ! -f "$ver_dir/enabled" ]
	then
		echo "Fixing Versions"
		cd $unins_dir
		
		for app in "$@"
		do
			
			local app_size=$(awk -v appz="${app}" '$0 ~ appz {print $4}' ${repo_f} 2>/dev/null)

			echo -n "$app_size" > $ver_dir/"${app}".vr
		done
		echo "done"
		touch $ver_dir/enabled
	else
		cd $unins_dir
		for app in *.unins
		do
			get_v=$(echo "$app" | cut -d'.' -f 1)
			unis_n=$(echo -n $get_v)

			local app_size=$(awk -v appz="${unis_n}" '$0 ~ appz {print $4}' ${repo_f} 2>/dev/null)
			current=$(cat $ver_dir/${unis_n}.vr)
			if [ "$app_size" -gt "$current" ]
			then
				echo -e "${CYN}"
				echo -e "$unis_n ${NC}can be updated to version ${GRN}${app_size}${NC}, current version is ${RED}$current${NC} run tmr --upgrade to update it."
				echo ""
			fi
		done

		echo "Done"
	fi
}


function tupgrade ()
{
	cd $unins_dir
	for FILE in "$@"
	do

		local app_vers=$(awk -v appx="${FILE}" '$0 ~ appx {print $4}' ${repo_f} 2>/dev/null)
		current=$(cat $ver_dir/"${FILE}".vr)
		if [ "$app_vers" -gt "$current" ]
		then
		    echo -e "${CYN}"
			echo -e "$FILE ${NC}can be updated to version ${GRN}${app_vers}${NC}, current version is ${RED}$current${NC}"
			echo ""
			if [ "$multiple" -eq 0 ];then multi_chk "$@";fi
			if [ "$autoconfirm" -eq 0 ];then autocon_chk "$@";fi
			rm -rf $cache_dir/${FILE}.zip
			let "upg += 1"
			tstall $FILE
			echo -n "$app_vers" > $ver_dir/"${FILE}".vr
		else
			echo -e "${CYN}"
			echo -e "$FILE ${NC}alread at latest version, current version is ${GRN}$current${NC}"
			echo ""
		fi
	done
     echo "$upg package(s) were upgraded"
}


function main ()
{
	echo $my_version > $ver_dir/my_v
	err_chk "$@"
	for parm in "$take"
	do
		#[PA] parsing arguments
		#[PA]===========================================================================================
		case $parm in

			"--install" )
			if [ -z "$subject" ]; then echo "insufficent arguments run tmr --help" && exit; fi
			#whether or not user input multiple's flag (-m)
			multi_chk "$@"
			if [ "$multiple" -gt 0 ]
			then
				#size and auto-confirmation check for multiple installations
				size_chk "$@"

				autocon_chk "$@"

				if [ "$autoconfirm" -lt 1 ]
				then
					echo "After this operation, $total_size KB of additional disk space will be used."
					echo -e "Do you want to continue? [${GRN}Y/${RED}n${NC}] Default ${RED}n${NC}"
					read choiz
				else
					choiz="y"
				fi

				#[HC] handling choice
				#[HC]===================================================================================
				case $choiz in
				"Y" | "y")
				
				#performing multiple instalations
				for var3 in "$@"
				do
					app_n2=$(awk -v appm="${var3}" '$0 ~ appm {print $1}' ${repo_f} 2>/dev/null)
					if [ "$var3" == "$app_n2" ]
					then
						let "userconfirmed += 1"
						tstall "$app_n2"
					fi
				done
				;;

				"N" | "n")
				echo "Abort"
				exit
				;;

				*)
				echo "Abort"
				exit
				esac
			else
				#performing single instalation
				autocon_chk "$@"
				var4="$subject"
				app_n3=$(awk -v appn="${var4}" '$0 ~ appn {print $1}' ${repo_f} 2>/dev/null)
				if [ "$var4" == "$app_n3" ]
				then
					tstall "$app_n3"
				else
					echo -e "${RED}Could not locate $var4 ${GRN}try runing tmr --update ${NC}first"
					exit
				fi
			fi
			#[HC]=======================================================================================
		;;

		"--remove")
			if [ -z "$subject" ]; then echo "insufficent arguments run tmr --help" && exit; fi
			clean_chk "$@"
			reins_chk "$@"
			autocon_chk "$@"
			local var6="$subject"
			local app_n5=$(awk -v appr="${var6}" '$0 ~ appr {print $1}' ${repo_f} 2>/dev/null)
			if [ "$var6" == "$app_n5" ]
			then
				tremove "$app_n5"
			else
				echo -e "${RED}Could not locate $var6${NC}"
				exit
			fi
			;;

		"--update")
		     get_pkgList
			tupdate $(cat $ver_dir/upgrd.lst)
			;;

		"--upgrade")
		     get_pkgList
			tupgrade $(cat $ver_dir/upgrd.lst)
			;;

		"--reinstall")
			if [ -z "$subject" ]; then echo "insufficent arguments run tmr --help" && exit; fi
			let "cleani += 1"
			local var8="$subject"
			local app_n8=$(awk -v appri="${var8}" '$0 ~ appri {print $1}' ${repo_f} 2>/dev/null)
			if [ "$var8" == "$app_n8" ]
			then
				tremove $app_n8
				tstall $app_n8
			else
				echo -e "${RED}Could not locate ${var8}${NC}"
				exit
			fi
			;;

		"--search")
			if [ -z "$subject" ]; then echo "insufficent arguments run tmr --help" && exit; fi
			if [ "$subject" == "--all" ]
			then
			      echo -e -n "${CYN}"
				cat $doc_f
				echo -e "${NC}"
				exit
			fi
			echo -e -n "${CYN}"
			grep -i -s "$subject" $doc_f
			echo -e "${NC}"
			exit
			;;

		"--help")
			
			print_help
			exit
			;;
		*)
		echo -e "${RED}could not execute command. ${GRN}Run tmr --help${NC}"
		exit 1
		esac
		#[PA]===========================================================================================
	done
}

main "$@" 2>/dev/null
