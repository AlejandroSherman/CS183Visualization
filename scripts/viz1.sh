#!/bin/sh
#sizeinfo=$( cat find.txt | awk '{print $5}' )
#locationinfo=$( cat find.txt | awk -F/ 'OFS="/" {print $3, $4}' )
allinfo=$( cat find.txt | awk -F'[ /]' 'OFS="/" {print $5, $(NF-1), $(NF)}' )
parentinfo=$( cat find.txt | awk -F'[ /]' '{print $(NF-1)}' )
pinfo=$( awk 'BEGIN{ORS=" "}{for (i=1;i<=NF; i++)a[$i]++} END {for (i in a) print i}' <<< "$parentinfo " );
#pinfo=$( awk 'BEGIN{RS=ORS=" "}{if (a[$0] == 0){ a[$0] += 1; print $0}}' <<< $parentinfo );

make_rectangle () {
   #echo "Current Parent folder is: $1"
   rows=4
   cols=36  
   for (( i = 1; i <= rows; i++ ))
   do
     if (( i == rows/2))
     then
         echo "    Current folder is: $1"
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

draw_circle () {
#n=3
n=$1/11
if (( n < 4 ))
then
  n=4
fi
if (( n > 18 ))
then
   n=18
fi
R2=$((n*n))

for(( x=-n ; x<=n ; x+=2 ))
do
  if (( x == 0 || x == 1 ))
  then
      #echo "   message"
      echo "    $2"
  fi
  for ((y=-n ; y<=n ; y++));
  do
      d=$((x*x + y*y))
      if [ $((d-R2)) -lt 8 ] && [ $((R2-d)) -lt 8 ]
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

echo "Welcome to our terminal visualization program" #expand message once more fucntionaity is present
for PARENT in $pinfo
do 
   #echo "Current Parent folder is: $PARENT"
   make_rectangle "$PARENT"
   for INFO in $allinfo
   do 
      size=$( echo "$INFO" | awk -F/ '{print $1}' )
      #parent=$( echo "$INFO" | awk -F/ '{print $2}' )
      file=$( echo "$INFO" | awk -F/ '{print $3}' )
      #prefile=${file%[0-9]*.*}
      #if [[ $PARENT == *"$prefile"* ]];
      if [[ $INFO == *"$PARENT"* ]];
      then
         #echo "$file here of size $size."
         draw_circle "$size" "$file"
      fi
   done
   read -p "Hit any key to continue."
done
echo "Done" 
#draw_circle
