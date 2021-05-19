#!/bin/awk
{
  a[$2]=$1; 
  c[$2"|"$3]=$3; 
  d[$2"|"$4]=$4; 
}END{
 for(i in a){
  tc=""; 
  for(j in c){ 
    split(j,t,"|"); 
    if (t[1]==i) if(tc=="") tc=t[2]; else tc=tc", "t[2];
  };
  td=""; 
  for(j in d){ 
    split(j,t,"|"); 
    if (t[1]==i) if(td=="") td=t[2]; else td=td", "t[2];
  };
  print a[i]"|"i"|"tc"|"td}; 
}
