/*
Jiri Kolar
This file depends on foamface.cmd (Load together with this script)
For example: 
	read "../se_cmd/foamface.cmd"

To relax foam
usage: relax_dry
		relax_wet
*/
str := {
	set vertex x 1.05*x where x>0.5;
	set vertex x 0.95*x where x<=0.5;
	set vertex y 1.05*y where y>0.5;
	set vertex y 0.95*y where y<=0.5;
	set vertex z 1.05*z where z>0.5;
	set vertex z 0.95*z where z<=0.5;	
}
con:= {
	set vertex x 1.05*x where x<0.5;
	set vertex x 0.95*x where x>=0.5;
	set vertex y 1.05*y where y<0.5;
	set vertex y 0.95*y where y>=0.5;
	set vertex z 1.05*z where z<0.5;
	set vertex z 0.95*z where z>=0.5;
}

gos:={
set facet tension area;g;u;w 1e-8;
set facet tension 1;
}
gon:={
//set body pressure 1/volume*max(bodies,volume);
set body pressure 1/pow(3/4*volume/3.14,1/3); //laplacian pressure
g;u;w 1e-8;g;
}


// different relax commands

relax_nopop:={
//pop_tri_to_edge facets;
V;
{g 10;u 2;g 10}5;
}

relax_pop_tri:={
pop_tri_to_edge facets;
V;
{g 10;u 2;g 20}5;
}

relax_pop_and_weed:={
V;
pop_tri_to_edge facets;
{g 10;u 2;w 1e-7;g 10}5;
}

relax_pop_quad:={
V;
pop_quad_to_quad facets;
{g 10;u 2;g 10}5;
}

procedure pop_tri_edge(real minval) {
pop_tri_to_edge facets where area<minval;
u 5;g 10;
}

procedure pop_quad_quad(real minval) {
pop_quad_to_quad facets where area<minval;
u 5;g 10;
}
procedure pop_edge_tri(real minval) {
pop_edge_to_tri edges where length<minval;
u 5;g 10;
}

procedure pop_edges(real minval)
{
t minval;
O;o;u 5;g 10;
}

// command is called for foam relaxing

pop_minimal_edges:= {
ehist;
pop_edge_to_tri edges where color=red;
}

set_target_vol:= {
	foreach body bb do {
	set bb.target volume;
	};
}

procedure pop_nonminimal(real minval)
{
pop_edges(minval);
pop_edge_tri(minval);
pop_quad_quad(minval);
pop_tri_to_edge facets;
u 10;g 10;
}

procedure pop_in_cascade(real minval)
{
pop_nonminimal(minval*1e-3);
pop_nonminimal(minval*1e-2);
pop_nonminimal(minval*1e-1);
pop_nonminimal(minval);
}
// na anisotropnich penach algoritmus pada
// test mensiho eps, vetsino epsrefine a min kroku
relax_dry:={
set_target_vol;
avg_elength:=0;
eps:=0.01;
epsrefine:=3;
ehist;
V;
{ehist;refine edges where length>epsrefine*avg_elength;pop_in_cascade(eps*avg_elength);u 10;g 50} 20;
u 5;
g 20;
}
// 

relax_wet:={
g 100;u;{{u;g 20}}3;
}

define facet attribute removeface integer
procedure marksmallfacets (real area_th)
{
	foamface_mark;
	foamedge_mark;
	set facet color white;
	set facet removeface 0;
    for ( inxx := 1 ; inxx <= foamface_count; inxx += 1) {		
		evalence:=0;
		face_area:=0;
		foreach facet ff where fmark=inxx do{
			foreach ff.edges ee where emark>0 do {
			evalence+=1;
			};
			face_area+=ff.area;
		};
		if evalence<=4 and face_area<area_th then {
		printf "%d %f \n",evalence,face_area;
		foreach facet ff where fmark=inxx do{
			foreach ff.edges ee do {
			//printf "edge id %d emark %d\n",ee.id,ee.emark;
			//printf "face id %d\n",ff.id;
			set facet[ff.id] color green;
			};
		};
		foreach facet ff where fmark=inxx do{
			ff.removeface:=1;
			break;
		};		
		};    
    };
}

removesmall4edges:={
	foreach facet ff where removeface>0 do {
	pop_quad_to_quad ff;
	}
}

gogo:={
relax_dry;
marksmallfacets(0.001);
removesmall4edges;
relax_dry;
}
