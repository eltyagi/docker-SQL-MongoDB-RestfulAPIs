-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema AFS
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema AFS
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `AFS` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `AFS` ;

-- -----------------------------------------------------
-- Table `AFS`.`actionMaster`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`actionMaster` (
  `actionid` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `action` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`actionid`),
  UNIQUE INDEX `action` (`action` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `AFS`.`roleMaster`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`roleMaster` (
  `roleid` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `role` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`roleid`),
  UNIQUE INDEX `role` (`role` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `AFS`.`roleDetails`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`roleDetails` (
  `roleid` TINYINT UNSIGNED NOT NULL,
  `actionid` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`roleid`, `actionid`),
  INDEX `actionid` (`actionid` ASC) VISIBLE,
  CONSTRAINT `roleDetails_ibfk_1`
    FOREIGN KEY (`roleid`)
    REFERENCES `AFS`.`roleMaster` (`roleid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `roleDetails_ibfk_2`
    FOREIGN KEY (`actionid`)
    REFERENCES `AFS`.`actionMaster` (`actionid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `AFS`.`userbase`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`userbase` (
  `ubid` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `firstName` VARCHAR(45) NOT NULL,
  `lastName` VARCHAR(45) NOT NULL,
  `username` VARCHAR(20) NOT NULL,
  `password` VARCHAR(128) NOT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ubid`),
  UNIQUE INDEX `username` (`username` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 134
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `AFS`.`userRoles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`userRoles` (
  `ubid` TINYINT UNSIGNED NOT NULL,
  `roleid` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`ubid`, `roleid`),
  INDEX `roleid` (`roleid` ASC) VISIBLE,
  CONSTRAINT `userRoles_ibfk_1`
    FOREIGN KEY (`ubid`)
    REFERENCES `AFS`.`userbase` (`ubid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `userRoles_ibfk_2`
    FOREIGN KEY (`roleid`)
    REFERENCES `AFS`.`roleMaster` (`roleid`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `AFS`.`userSettings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`userSettings` (
    `ubid` TINYINT UNSIGNED NOT NULL,
    `setting1` BIT NOT NULL DEFAULT 0,
    `setting2` BIT NOT NULL DEFAULT 0,
    `setting3` BIT NOT NULL DEFAULT 0,
    `setting4` BIT NOT NULL DEFAULT 0,
    `setting5` BIT NOT NULL DEFAULT 0,
    `setting6` BIT NOT NULL DEFAULT 0,
    `setting7` BIT NOT NULL DEFAULT 0,
    PRIMARY KEY (`ubid`),
    CONSTRAINT `userSettings_ibfk_1` FOREIGN KEY (`ubid`)
        REFERENCES `AFS`.`userbase` (`ubid`)
        ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB DEFAULT CHARACTER SET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;


-- -----------------------------------------------------
-- Table `AFS`.`valid`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`valid` (
    `ubid` TINYINT UNSIGNED NOT NULL,
    `startDt` DATETIME NOT NULL,
    `expiryDt` DATETIME NOT NULL,
    `locked` BIT NOT NULL DEFAULT 0,
    PRIMARY KEY (`ubid`),
    CONSTRAINT `valid_ibfk_1` FOREIGN KEY (`ubid`)
        REFERENCES `AFS`.`userbase` (`ubid`)
        ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB DEFAULT CHARACTER SET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;


-- -----------------------------------------------------
-- Table `AFS`.`quantitativeMetrics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`quantitativeMetrics` (
    `rating` TINYINT NOT NULL,
    `accounts` INT NULL,
    `bads` INT NULL,
    `goods` INT NULL
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `AFS`.`reportValues`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`reportValues` (
  `valueId` SMALLINT UNSIGNED NOT NULL,
  `valueName` VARCHAR(255) NULL,
  `value` DECIMAL NULL,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdBy` TINYINT UNSIGNED NOT NULL,
  `updatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updatedBy` TINYINT UNSIGNED NOT NULL,
  PRIMARY KEY (`valueId`),
  INDEX `FK_CREATE_idx` (`createdBy` ASC) VISIBLE,
  INDEX `fk_update_idx` (`updatedBy` ASC) VISIBLE,
  INDEX `valueTypeIndex` (`valueName` ASC) VISIBLE,
  CONSTRAINT `fk_create`
    FOREIGN KEY (`createdBy`)
    REFERENCES `AFS`.`userbase` (`ubid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_update`
    FOREIGN KEY (`updatedBy`)
    REFERENCES `AFS`.`userbase` (`ubid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `AFS`.`gant`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`gant` (
    `task` VARCHAR(50) NOT NULL,
    `start` TIMESTAMP NULL,
    `duration` INT NULL,
    `resource` VARCHAR(50) NULL,
    PRIMARY KEY (`task`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `AFS`.`inputModelPower`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`inputModelPower` (
    `metric` VARCHAR(45) NOT NULL,
    `value` TINYINT NOT NULL,
    `status` VARCHAR(20) NULL,
    `grade` TINYINT(1) NULL,
    `engStatus` VARCHAR(20) NULL,
    PRIMARY KEY (`metric` , `value`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `AFS`.`quantitative`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`quantitative` (
  `metric` VARCHAR(45) NOT NULL,
  `status` BIT(1) NULL,
  `value` FLOAT NULL,
  `score` FLOAT NULL,
  `desc` VARCHAR(250) NULL,
  PRIMARY KEY (`metric`),
  UNIQUE INDEX `Quantitativecol_UNIQUE` (`desc` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `AFS`.`quantitativeMetrics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`quantitativeMetrics` (
    `rating` TINYINT NOT NULL,
    `accounts` INT NULL,
    `bads` INT NULL,
    `goods` INT NULL
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `AFS`.`reportStatus`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`reportStatus` (
    `component` VARCHAR(50) NOT NULL,
    `status` BIT(1) NULL,
    PRIMARY KEY (`component`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `AFS`.`vatStatus`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`vatStatus` (
    `metrics` VARCHAR(45) NOT NULL,
    `score` TINYINT NULL,
    `status` BIT(1) NULL,
    PRIMARY KEY (`metrics`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `AFS`.`dataShiny`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`dataShiny` (
    `ques` VARCHAR(45) NOT NULL,
    `input` BIT(4) NULL,
    `entered` BIT(1) NULL,
    `fullQues` VARCHAR(250) NULL,
    `analysis` VARCHAR(250) NULL,
    `res1` VARCHAR(250) NULL,
    `res2` VARCHAR(250) NULL,
    `res3` VARCHAR(250) NULL,
    PRIMARY KEY (`ques`)
)  ENGINE=INNODB;


-- -----------------------------------------------------
-- Table `AFS`.`secondQuarters`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `AFS`.`secondQuarters` (
    `quarter` TINYINT NOT NULL,
    `dealNo` BIGINT NOT NULL,
    `onBalanceExposure` FLOAT NULL,
    `limit` FLOAT NULL,
    `provision` FLOAT NULL,
    `collateral` FLOAT NULL,
    `custCode` INT NULL,
    `baseFullLoss` FLOAT NULL,
    `upturnFullLoss` FLOAT NULL,
    `downturnFullLoss` FLOAT NULL,
    `wgtFullLoss` FLOAT NULL,
    `ammortizeType` VARCHAR(50) NULL,
    `offBalExposure` FLOAT NULL,
    `onBalEcl` FLOAT NULL,
    `offBalEcl` FLOAT NULL,
    PRIMARY KEY (`quarter` , `dealNo`)
)  ENGINE=INNODB;

USE `AFS` ;

-- -----------------------------------------------------
-- procedure CreateUserProcedure
-- -----------------------------------------------------

DELIMITER $$
USE `AFS`$$
CREATE DEFINER=`afs`@`%` PROCEDURE `CreateUserProcedure`(IN fName VARCHAR(45),
IN lName VARCHAR(45),
IN uname VARCHAR(20),
IN pwd VARCHAR(128),
IN exp DATETIME)
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN
	DECLARE uid TINYINT UNSIGNED;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;  -- rollback any error in the transaction
    END;

    START TRANSACTION;
    -- 1. inserting user in userbase
	INSERT
	INTO userbase (`firstName`, `lastName`, `username`, `password`)
	VALUES (fName, lName, uname, pwd);

	-- 2. selecting the ubid auto created in database
	SELECT ubid
	INTO uid
	FROM userbase
	where userbase.username = uname;

	-- 3. inserting ubid into user settings
	INSERT
	INTO userSettings(`ubid`)
	VALUES(uid);

	-- 4. inserting ubid and the user's expiry date into valid
	INSERT
	INTO valid(`ubid`, `expiryDt`)
	VALUES(uid, exp);

    -- 5. inserting ubid with viewer role in userRoles
    INSERT
    INTO userRoles(`ubid`)
    VALUES(uid);

	COMMIT;
END$$

DELIMITER ;

CREATE USER 'afs'@'%' IDENTIFIED BY 'Afs@2019';
GRANT ALL PRIVILEGES ON AFS.* TO 'afs'@'%';

FLUSH PRIVILEGES;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `AFS`.`userbase`
-- -----------------------------------------------------
START
TRANSACTION;
USE `AFS`;
INSERT INTO `AFS`.`userbase` (`ubid`, `firstName`, `lastName`, `username`, `password`, `createdAt`, `updatedAt`) 
VALUES
(1, 'Root', 'User', 'root.user', '$7$C6..../....Pvkt2hWDcoH5ggE/lPHceXgd5J2gOxNEG.I1JlsNHg9$Rua8/fe5Jh/n3k8qW/KJCaaV5GbwlnCmMX5viLoek61', DEFAULT, DEFAULT);

COMMIT;

-- -----------------------------------------------------
-- Data for table `AFS`.`roleMaster`
-- -----------------------------------------------------
START
TRANSACTION;
USE `AFS`;
INSERT INTO `AFS`.`roleMaster`
(`roleid`, `role`) 
VALUES
(1, 'maker');
INSERT INTO `AFS`.`roleMaster`
(`roleid`, `role`) VALUES
(2, 'approver');
INSERT INTO `AFS`.`roleMaster`
(`roleid`, `role`) VALUES
(3, 'supervisor');
INSERT INTO `AFS`.`roleMaster`
(`roleid`, `role`) VALUES
(4, 'audit');
INSERT INTO `AFS`.`roleMaster`
(`roleid`, `role`) VALUES
(5, 'admin');
INSERT INTO `AFS`.`roleMaster`
(`roleid`, `role`) VALUES
(6, 'viewer');

COMMIT;


-- -----------------------------------------------------
-- Data for table `AFS`.`userRoles`
-- -----------------------------------------------------
START TRANSACTION;
USE `AFS`;
INSERT INTO `AFS`.`userRoles`
(`ubid`, `roleid`) VALUES
(1, 1);
INSERT INTO `AFS`.`userRoles`
(`ubid`, `roleid`) VALUES
(1, 2);
INSERT INTO `AFS`.`userRoles`
(`ubid`, `roleid`) VALUES
(1, 3);
INSERT INTO `AFS`.`userRoles`
(`ubid`, `roleid`) VALUES
(1, 4);
INSERT INTO `AFS`.`userRoles`
(`ubid`, `roleid`) VALUES
(1, 5);
INSERT INTO `AFS`.`userRoles`
(`ubid`, `roleid`) VALUES
(1, 6);

COMMIT;


-- -----------------------------------------------------
-- Data for table `AFS`.`actionMaster`
-- -----------------------------------------------------
START TRANSACTION;
USE `AFS`;
INSERT INTO `AFS`.`actionMaster`
(`actionid`, `action`) VALUES
(1, 'input');
INSERT INTO `AFS`.`actionMaster`
(`actionid`, `action`) VALUES
(2, 'approve');
INSERT INTO `AFS`.`actionMaster`
(`actionid`, `action`) VALUES
(3, 'change');
INSERT INTO `AFS`.`actionMaster`
(`actionid`, `action`) VALUES
(4, 'run');
INSERT INTO `AFS`.`actionMaster`
(`actionid`, `action`) VALUES
(5, 'logs');
INSERT INTO `AFS`.`actionMaster`
(`actionid`, `action`) VALUES
(6, 'test');
INSERT INTO `AFS`.`actionMaster`
(`actionid`, `action`) VALUES
(7, 'user_mgt');
INSERT INTO `AFS`.`actionMaster`
(`actionid`, `action`) VALUES
(8, 'reports');

COMMIT;


-- -----------------------------------------------------
-- Data for table `AFS`.`roleDetails`
-- -----------------------------------------------------
START TRANSACTION;
USE `AFS`;
INSERT INTO `AFS`.`roleDetails`
(`roleid`, `actionid`) VALUES
(1, 1);
INSERT INTO `AFS`.`roleDetails`
(`roleid`, `actionid`) VALUES
(1, 4);
INSERT INTO `AFS`.`roleDetails`
(`roleid`, `actionid`) VALUES
(2, 2);
INSERT INTO `AFS`.`roleDetails`
(`roleid`, `actionid`) VALUES
(3, 3);
INSERT INTO `AFS`.`roleDetails`
(`roleid`, `actionid`) VALUES
(4, 5);
INSERT INTO `AFS`.`roleDetails`
(`roleid`, `actionid`) VALUES
(4, 6);
INSERT INTO `AFS`.`roleDetails`
(`roleid`, `actionid`) VALUES
(5, 7);
INSERT INTO `AFS`.`roleDetails`
(`roleid`, `actionid`) VALUES
(6, 8);

COMMIT;


-- -----------------------------------------------------
-- Data for table `AFS`.`valid`
-- -----------------------------------------------------
START TRANSACTION;
USE `AFS`;
INSERT INTO `AFS`.`valid`
(`ubid`, `startDt`, `expiryDt`, `locked`) VALUES
(1, '2019-11-20 00:00:00', '2099-12-31 00:00:00', 0);

COMMIT;

-- -----------------------------------------------------
-- Data for table `AFS`.`userSettings`
-- -----------------------------------------------------
START
TRANSACTION;
USE `AFS`;
INSERT INTO `AFS`.`userSettings`
(`ubid`, `setting1`, `setting2`, `setting3`, `setting4`, `setting5`, `setting6`, `setting7`) VALUES
(1, 0, 0, 0, 0, 0, 0, 0);

COMMIT;