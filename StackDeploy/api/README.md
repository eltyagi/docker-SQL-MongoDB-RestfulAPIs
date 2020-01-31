# IFRS 9 User Management APIs

set up the database by farword engineering the MySQL design.

create .Renviron file and paste the followning:
  
```{r}
prod.host="hostname"
prod.port="3306"
prod.db="db_name"
prod.uname="dbusdername"
prod.pwd="dbpassword"
prod.drv="com.mysql.cj.jdbc.Driver"
prod.clspath="./drivers/MySql/mysql-connector-java-8.0.17.jar"
prod.urn="jdbc:mysql://"
prod.ubase="userbase"
prod.usersettings="userSettings"
prod.uroles="userRoles"
prod.rolemaster="roleMaster"
prod.roledetails="roleDetails"
prod.actmaster="actionMaster"
prod.uvalid="valid"
prod.log.url="mongodb://username:password@hostname:27017"
prod.log.db="log.db.username"
prod.user.log="log.db.password"
prod.override.log="log.db.override.log"
prod.jwt.secret="ThisIsAGoodSecretIGuess@"
prod.reset.password="pleasechangeyourpassword"
prod.user.mgt.action.name="user_mgt"
```

This is your configuration file. Edit as per your requirement

Go to sources and edit userAPI.R

```
# adding db info to .obj.env
```

to best suite the .Renviron file

Wola! you can run the Plumber.R file