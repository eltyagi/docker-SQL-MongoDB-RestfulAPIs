source("./sources/libraries.R")
source("./sources/functions.R")
source("./sources/envAndDb.R")
pr <- plumb("./sources/userAPIs.R")

pr$registerHook("exit", function(){
  dbDisconnect(user.db)
  print("Shutting down APIs...")
})


pr$run(port = 3005)
