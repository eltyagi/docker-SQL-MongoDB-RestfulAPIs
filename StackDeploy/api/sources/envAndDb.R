# envAndDb.R

#' @author "Revanth Nemani <raynemani@gmail.com>"
#'


# New Environments--------------------------------

# boolean environment
.bit.env <<- new.env()

# object Names environment
.obj.env <<- new.env()

# db information environment
.db.info.env <<- new.env()

# JWT Environment
.jwt.info.env <<- new.env()

# variables------------------------------------------------------------

## sourcing environment variables
.api.env <- .GetEnvironmentVars()

## adding db info to .obj.env
.db.info.env$host <- .api.env$dev.host
.db.info.env$port <- .api.env$dev.port
.db.info.env$service <- .api.env$dev.db
.db.info.env$uname <- .api.env$dev.uname
.db.info.env$pwd <- .api.env$dev.pwd
.db.info.env$drv <- .api.env$dev.drv
.db.info.env$clspath <- .api.env$dev.clspath
.db.info.env$urn <- .api.env$dev.urn
.db.info.env$userbase <- .api.env$dev.ubase
.db.info.env$user.settings <- .api.env$dev.usersettings
.db.info.env$user.roles <- .api.env$dev.uroles
.db.info.env$role.master <- .api.env$dev.rolemaster
.db.info.env$role.details <- .api.env$dev.roledetails
.db.info.env$action.master <- .api.env$dev.actmaster
.db.info.env$user.valid <- .api.env$dev.uvalid
.db.info.env$log.url <- .api.env$dev.log.url
.db.info.env$log.db <- .api.env$dev.log.db
.db.info.env$user.log <- .api.env$dev.user.log
.db.info.env$overrides.log <- .api.env$dev.override.log


