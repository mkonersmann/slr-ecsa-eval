#!/bin/awk
{
  a[$2]=$1; 
  c[$2"|"$3]=$3; 
  d[$2"|"$4]=$4; 
  e[$2"|"$5]=$5; 
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
  te=""; 
  for(j in e){ 
    split(j,t,"|"); 
    if (t[1]==i) if(te=="") te=t[2]; else te=te", "t[2];
  };  
  print a[i]";"i";"tc";"td";"te}; 
}
