


*drop airport and not in chicago 
drop if inlist(stationname , "O'Hare Airport", "Midway Airport")
drop if inlist(longname, "Oak Park-Lake", "Harlem-Congress", "Ridgeland", "Harlem-Lake" ,"Austin-Congress")
drop if inlist(longname, "Oak Park-Congress" ,"Forest Park" , "Rosemont", "Dempster-Skokie", "Oakton-Skokie" )
drop if inlist(longname, "South Boulevard" , "Davis" ,"Main", "Dempster", "Noyes", "Central-Evanston")
drop if inlist(longname, "Foster" , "Linden" , "54th/Cermak" , "Cicero-Douglas")
drop if stationname =="Homan"
drop if stationname =="Washington/State"
drop if line_type=="Purple" | line_type=="Yellow" 
drop if inlist( stat_id, 40200,40500, 40640, 41580, 40410, 41700)


replace longname ="Madison/Wabash" if stationname =="Madison/Wabash"
replace longname ="Randolph/Wabash" if stationname =="Randolph/Wabash"
replace line_type ="Center" if inlist(stationname, "Madison/Wabash", "Randolph/Wabash")




