# functions.R

#' @author "Revanth Nemani <raynemani@gmail.com>"
#'

# Functions-----------------------------------------------------------

## Get Environment Variables
.GetEnvironmentVars <- function() {
  return(as.list(Sys.getenv()))
}

## STAN
.StanGenerator <- function() {
  v <- c(sample(c(LETTERS, letters, 0:9), 8, replace = T))
  return(gsub(":", "", gsub("-", "", paste0(
    gsub(" ", "", as_datetime(now())), "UTC", paste0(v, collapse = "")
  ))))
}

## logging database setup
.ConnectToLogs <- function() {
  mongo(
    collection = .db.info.env$user.log,
    db = .db.info.env$log.db,
    url = .db.info.env$log.url
  )
}

## object Name function
.ObjectName <- function(object) {
  deparse(substitute(object))
}

## Connect to database
.ConnectToDatabase <-
  function(host = .db.info.env$host,
           port = .db.info.env$port,
           service = .db.info.env$service,
           uname = .db.info.env$uname,
           pwd = .db.info.env$pwd,
           drv = .db.info.env$drv,
           clspath = .db.info.env$clspath,
           urn = .db.info.env$urn) {
    jdri <- JDBC(drv, classPath = clspath)
    jdcon <-
      dbConnect(jdri, paste0(urn, host, ":", port, "/", service), uname, pwd)
    try(dbSendQuery(jdcon, "SELECT 1"),
        stop("can't connect"))
    message(paste0("connected to ",
                   urn,
                   host, ":",
                   port, "/",
                   service))
    return(jdcon)
  }


## List to string
.ListAsString <- function(lst) {
  return(gsub("list\\(", "", (gsub(
    "\\)", "", gsub("c\\(", "", gsub("\\\"", "", paste(lst, sep = ",")))
  ))))
}

## get userbase
.GetUser <- function() {
  userbase <- dbGetQuery(
    user.db,
    sprintf(
      "SELECT ub.ubid, firstName, lastName, username, password, startDt, expiryDt, locked, setting1, setting2, setting3, setting4, setting5, setting6, role, action FROM %s ub, %s vd, %s us, %s ur, %s rd, %s rm, %s am WHERE ub.ubid = vd.ubid AND ub.ubid = us.ubid AND ub.ubid = ur.ubid AND ur.roleid = rd.roleid AND ur.roleid = rm.roleid AND rd.actionid = am.actionid;",
      .db.info.env$userbase,
      .db.info.env$user.valid,
      .db.info.env$user.settings,
      .db.info.env$user.roles,
      .db.info.env$role.details,
      .db.info.env$role.master,
      .db.info.env$action.master
    )
  )
  userbase <- userbase[order(userbase$ubid),]
  user <- unique(userbase[, 1:8])
  roles <-
    unique(userbase[, c(1, 15)]) %>% group_by(ubid) %>% summarise(role = toString(sort(role)))
  actions <-
    unique(userbase[, c(1, 16)]) %>% group_by(ubid) %>% summarise(action = toString(sort(action)))
  res <-
    merge(merge(user, roles, all = T, by = "ubid"),
          actions,
          all = T,
          by = "ubid")
  return(res)
}

## get user details
.GetUserDetails <- function(username) {
  userbase <- dbGetQuery(
    user.db,
    sprintf(
      "SELECT ub.ubid, expiryDt, locked, role, action FROM %s ub, %s vd, %s us, %s ur, %s rd, %s rm, %s am WHERE ub.ubid = vd.ubid AND ub.ubid = us.ubid AND ub.ubid = ur.ubid AND ur.roleid = rd.roleid AND ur.roleid = rm.roleid AND rd.actionid = am.actionid AND ub.username = '%s';",
      .db.info.env$userbase,
      .db.info.env$user.valid,
      .db.info.env$user.settings,
      .db.info.env$user.roles,
      .db.info.env$role.details,
      .db.info.env$role.master,
      .db.info.env$action.master,
      username
    )
  )
  userbase <- userbase[order(userbase$ubid),]
  user <- unique(userbase[, 1:3])
  roles <-
    unique(userbase[, c(1, 4)]) %>% group_by(ubid) %>% summarise(role = toString(sort(role)))
  actions <-
    unique(userbase[, c(1, 5)]) %>% group_by(ubid) %>% summarise(action = toString(sort(action)))
  res <-
    merge(merge(user, roles, all = T, by = "ubid"),
          actions,
          all = T,
          by = "ubid")
  return(res)
}

# get usernames
.GetUserNames <- function() {
  userbase <- dbGetQuery(
    user.db,
    sprintf(
      "SELECT username FROM %s;",
      .db.info.env$userbase
    )
  )
  userbase <- userbase[order(userbase$username),]
  return(userbase)
}

# get all roles
.GetAllRoles <- function() {
  rolebase <- dbGetQuery(
    user.db,
    sprintf(
      "SELECT role FROM %s;",
      .db.info.env$role.master
    )
  )
  rolebase <- rolebase[order(rolebase$role),]
  return(rolebase)
}

# Check that it doesn't match any non-letter
.LettersOnly <- function(x) {
  !grepl("[^A-Za-z.]", x)
}

# Check that it doesn't match any non-letter except period
.LettersAndDotOnly <- function(x) {
  !grepl("[^A-Za-z.]", x)
}

# Check that it doesn't match any non-number
.NumbersOnly <- function(x) {
  !grepl("\\D", x)
}

# jwt get userid function
.GetUserIdFromJwt <- function(req) {
  # Get jwt from header
  jwt.encoded <- c(req$HTTP_CUSTOM_HEADER)
  
  # on Null return null custom header
  if (is.null(jwt.encoded)) {
    return(unbox("null custom header"))
  }
  
  # decode jwt
  jwt.decoded <-
    try(jwt_decode_hmac(jwt = jwt.encoded, secret = .jwt.info.env$secret),
        silent = T)
  
  # on jwt validation or decoding error return invalid jwt
  if (inherits(jwt.decoded, "try-error"))
  {
    return(unbox("invalid jwt"))
  }
  
  # return user id from jwt
  return(strsplit(jwt.decoded$iss, split = ", ")[[1]][1])
}

# get ubid
.GetUbid <- function(username) {
  .uid <-
    dbGetQuery(
      user.db,
      sprintf(
        "SELECT ubid FROM %s WHERE username = '%s'",
        .db.info.env$userbase,
        username
      )
    )
}

#  get user actions from ubid
.GetUserActions <- function(user.id) {
  d <- dbGetQuery(
    user.db,
    sprintf(
      "SELECT action FROM %s ur, %s rd, %s am WHERE ur.ubid = %s AND ur.roleid = rd.roleid AND rd.actionid = am.actionid;",
      .db.info.env$user.roles,
      .db.info.env$role.details,
      .db.info.env$action.master,
      user.id
    )
  )
  return(d)
}