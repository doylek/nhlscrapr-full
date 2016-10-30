#' Create NHL database
#' 
#' IN DEVELOPMENT. Creates an SQLite database to hold nhlscrpr data. Need only run once per database instance. 
#'
#' @param db_folder Folder in which database will be created.
#'
#' @export
#'
create_nhl_db <- function(db_folder='db') {
  suppressWarnings(dir.create(db_folder))
  con <- dbConnect(SQLite(),'db/nhl_db') # RWC
}

#' Update Season in Database
#' 
#' Renews database records for specified season in database.
#' 
#' This function first removes all data from current season and then re-writes all data to database from the grand.data file. Seasons are automatically detected from the grand.data file. 
#'
#' @param grand.data Grand.data events dataframe to be written to database. 
#'
#' @return Returns list of gcodes that are held in updated database table for chosen season. 
#' @export
#'
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
#' Retrieve season
#' 
#' Retrieves a season of data from the database. 
#'
#' @param season Character. Season to extract from database, e.g. "20162017."
#'
#' @return data.frame containing data for season.  
#' @export
#'
retrieve_season <- function(season) {
  message('Connecting to database..')
  con <- dbConnect(SQLite(),'db/nhl_db', flags = SQLITE_RO)
  return_statement <- paste0("select * from game_events where season = ",season)
  data = dbGetQuery(con,return_statement) #trying again
  invisible(dbDisconnect(con))
  return(data)
}