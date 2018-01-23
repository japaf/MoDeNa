/*
Jiri Kolar
This file depends on foamface.cmd (Load together with this script)
For example: 
	read "../se_cmd/foamface.cmd"

To analyze edge legnth distribution
ehist
*/

//edge length

ehist := {
	foamedge_mark;
	//foamedge_count defined in foamedge_mark
	define edges_length real[foamedge_count];
	local range,step,left,right, mean,minl,maxl;
	avg_elength:=0;
	local binid,bins;
	bins:=10;
	define hist integer[bins];
	edges_length:=0;
	hist:=0;
	foreach edge ee where emark > 0 do
	  { 
		edges_length[ee.emark] += ee.length;
		avg_elength+=ee.length;
	  };
	  avg_elength:=avg_elength/foamedge_count;
	  printf "avg length: %f\n",avg_elength;
	 //compute distribution	
	hist:=0;
	minl:=1e30;
	maxl:=0;
	//compute max and min length
	for (inx:=1;inx<=foamedge_count;inx+=1) {		
		if maxl<edges_length[inx] then
		{
			maxl:=edges_length[inx];
		};
		if minl>edges_length[inx] then
		{
			minl:=edges_length[inx];
		};
	};
	range:=(maxl-minl);
	step:=range/bins;
	//fill the bins
	set edge color black;
	for (inx:=1;inx<=foamedge_count;inx+=1) {
		binid:=floor((edges_length[inx]-minl)/step);
		if (binid==0) then 
		{
			binid:=1;
		};
		if (binid>bins) then 
		{
			binid:=bins;
		};
		if (binid==1) then {
			set edge color red where emark==inx;
		};
		hist[binid]+=1;
	};
	//write histogram to output
	printf "Foam edge length histogram\n";
	for (inx:=1;inx<=bins;inx+=1) {
		right:=inx*step+minl;
		left:=(inx-1)*step+minl;
		mean:=(left+right)/2;
		printf "%f - %f \t %d \n",left, right, hist[inx];
	};
}; //end edge length
