PATH_TO_ZIP_FILE = './ships_data.zip'
data_ships <- read.csv(unzip(PATH_TO_ZIP_FILE))

dropdownServer <- function(id, path, is_zip=TRUE) { 
  moduleServer(
    id, 
    function(input, output, session) { 
      if (is_zip) { 
        df <- read.csv(unzip(path))
      } else { 
        # Assume it's csv
        df <- read.csv(path)
      }
      return(df)
    }
  )
}
