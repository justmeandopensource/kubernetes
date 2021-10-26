rm centos8-6.sh
lxc list | rev | cut -f5,7 -d'|' | grep -v "+" | grep -v 'IPV4' | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -v EMAN | sed 's/ *//g' | cut -f2,4 -d' ' | cut -f2 -d'(' | sed 's/|/ /' | rev | awk '{i=NF;while(i)printf "%s",$i (i-->1?FS:RS)}' | sed "s/^/echo '/" | sed "s/$/' >> \/etc\/hosts/" >> centos8-6.sh
chmod 755 centos8-6.sh

