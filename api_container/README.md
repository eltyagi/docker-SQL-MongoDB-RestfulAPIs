# User Management APIs

set up the database by forward engineering the MySQL design.

create .Renviron file and paste the followning:
  
```{r}
dev.host="hostname"
dev.port="3306"
dev.db="db_name"
dev.uname="dbusdername"
dev.pwd="dbpassword"
dev.drv="com.mysql.cj.jdbc.Driver"
dev.clspath="./drivers/MySql/mysql-connector-java-8.0.17.jar"
dev.urn="jdbc:mysql://"
dev.ubase="userbase"
dev.usersettings="userSettings"
dev.uroles="userRoles"
dev.rolemaster="roleMaster"
dev.roledetails="roleDetails"
dev.actmaster="actionMaster"
dev.uvalid="valid"
dev.log.url="mongodb://username:password@hostname:27017"
dev.log.db="log.db.username"
dev.user.log="log.db.password"
dev.override.log="log.db.override.log"
dev.jwt.secret="ThisIsAGoodSecretIGuess@"
dev.reset.password="pleasechangeyourpassword"
dev.user.mgt.action.name="user_mgt"
```

This is your configuration file. Edit as per your requirement

Go to sources and edit userAPI.R

```
# adding db info to .obj.env
```

to best suite the .Renviron file

Wola! you can run the Plumber.R file
