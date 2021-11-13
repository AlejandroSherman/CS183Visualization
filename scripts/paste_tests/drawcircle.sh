#!/bin/sh
draw_circle () {
n=8
#n=$1/11
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
      echo "     five.txt"
   fi
   for ((y=-n ;  y<=n ; y++));
   do
      d=$((x*x + y*y))
      if [ $((d-R2)) -lt 8 ] && [ $((R2-d)) -lt 8 ]
         then echo -n "*"
      else echo -n " "
      fi
   done
   echo
done
}

draw_circle
