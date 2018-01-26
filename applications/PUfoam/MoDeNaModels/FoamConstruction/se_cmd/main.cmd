/*
Pavel Ferkl
Relax the structure and exit
*/
read "foamface.cmd"
read "distribution.cmd"
read "wetfoam2.cmd"
read "fe2geo.cmd"
read "relaxNE4.cmd"
connected
gogo
dmpgeo
spread := 0.2
wetfoam >>> "FoamWet.fe"
q
q