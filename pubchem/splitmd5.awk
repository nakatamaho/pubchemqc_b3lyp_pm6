#!/usr/bin/awk -f
BEGIN {chunk=0; oldfilename="";}
{
  if (NF >= 2) { 
  a = substr($2,0)
  split (a,b,"/")
  gsub ("^0*", "", b[2]);

  upper = int(b[2] / 25000) * 25000 + 1 
  lower = (int(b[2] / 25000) + 1) * 25000
  _upper=sprintf("%09d", upper)
  _lower=sprintf("%09d", lower)
  filename= "compound_" _upper "_" _lower ".md5"
  print "1st" chunk,  int(b[2] / 25000), b[2] 
  if ( int(b[2] / 25000) > chunk ) { 
      close (oldfilename) ;  
      _command = sprintf ("sort -k2 %s > _%s ; mv _%s %s ", oldfilename, oldfilename, oldfilename, oldfilename);
      print _command;
      system(_command);
  } 
  chunk = int(b[2] / 25000) 
  oldfilename = filename
  gsub(".PM6.initial.",".initial.",$2);
  print $1, "" ,$2 $3 >> filename
}

}