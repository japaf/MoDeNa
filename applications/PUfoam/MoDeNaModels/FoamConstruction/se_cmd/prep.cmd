/*
Pavel Ferkl
Loads all commands
Use:
    read "prep.cmd"
    gogo
    dmpgeo
*/
prep:={
    read "foamface.cmd";
    read "distribution.cmd"
    read "fe2geo.cmd"
    read "relaxNE4.cmd"
}