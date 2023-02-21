#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>


void print_help (int x){
	printf("Usage: tmrman [option]\n");
	printf("\n");
	printf("-c (clear cache), -i (install), -r (remove), -u (update), -f (full repair), -h (shows this message)\n");
	printf("\n");
	exit(x);
}


void tm_run(char str[],char extra[],int buf){

	if (extra == NULL)
		{
			char buff[buf];
			sprintf(buff,str);
			system(buff);
		}
	else
	{
			char buff[buf];
			sprintf(buff,str,extra);
			system(buff);
	}
}

void tm_null (){
	int tm_clear=0, tm_install=0, tm_update=0, tm_remove=0, tm_fix=0;
}


void tm_execute (int task){

	char tm_rootDir[]="/data/system/tmrepo/";
	char tm_cacheDir[]="/data/system/tmrepo/cache/";
	char tm_packageDir[]="/data/system/tmrepo/package/";
	char tm_dataDir[]="/data/system/tmrepo/data/";
	char tm_updateDir[]="/data/system/tmrman/update/";
	char tm_tmrURL1[]="$(cat /data/system/tmrman/svr/updateF.tmr)";
	char tm_tmrURL2[]="$(cat /data/system/tmrman/svr/updateD.tmr)";

	tm_run("mount -o rw,remount /",NULL,50);

	switch(task){
		case 1:
			tm_run("rm -rf %s*",tm_cacheDir,50);
			tm_null();
			break;
		case 2:
			tm_run("rm -rf %s*",tm_updateDir,50);
			printf("\ngetting necessary files...make sure you have internet connection\n");
			tm_run("wget -q -P /data/system/tmrman/update %s",tm_tmrURL2,500);
			tm_run("wget -q -P /data/system/tmrman/update %s",tm_tmrURL1,500);
			printf("Attempting installation....\n");
			tm_run("cp -f %stmr /system/bin",tm_updateDir,100);
			tm_run("chmod 755 /system/bin/tmr",NULL,50);

			tm_run("if [ -f \"/data/system/tmrman/update/tmrepo.zip\" ];then cd /data/system;rm -rf /data/system/tmrepo;unzip -o %stmrepo.zip;else echo \"Could not proceed\";exit 3;fi",tm_updateDir,500);

			tm_run("rm -rf %s*",tm_updateDir,50);

			tm_run("tmr --update",NULL,15);

			tm_null();
			break;
		case 3:
			tm_run("rm -rf %s*",tm_updateDir,100);
			printf("\ngetting necessary files...make sure you have internet connection\n");
			tm_run("wget -q -P /data/system/tmrman/update %s",tm_tmrURL1,500);
			printf("Attempting update....\n");
			tm_run("if [ ! -f \"/data/system/tmrman/update/tmr\" ];then echo \"Could not proceed\";exit 6;fi",NULL,200);
			tm_run("cp -f %stmr /system/bin",tm_updateDir,100);
			tm_run("chmod 755 /system/bin/tmr",NULL,50);
			tm_run("rm -rf %s*",tm_updateDir,50);
			tm_run("tmr --update",NULL,15);
			tm_null();
			break;
		case 4:
			printf("\nremoving tmr from system\n");
			tm_run("rm -rf %s",tm_rootDir,50);
			tm_run("rm -rf /system/bin/tmr",NULL,50);
			tm_null();
			break;
		case 5:
			tm_run("rm -rf /data/system/tmrman/unis",NULL,50);
			printf("\nAttempting Repairs, make sure you have internet connection\n");
			tm_run("wget -q -P /data/system/tmrman/update %s",tm_tmrURL2,500);
			tm_run("cp -R %sunis /data/system/tmrman/",tm_dataDir,200);
			tm_run("if [ -f \"/data/system/tmrman/update/tmrepo.zip\" ];then cd /data/system;rm -rf /data/system/tmrepo;unzip -o %stmrepo.zip;else echo \"Could not proceed\";exit 4;fi",tm_updateDir,500);
			tm_run("cp -R /data/system/tmrman/unis %s",tm_dataDir,200);
			tm_null();
			break;
		default:
			printf("Unknown error");
			exit(5);

	}

}


int main (int argc, char **argv){

	if (argc < 2)
	{
		printf("\nInsufficient arguments\n");
		print_help(1);
	}

    int tm_val;

	int tm_clear, tm_install, tm_update, tm_remove, tm_fix;

	while((tm_val = getopt(argc, argv, "icurhf"))!=-1)
	{
		switch (tm_val){
			case 'c':
				tm_clear=1;
				tm_execute(tm_clear);
				break;
			case 'i':
				tm_install=2;
				tm_execute(tm_install);
				break;
			case 'u':
				tm_update=3;
				tm_execute(tm_update);
				break;
			case 'r':
				tm_remove=4;
				tm_execute(tm_remove);
				break;
			case 'f':
				tm_fix=5;
				tm_execute(tm_fix);
				break;
			case 'h':
				printf("\n");
				print_help(0);
			default:
				printf("\n");
				print_help(2);

		}
	}

	return 0;
}
