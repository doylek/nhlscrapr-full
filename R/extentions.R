create_nhl_db(db_folder='db') {
  suppressWarnings(dir.create(db_folder))
  con <- dbConnect(SQLite(),'db/nhl_db') # RWC
}

update_season_db <- function(grand.data) {
  
  con <- dbConnect(SQLite(),'db/nhl_db') # RWC
  
  seasons <- unique(grand.data$season)
  
  ## clear all games from db for this season
  message("Deleting previous data from this season.")
  delete_statement <- paste0("delete from game_events where season = '",seasons,"'")
  dbGetQuery(con, delete_statement)
  
  ## write the grand.data with updated games to the database
  message("Writing this season's data to database")
  dbWriteTable(con,'game_events',grand.data, append=T) # updating new games
  
  ## return games now in db
  return_statement <- paste0("select distinct gcode from game_events where season = '", seasons ,"'" )
  game_pop <- dbGetQuery(con, return_statement)
  message('Database table now contains data for following gcodes:')
  print( unique(game_pop$gcode))
  
  invisible(dbDisconnect(con))
}
retrieve_season.R <- function(season) {
  message('Connecting to database..')
  con <- dbConnect(SQLite(),'db/nhl_db', flags = SQLITE_RO)
  return_statement <- paste0("select * from game_events where season = ",season)
  data = dbGetQuery(con,return_statement) #trying again
  invisible(dbDisconnect(con))
  return(data)
}