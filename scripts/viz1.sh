#!/bin/bash
#sizeinfo=$( cat find.txt | awk '{print $5}' )
#locationinfo=$( cat find.txt | awk -F/ 'OFS="/" {print $3, $4}' )
#allinfo=$( cat find.txt | awk -F'[ /]' 'OFS="/" {print $5, $(NF-1), $(NF)}' )

allinfo=$( cat find.txt | awk -F'[ /]' 'OFS="/" {print $5, $(NF-1), $(NF)}' | sort -nrk1 ) #collect all info from find.txt file and sort the data by filesize
parentinfo=$( cat find.txt | awk -F'[ /]' '{print $(NF-1)}' ) #store parent or folder information on it's own
pinfo=$( awk 'BEGIN{ORS=" "}{for (i=1;i<=NF; i++)a[$i]++} END {for (i in a) print i}' <<< "$parentinfo " ); #remove duplicates from parent folders and attempt to keep relative order
#pinfo=$( awk 'BEGIN{RS=ORS=" "}{if (a[$0] == 0){ a[$0] += 1; print $0}}' <<< $parentinfo );
folder=$"temp_files/"; #declare folder path
#folde=$"./temp_files/";

make_rectangle () { #function to draw parent folder rectangle
   #echo "Current Parent folder is: $1"
   rows=4 #set row number
   cols=44 #set column number
   for (( i = 1; i <= rows; i++ )) #rectangle drawing algorithm
   do
     if (( i == rows/2))
     then
         echo "    Current folder is: $1"  #display the current folder
     fi
     for(( j = 1; j <= cols; j++ ))
     do
        if (( i == 1 || i == rows || j == 1 || j == cols ))
        then
            echo -n "*"
         else
            echo -n " "
         fi
      done
      echo
   done
}

draw_circle () { #function to draw file circle
#n=3 
n=$1/11 #set the scale of the circles here
tol=$n
if (( n < 4 )) #begin ceiling and floor check
then
  n=4
fi
if (( n > 18 ))
then
   n=18
fi
R2=$((n*n)) #set R2

spaces=$""
if (( n <= 4 )) #determine spacing and circle tolerance based on filesize
then
  spaces=$""
  tol=5
elif (( n <= 5 ))
then
  spaces=$"  "
  tol=6
elif (( n <= 8 ))
then
  spaces=$"   " 
  tol=8
elif (( n <= 10 ))
then 
  spaces=$"     "
  tol=10 
elif (( n <= 12 ))
then 
  spaces=$"       " 
  tol=12
elif (( n <= 14 ))
then
  spaces=$"         " 
  tol=14
elif (( n <= 16 ))
then
  spaces=$"            " 
  tol=16
elif (( n <= 18 ))
then
  spaces=$"             " 
  tol=18
fi

for(( x=-n ; x<=n ; x+=2 )) #circle drawing algorithm
do
  if (( x == 0 || x == 1 ))
  then
      #echo "   message" 
      #echo "    $2"
      echo "$spaces$2$spaces" #dynamic filename display
  fi
  for ((y=-n ; y<=n ; y++));
  do
      d=$((x*x + y*y))
      if [ $((d-R2)) -lt $tol ] && [ $((R2-d)) -lt $tol ] #tolerance check
         then echo -n "*"
      else echo -n " "
      fi
      #if (( y == 0 && x == 1 ))
      #then
      #    echo "message"
      #fi
  done
  echo
done
}

push_queue(){ #queue semantics
   element_to_store="$1"
   queue+=($element_to_store)
}

pop_queue(){
   args=${queue[0]}
   queue=("${queue[@]:1}")
}

declare -a queue #create queue
qsize=0 #save size of queue
largest=0 #save the largest filesize for one line

echo "Welcome to our in-terminal visualization program"
echo " " 
echo "Here you will visually see the location and size of files housed in the desired directory depicted  as differently sized circles"
echo " "
#echo "Press any key to begin"
read -p "Press any key to begin"
echo " "
for PARENT in $pinfo #iterate through all parent folders
do 
   #echo "Current Parent folder is: $PARENT"
   make_rectangle "$PARENT"
   echo "Generating temp drawing files"
   for INFO in $allinfo #this loop creates the circle files paste will use
   do 
      #echo "$INFO"
      size=$( echo "$INFO" | awk -F/ '{print $1}' ) #get file size
      #parent=$( echo "$INFO" | awk -F/ '{print $2}' )
      file=$( echo "$INFO" | awk -F/ '{print $3}' ) #get file name
      createfile="$folder$file" #generate filename for temp_files
      #prefile=${file%[0-9]*.*}
      #if [[ $PARENT == *"$prefile"* ]];
      if [[ $INFO == *"$PARENT"* ]]; #we found a file inside of this folder
      then
         #echo "$file here of size $size."
         draw_circle "$size" "$file" > "$createfile" #draw circle and store in temp file
         #echo "file to create is : $createfile"
      fi
   done
   #read -p "Hit any key to continue."
   #string=$""
   for INF in $allinfo #this loop performs the paste commands
   do 
      siz=$( echo "$INF" | awk -F/ '{print $1}' ) #again store file size
      fil=$( echo "$INF" | awk -F/ '{print $3}' ) #again store file name
      createfil="$folder$fil" #again generate temp file name
      if [[ $INF == *"$PARENT"* ]]; #we found the file again
      then
          #string+=$( echo "$createfil "  )
          push_queue "$createfil" #push this temp file onto the queue
          ((qsize++)) #increment queue size
          if [ "$siz" -gt "$largest" ] #check if filesize is bigger than previously found value
          then
              largest=$siz #store new largest filesize
          fi
      fi
   done #at this point the queue is prepared
   
   scaled=$largest/11 #here we utilize the same filesize scale as the draw circle function does
   upper=2 #give upper ceiling a default value of 2
   if (( scaled < 4 )) #bounds check
   then
      scaled=4
   fi
   if (( scaled > 18 ))
   then 
      scaled=18
   fi
   if (( scaled <= 4 )) #set upper ceiling based on filesize
   then 
      upper=6
   elif (( scaled <= 8 ))
   then 
      upper=5
   elif (( scaled <= 12 ))
   then 
      upper=4
   elif (( scaled <= 14 ))
   then 
      upper=3
   elif (( scaled <= 18 ))
   then 
       upper=2
   fi
   #string=$""
   while [ "$qsize" -gt 0 ] #only keep perfoming paste commands while queue has values
   do 
      qiter=0 #initialize iterator 
      string=$"" #initialize command to pass to paste
      while [ "$qiter" -lt "$upper" ] #while below our upper ceiling for this line
      do
         if [ "$qsize" -gt 0 ] #check there are still values on queue
         then
            string+=$( echo "${queue[0]} " ) #add first value in our queue to our paste command
            pop_queue #remove first value in queue
            ((qsize--)) #decrement queue size
         fi
         ((qiter++)) #increment iterator
      done
      paste ${string::-1} #perform current paste
      read -p "Press any key to continue to the next display." 
      echo " "
   done

   #echo "Now we pass this to paste: $string" #old semantics
   #cat ${string::-1}
   #paste ${string::-1}
   #read -p "Press any key to continue to the next display."
done
echo "Removing temp files"
echo " "
rm temp_files/*.txt #remove .txt temp files
echo "Done" 
#draw_circle
