# userAPIs.R

#' @author "Revanth Nemani <raynemani@gmail.com>"
#'

## adding jwt secret info
.jwt.info.env$secret <- .api.env$dev.jwt.secret

## reset password set
.obj.env$reset.password <- .api.env$dev.reset.password

## user.mgt action
.obj.env$user.mgt.action.name <- .api.env$dev.user.mgt.action.name

## Connect to logging database
log.db <<- .ConnectToLogs()

## user database connection
user.db <<- .ConnectToDatabase()

# APIs-----------------------------------------------------------------

#* Login
#* @param stan unique identifier- 25 characters
#* @param username username for login
#* @param password password of the coresponding user for login
#* @post /user/login
function(req, res) {
  if (!exists("user.db")) {
    user.db <<- .ConnectToDatabase()
  } else {
    .ReconnectOnClose(user.db)
  }
  # Getting payload data
  payload <- fromJSON(req$postBody, flatten = T)

  # params cannot be null
  if (is.null(payload$username) |
      is.null(payload$password) | is.null(payload$stan)) {
    res$status <- 400 # Bad Request
    return(unbox("params cannot be null"))
  }

  # param validation - prevent injection
  if (!.LettersAndDotOnly(payload$username)) {
    res$status <- 400 # Bad Request
    return(unbox("username can only contain alphabets and period."))
  }

  # params should be within length limits - prevent DOS and data insert errors
  if (nchar(payload$username) > 20 |
      nchar(payload$username) <= 6 |
      nchar(payload$password) <= 6 |
      nchar(payload$password) > 128 | nchar(payload$stan) != 25) {
    res$status <- 400 # Bad Request
    return(list(
      "arguments are not in length limits",
      data.frame("6<=username=>20",
                 "6<=Password<=128",
                 "stan=25")
    ))
  }

  # Just assigning a few variables for ease
  .username <- as.character(payload$username)
  .stan <- payload$stan
  .user.details <-
    dbGetQuery(
      user.db,
      sprintf(
        "SELECT ub.ubid, ub.username, password, startDt, expiryDt, locked FROM %s ub, %s vd WHERE username = '%s' AND ub.ubid = vd.ubid;",
        .db.info.env$userbase,
        .db.info.env$user.valid,
        .username
      )
    )

  # username doesn't exist
  if (nrow(.user.details) == 0) {
    res$status <- 404  # Not found
    return(unbox("username doesn't exist"))
  }

  # user is locked
  if (.user.details$locked != 0) {
    res$status <- 409  # conflict
    return(unbox(paste0(
      .user.details$username, " is locked from login"
    )))
  }

  # userID has expired
  if (.user.details$startDt > today() |
      .user.details$expiryDt < today()) {
    res$status <- 409  # conflict
    return(unbox(
      paste0(
        .user.details$username,
        " is not valid according to the start and expiry date. Please contact your IT Department"
      )
    ))
  }

  # matching password
  password.match <-
    password_verify(as.character(.user.details$password),
                    as.character(payload$password))

  # on password match get actions, encode username and roles in a jwt token
  if (password.match == T) {
    actions <- dbGetQuery(
      user.db,
      sprintf(
        "SELECT action FROM %s ur, %s rd, %s am WHERE ur.ubid = %s AND ur.roleid = rd.roleid AND rd.actionid = am.actionid;",
        .db.info.env$user.roles,
        .db.info.env$role.details,
        .db.info.env$action.master,
        .user.details$ubid
      )
    )
    payload <- toString(c(.user.details$ubid, actions$action))
    key <- charToRaw(.jwt.info.env$secret)
    jwt <- jwt_encode_hmac(jwt_claim(payload), secret = key)
    payload <- data.frame(stan = .stan,
                          login = "success",
                          token = jwt)
    log.db$insert(list(
      stan = .stan,
      action = sprintf("Login with username: %s", .username),
      By.ubid = .user.details$ubid,
      on = now()
    ))
    res$status <- 200 # OK
    return(payload)
  } else {
    # On password match fail, reject
    res$status <- 400 # Bad Request
    return(unbox("Invalid Password"))
  }
}

#* Create user
#* @param stan unique identifier- 25 characters
#* @param firstName First Name of the user to create
#* @param lastName Last name of the user to create
#* @param username unique username to be given to the user
#* @param password password for the user to be created
#* @param expiryDt expiry date of the user to be created
#* @post /user/create
function(req, res) {
  
  # get payload data
  payload <- fromJSON(req$postBody, flatten = T)

  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)

  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }

  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }

  # check actions available for the user in the jwt
  user.actions <- .GetUserActions(user.id.from.jwt)

  # user.role should have user management action
  if (!(.obj.env$user.mgt.action.name %in% user.actions$action)) {
    msg <- "Unauthorised Access"
    res$status <- 403 # Forbidden
    return(unbox(msg))
  }

  # params cannot be null
  if (is.null(payload$username) |
      is.null(payload$firstName) |
      is.null(payload$lastName) |
      is.null(payload$password) |
      is.null(payload$expiryDt) |
      is.null(payload$stan) | is.na(payload$expiryDt)) {
    res$status <- 400 # Bad Request
    return(unbox("params cannot be null"))
  }

  # param validation - prevent injection
  if (!.LettersAndDotOnly(payload$username)) {
    res$status <- 400 # Bad Request
    return(unbox("username can only contain alphabets and period."))
  }

  if (!.LettersOnly(payload$firstName) |
      !.LettersOnly(payload$lastName)) {
    res$status <- 400 # Bad Request
    return(unbox("First name and last name can only contain alphabets"))
  }

  # params should be length limits - prevent DOS and data insert errors
  if (nchar(payload$username) > 20 |
      nchar(payload$username) <= 6 |
      nchar(payload$firstName) > 45 |
      nchar(payload$lastName) > 45 |
      nchar(payload$password) <= 6 |
      nchar(payload$password) > 128 |
      nchar(payload$expiryDt) > 21 | nchar(payload$stan) != 25) {
    res$status <- 400 # Bad Request
    return(list(
      "arguments are not in length limits",
      list(
        "firstName<=45",
        "lastName<45",
        "6<=username=>20",
        "6<=Password<=128",
        "expiryDt<=21",
        "roles<=30",
        "payload$stan=25"
      )
    ))
  }

  .username <- as.character(payload$username)
  .stan <- payload$stan
  check <-
    dbGetQuery(
      user.db,
      sprintf(
        "SELECT ubid FROM %s WHERE username = '%s';",
        .db.info.env$userbase,
        payload$username
      )
    )

  # user exists
  if (!identical(check$ubid, numeric(0))) {
    res$status <- 409 # Conflict
    return(unbox("Username already exists"))
  }

  # Create user
  dbSendUpdate(
    user.db,
    paste0(
      "CALL ", .db.info.env$service, ".CreateUserProcedure('",
      payload$firstName,
      "','",
      payload$lastName,
      "','",
      payload$username,
      "','",
      password_store(payload$password),
      "','",
      payload$expiryDt,
      "');"
    )
  )
  check <-
    dbGetQuery(
      user.db,
      sprintf(
        "SELECT ubid FROM %s WHERE username = '%s';",
        .db.info.env$userbase,
        payload$username
      )
    )
  log.db$insert(list(
    stan = .stan,
    action = sprintf(
      "Created user with ubid: %s and username: %s",
      check$ubid,
      .username
    ),
    By.ubid = user.id.from.jwt,
    on = now()
  ))
  res$status <- 201 # User Created
  return(unbox(check$ubid))
}

#* get users
#* @get /user/search
function(req, res) {
  
  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)

  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }

  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }

  # check actions available for the user in the jwt
  user.actions <- .GetUserActions(user.id.from.jwt)

  # user.role should have user management action
  if (!(.obj.env$user.mgt.action.name %in% user.actions$action)) {
    msg <- "Unauthorised Access"
    res$status <- 403 # Forbidden
    return(unbox(msg))
  }

  # Getting userbase
  log.db$insert(
    list(
      stan = .StanGenerator(),
      action = "viewed all users",
      By.ubid = user.id.from.jwt,
      on = now()
    )
  )
  res$status <- 200 # OK
  .GetUser()
}

#* Update password
#* @param stan unique identifier- 25 characters
#* @param username username for updating the password
#* @param oldPassword current password that has to be changed now
#* @param newPassword new password for the user to change to
#* @post /user/update/password
function(req, res) {
  
  # get payload data
  payload <- fromJSON(req$postBody, flatten = T)

  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)

  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }

  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }

  # params cannot be null
  if (is.null(payload$username) |
      is.null(payload$oldPassword) |
      is.null(payload$newPassword) | is.null(payload$stan)) {
    res$status <- 400 # Bad Request
    return(unbox("params cannot be null"))
  }

  # param validation - prevent injection
  if (!.LettersAndDotOnly(payload$username)) {
    res$status <- 400 # Bad Request
    return(unbox("username can only contain alphabets and period."))
  }

  # params should be within length limits - prevent DOS and data insert errors
  if (nchar(payload$username) > 20 |
      nchar(payload$username) <= 6 |
      nchar(payload$oldPassword) <= 6 |
      nchar(payload$oldPassword) > 128 |
      nchar(payload$newPassword) <= 6 |
      nchar(payload$newPassword) > 128 |
      nchar(payload$stan) != 25) {
    res$status <- 400 # Bad Request
    return(list(
      "arguments are not in length limits",
      list("6<=username=>20",
           "6<=Passwords<=128",
           "stan=25")
    ))
  }

  # Just assigning a few variables for ease
  .username <- as.character(payload$username)
  .stan <- payload$stan
  .user.details <- dbGetQuery(
    user.db,
    sprintf(
      "SELECT ub.ubid, ub.username, password FROM %s ub WHERE username = '%s';",
      .db.info.env$userbase,
      .username
    )
  )
  .old.password <- .user.details$password

  # username doesn't exist
  if (nrow(.user.details) == 0) {
    res$status <- 404 # Not found
    return(unbox("username doesn't exist"))
  }

  # jwt token user and the username supplied to change the password should match
  if (.user.details$ubid != user.id.from.jwt) {
    msg <- "Unauthorised Access"
    res$status <- 403 # Forbidden
    return(unbox(msg))
  }

  # matching password
  password.match <-
    password_verify(as.character(.old.password),
                    as.character(payload$oldPassword))

  # password not match
  if (password.match != T) {
    res$status <- 400 # Bad Request
    return(unbox("Invalid Password"))
  }

  # Old password cannot be equal to new password
  if (payload$oldPassword == payload$newPassword) {
    res$status <- 400 # Bad Request
    return(unbox("The new password cannot be the same as old password"))
  }

  dbSendUpdate(
    user.db,
    sprintf(
      "UPDATE %s SET password = '%s' WHERE ubid = %s;",
      .db.info.env$userbase,
      password_store(payload$newPassword),
      .user.details$ubid
    )
  )
  log.db$insert(list(
    stan = .stan,
    action = sprintf("Password changed for user with username: %s", .username),
    By.ubid = user.id.from.jwt,
    on = now()
  ))
  res$status <- 201 # Password updated
  return(unbox("Password Updated"))
}

#* Reset password
#* @param stan unique identifier- 25 characters
#* @param username username of the user to reset password
#* @post /user/update/password/reset
function(req, res) {
  
  # get payload data
  payload <- fromJSON(req$postBody, flatten = T)

  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)

  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }

  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }

  # check actions available for the user in the jwt
  user.actions <- .GetUserActions(user.id.from.jwt)

  # user.role should have user management action
  if (!(.obj.env$user.mgt.action.name %in% user.actions$action)) {
    msg <- "Unauthorised Access"
    res$status <- 403 # Forbidden
    return(unbox(msg))
  }

  # params cannot be null
  if (is.null(payload$username) | is.null(payload$stan)) {
    res$status <- 400 # Bad Request
    return(unbox("params cannot be null"))
  }

  # param validation - prevent injection
  if (!.LettersAndDotOnly(payload$username)) {
    res$status <- 400 # Bad Request
    return(unbox("username can only contain alphabets and period."))
  }

  # params should be within length limits - prevent DOS and data insert errors
  if (nchar(payload$username) > 20 |
      nchar(payload$username) <= 6 | nchar(payload$stan) != 25) {
    res$status <- 400 # Bad Request
    return(list(
      "arguments are not in length limits",
      list("6<=username=>20",
           "6<=Passwords<=128",
           "stan=25")
    ))
  }

  # Just assigning a few variables for ease
  .username <- as.character(payload$username)
  .stan <- payload$stan
  .user.details <- dbGetQuery(
    user.db,
    sprintf(
      "SELECT ubid FROM %s WHERE username = '%s';",
      .db.info.env$userbase,
      .username
    )
  )

  # username doesn't exist
  if (nrow(.user.details) == 0) {
    res$status <- 404 #  Not found
    return(unbox("username doesn't exist"))
  }

  dbSendUpdate(
    user.db,
    sprintf(
      "UPDATE %s SET password = '%s' WHERE ubid = %s;",
      .db.info.env$userbase,
      password_store(.obj.env$reset.password),
      .user.details$ubid
    )
  )
  log.db$insert(list(
    stan = .stan,
    action = sprintf("Password reset for user with username: %s", .username),
    By.ubid = user.id.from.jwt,
    on = now()
  ))
  res$status <- 201 #  password reset
  return(unbox("Password reset"))
}

#* Update Roles
#* @param stan unique identifier- 25 characters
#* @param username username of the user to update roles
#* @param roles roles to update. multiple roles to be seperated by a comma
#* @post /user/update/roles
function(req, res) {
  
  # get payload data
  payload <- fromJSON(req$postBody, flatten = T)

  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)

  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }

  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }

  # check actions available for the user in the jwt
  user.actions <- .GetUserActions(user.id.from.jwt)

  # user.role should have user management action
  if (!(.obj.env$user.mgt.action.name %in% user.actions$action)) {
    msg <- "Unauthorised Access"
    res$status <- 403 # Forbidden
    return(unbox(msg))
  }

  # params cannot be null
  if (is.null(payload$username) |
      is.null(payload$stan) | is.null(payload$roles)) {
    res$status <- 400 # Bad Request
    return(unbox("params cannot be null"))
  }

  # param validation - prevent injection
  if (!.LettersAndDotOnly(payload$username)) {
    res$status <- 400 # Bad Request
    return(unbox("username can only contain alphabets and period."))
  }

  # params should be within length limits - prevent DOS and data insert errors
  if (nchar(payload$username) > 20 |
      nchar(payload$username) <= 6 | nchar(payload$stan) != 25) {
    res$status <- 400 # Bad Request
    return(list(
      "arguments are not in length limits",
      list("6<=username=>20",
           "6<=Passwords<=128",
           "stan=25")
    ))
  }

  # Just assigning a few variables for ease
  .username <- as.character(payload$username)
  .stan <- payload$stan
  .roles <- strsplit(payload$roles, ", ")[[1]]

  # preparing the roles string
  find.roleids.from.db.string.parsed <-
    paste0(.roles, collapse = "', '")

  # getting roleids from db
  roleids.to.insert <- dbGetQuery(
    user.db,
    sprintf(
      "SELECT roleid FROM %s rm WHERE rm.role IN ('%s');",
      .db.info.env$role.master,
      find.roleids.from.db.string.parsed
    )
  )

  # getting the ubid of the username provided
  ubid.of.user <-
    dbGetQuery(
      user.db,
      sprintf(
        "SELECT ubid FROM %s WHERE username = '%s';",
        .db.info.env$userbase,
        .username
      )
    )$ubid %>% as.character()

  # deleting all the current roles of the user in the payload
  dbSendUpdate(
    user.db,
    sprintf(
      "DELETE FROM %s WHERE ubid = %s;",
      .db.info.env$user.roles,
      ubid.of.user
    )
  )

  # adding all of the new roles of the user in payload
  roleids.to.insert <-
    roleids.to.insert %>% transmute(ubid = ubid.of.user, roleid = roleid)
  append.table.res <-
    dbWriteTable(
      user.db,
      .db.info.env$user.roles,
      roleids.to.insert,
      append = T,
      overwrite = F
    )

  # check append table result
  if (append.table.res != T) {
    return("There could be some problem")
  }

  log.db$insert(list(
    stan = .stan,
    action = sprintf(
      "Updated roles for user with username: %s. New roles: %s",
      .username,
      payload$roles
    ),
    By.ubid = user.id.from.jwt,
    on = now()
  ))
  res$status <- 201 #  Updated roles
  return(unbox(sprintf("roles Updated for user: %s", .username)))
}

#* Lock user
#* @param stan unique identifier- 25 characters
#* @param username username of the user to lock
#* @param action valid actions are lock and unlock
#* @post /user/update/lock
function(req, res) {
  
  # get payload data
  payload <- fromJSON(req$postBody, flatten = T)

  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)

  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }

  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }

  # check actions available for the user in the jwt
  user.actions <- dbGetQuery(
    user.db,

    sprintf(
      "SELECT action FROM %s ur, %s rd, %s am WHERE ur.ubid = %s AND ur.roleid = rd.roleid AND rd.actionid = am.actionid;",
      .db.info.env$user.roles,
      .db.info.env$role.details,
      .db.info.env$action.master,
      user.id.from.jwt
    )
  )

  # user.role should have user management action
  if (!(.obj.env$user.mgt.action.name %in% user.actions$action)) {
    msg <- "Unauthorised Access"
    res$status <- 403 # Forbidden
    return(unbox(msg))
  }

  # params cannot be null
  if (is.null(payload$username) |
      is.null(payload$stan) | is.null(payload$action)) {
    res$status <- 400 # Bad Request
    return(unbox("params cannot be null"))
  }

  # param validation - prevent injection
  if (!.LettersAndDotOnly(payload$username)) {
    res$status <- 400 # Bad Request
    return(unbox("username can only contain alphabets and period."))
  }

  # params should be within length limits - prevent DOS and data insert errors
  if (nchar(payload$username) > 20 |
      nchar(payload$username) <= 6 | nchar(payload$stan) != 25) {
    res$status <- 400 # Bad Request
    return(list(
      "arguments are not in length limits",
      list("6<=username=>20",
           "6<=Passwords<=128",
           "stan=25")
    ))
  }

  if (!(payload$action %in% c("unlock", "lock"))) {
    res$status <- 400 # Bad Request
    return(unbox("the action param has invalid  actions"))
  }

  # Just assigning a few variables for ease
  .username <- as.character(payload$username)
  .stan <- payload$stan
  .ubid <- .GetUbid(.username)

  # username doesn't exist
  if (nrow(.ubid) == 0) {
    res$status <- 404  # Not found
    return(unbox("username doesn't exist"))
  }

  # execute according to action mentioned
  switch (
    payload$action,
    "lock" = dbSendUpdate(
      user.db,
      sprintf(
        "UPDATE %s SET locked = 1 WHERE ubid = %s;",
        .db.info.env$user.valid,
        .ubid
      )
    ),
    "unlock" = dbSendUpdate(
      user.db,
      sprintf(
        "UPDATE %s SET locked = 0 WHERE ubid = %s;",
        .db.info.env$user.valid,
        .ubid
      )
    ),
    return(unbox("no valid action sent"))
  )

  .post.action <-
    dbGetQuery(
      user.db,
      sprintf(
        "SELECT locked FROM %s WHERE ubid = %s;",
        .db.info.env$user.valid,
        .ubid
      )
    )

  # checking if the update was made correctly
  if (.post.action != 1 & payload$action == "lock") {
    res$status <- 500 # Internal server error
    return(unbox("Internal server error"))
  }

  # checking if the update was made correctly
  if (.post.action != 0 & payload$action == "unlock") {
    res$status <- 500 # Internal server error
    return(unbox("Internal server error"))
  }

  # assign log and final payload in case of locked
  if (.post.action == 1) {
    action.log <- sprintf("Locked user with username: %s", .username)
    final.payload <- "user locked"
  }

  # assign log and final payload in case of locked
  if (.post.action == 0) {
    action.log <- sprintf("Unlocked user with username: %s", .username)
    final.payload <- "user unlocked"
  }

  # log the action
  log.db$insert(list(
    stan = .stan,
    action = action.log,
    By.ubid = user.id.from.jwt,
    on = now()
  ))

  # set status
  res$status <- 200  # OK

  # response
  return(unbox(final.payload))
}

#* User expiry date update
#* @param stan unique identifier- 25 characters
#* @param username username of the user to update the expiry date
#* @param newExpiryDt new expiry of the user
#* @post /user/update/expiry
function(req, res) {
  
  # get payload data
  payload <- fromJSON(req$postBody, flatten = T)

  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)

  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }

  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }

  # check actions available for the user in the jwt
  user.actions <- .GetUserActions(user.id.from.jwt)

  # user.role should have user management action
  if (!(.obj.env$user.mgt.action.name %in% user.actions$action)) {
    msg <- "Unauthorised Access"
    res$status <- 403 # Forbidden
    return(unbox(msg))
  }

  # params cannot be null
  if (is.null(payload$username) |
      is.null(payload$stan) | is.null(payload$newExpiryDt)) {
    res$status <- 400 # Bad Request
    return(unbox("params cannot be null"))
  }

  # param validation - prevent injection
  if (!.LettersAndDotOnly(payload$username)) {
    res$status <- 400 # Bad Request
    return(unbox("username can only contain alphabets and period."))
  }

  # params should be within length limits - prevent DOS and data insert errors
  if (nchar(payload$username) > 20 |
      nchar(payload$username) <= 6 |
      nchar(payload$stan) != 25 |
      nchar(payload$newExpiryDt) >= 21) {
    res$status <- 400 # Bad Request
    return(list(
      "arguments are not in length limits",
      list(
        "6<=username=>20",
        "6<=Passwords<=128",
        "newExpiryDt<=21",
        "stan=25"
      )
    ))
  }

  # checking the date format of the expiry date passed
  d <-
    try(as.Date(payload$newExpiryDt, format = "%Y-%m-%d %H:%M:%S"))
  if (class(d) == "try-error" || is.na(d)) {
    res$status <- 400 # Bad Request
    return(
      unbox(
        "The date format passed was incorrect. The accepted format is: YYYY-mm-dd HH:MM:SS"
      )
    )
  }

  # Just assigning a few variables for ease
  .username <- as.character(payload$username)
  .stan <- payload$stan
  .ubid <- .GetUbid(.username)

  # username doesn't exist
  if (nrow(.ubid) == 0) {
    res$status <- 404  # Not found
    return(unbox("username doesn't exist"))
  }

  # execute according to action mentioned
  dbSendUpdate(
    user.db,
    sprintf(
      "UPDATE %s SET expiryDt = '%s' WHERE ubid = %s;",
      .db.info.env$user.valid,
      payload$newExpiryDt,
      .ubid
    )
  )

  .post.action <-
    dbGetQuery(
      user.db,
      sprintf(
        "SELECT expiryDt FROM %s WHERE ubid = %s;",
        .db.info.env$user.valid,
        .ubid
      )
    )$expiryDt

  # checking if the update was made correctly
  if (.post.action != payload$newExpiryDt) {
    res$status <- 500 # Internal server error
    return(unbox("Internal server error"))
  }

  # log the action
  log.db$insert(list(
    stan = .stan,
    action = sprintf("Changed expiry date of user with username: %s", .username),
    By.ubid = user.id.from.jwt,
    on = now()
  ))

  # set status
  res$status <- 200  # OK

  # response
  return(unbox("updated the expiry date"))
}


#* get Name of the user
#* @get /user/name
function(req, res) {
  
  
  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)
  
  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }
  
  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }
  
  .name <- dbGetQuery(
    user.db,
    sprintf(
      "SELECT CONCAT_WS(' ', firstName, lastName) AS 'name' FROM %s ub WHERE ubid = '%s';",
      .db.info.env$userbase,
      as.integer(user.id.from.jwt)
    )
  )
  res$status <- 200 # Password updated
  return(unbox(.name$name))
}

#* get usernames
#* @get /user/usernames
function(req, res) {
  
  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)
  
  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }
  
  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }
  
  # check actions available for the user in the jwt
  user.actions <- .GetUserActions(user.id.from.jwt)
  
  # user.role should have user management action
  if (!(.obj.env$user.mgt.action.name %in% user.actions$action)) {
    msg <- "Unauthorised Access"
    res$status <- 403 # Forbidden
    return(unbox(msg))
  }
  
  res$status <- 200 # OK
  .GetUserNames()
}

#* get all roles
#* @get /user/roles
function(req, res) {
  
  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)
  
  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }
  
  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }
  
  # check actions available for the user in the jwt
  user.actions <- .GetUserActions(user.id.from.jwt)
  
  # user.role should have user management action
  if (!(.obj.env$user.mgt.action.name %in% user.actions$action)) {
    msg <- "Unauthorised Access"
    res$status <- 403 # Forbidden
    return(unbox(msg))
  }
  
  res$status <- 200 # OK
  .GetAllRoles()
}

#* get user details
#* @get /user/<username>/details
function(req, res, username) {
  
  # get user id from jwt
  user.id.from.jwt <- .GetUserIdFromJwt(req)
  
  # invalidating api requests without Custom-Header
  if (user.id.from.jwt == "null custom header") {
    res$status <- 403 # forbidden
    return(unbox("Unauthorised Access"))
  }
  
  # invalid JWT
  if (user.id.from.jwt == "invalid jwt") {
    res$status <- 403 # forbidden
    return(unbox("Invalid JWT"))
  }
  
  # check actions available for the user in the jwt
  user.actions <- .GetUserActions(user.id.from.jwt)
  
  # user.role should have user management action
  if (!(.obj.env$user.mgt.action.name %in% user.actions$action)) {
    msg <- "Unauthorised Access"
    res$status <- 403 # Forbidden
    return(unbox(msg))
  }
  
  res$status <- 200 # OK
  .GetUserDetails(username)
}
