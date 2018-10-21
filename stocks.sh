# Trung Nguyen
# Feb. 23, 2018
# for loop to process stock list

trap 'tput setab 0; tput setaf 7; stty sane;exit' SIGTERM SIGINT SIGQUIT

clear

#initializes colm and row of the stocks in the first row
trow=2
tcolm=8
counter=0

echo > volume.txt #top volume
echo > winner.txt #top winner
echo > loser.txt #top loser

#title
tput cup 0 72
echo "Dow Jones Industrial Average"

#exhibition of stocks 
while true 
do
	for stock in `cat stocks.txt`
	do
		wget -qO- https://api.iextrading.com/1.0/stock/$stock/batch?types=quote\&range=1m\&last=10 > iex1
		sed s/"}}"/"}}\n"/g <iex1 >iex2
		sed s/","/",\n"/g <iex2 >iex3

		name=`grep companyName iex3    | awk -F: '{print $2}' 		| sed s/"\""/""/g | sed s/","/""/g 	|cut -c1-18` 
		price=`grep latestPrice iex3   | awk -F: '{print $2}' 		| sed s/","/""/g 			|cut -c1-18`
		change=`grep "\"change\"" iex3 | head -1 | awk -F: '{print $2}' | sed s/","/""/g			|cut -c1-18`
		volume=`grep latestVolume iex3 | awk -F: '{print $2}' 		| sed s/","/""/g			|cut -c1-18` 

		#output green for positive change and red for negative change
		negative=`echo $change | grep "-" | wc -l`
		
		if [ "$change" == "0" ]
		then	
			#yellow
			tput setab 3; 
			tput setaf 0; 
		elif [ $negative -eq 0 ]
		then
			#green
			tput setab 2;
			tput setaf 0;
		else
			#red
			tput setab 1;
			tput setaf 0;
		fi

		echo "TOP VOLUME : $stock $volume" >> volume.txt 		#top volume
		
		if [ $negative -eq 0 ]						#top winner
		then
			echo "TOP WINNER : $stock $change" >> winner.txt
		else								#top loser
			echo "TOP LOSER : $stock $change" >> loser.txt
		fi
	
		tput cup $trow $tcolm;
		echo "                    "
		tput cup $trow $tcolm;
		echo $stock
	
		trow=$((trow+1))
		tput cup $trow $tcolm;
		echo "                    "
		tput cup $trow $tcolm;
		echo $name
	
		trow=$((trow+1))
		tput cup $trow $tcolm;
		echo "                    "
		tput cup $trow $tcolm;
		echo $price

		trow=$((trow+1))
		tput cup $trow $tcolm;
		echo "                    "
		tput cup $trow $tcolm;
		echo $change

		trow=$((trow+1))
		tput cup $trow $tcolm;
		echo "                    "
		tput cup $trow $tcolm;
		echo $volume
		echo

		tcolm=$((tcolm+26))
		counter=$((counter+1))
	
		if [ $counter -lt 6 ];
		then
			trow=2
		elif [ $counter -lt 12 ];
		then
			trow=8
		elif [ $counter -lt 18 ];
		then
			trow=14
		elif [ $counter -lt 24 ];
		then
			trow=20
		elif [ $counter -ge 24 ];
		then
			trow=26
		fi

		if [ $counter = 6 ]; 
		then 
			trow=8
			tcolm=8
			sleep 1
		elif [ $counter = 12 ];
		then
			trow=14
			tcolm=8
			sleep 1
		elif [ $counter = 18 ];
		then
			trow=20
			tcolm=8
			sleep 1
		elif [ $counter = 24 ];
		then	
			trow=26
			tcolm=8
			sleep 1
		fi
	
	done
	
	tput setab 0
	tput setaf 7
	
	tput cup 32 0					#top volume
	cat volume.txt | sort -k5 -n -r | head -4 | awk '{printf "\t%s %s %s %-4s %s\n", $1, $2, $3, $4, $5}'

	tput cup 32 0					#top loser
	cat loser.txt  | sort -k5 -n    | head -4 | awk '{printf "\t\t\t\t\t\t\t\t\t\t\t  %s %s %s %-4s %s\n", $1, $2, $3, $4, $5}'
	
	tput cup 32 0					#top winner
	cat winner.txt | sort -k5 -n -r | head -4 | awk '{printf "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t %s %s %s %-4s %s\n", $1, $2, $3, $4, $5}'
	
	echo >volume.txt
	echo >winner.txt
	counter=0	
	trow=2
	tcolm=8
	sleep 2
done
