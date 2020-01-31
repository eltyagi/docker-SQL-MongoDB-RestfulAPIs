SELECT * FROM AFS.gant;
INSERT INTO `AFS`.`gant` (`task`, `start`, `duration`, `resource`) VALUES ('Staging', '2017-10-22', '28', 'Mahmoud');
UPDATE `AFS`.`gant` SET `task` = 'Staging' WHERE (`task` = 'Report Generation');
UPDATE `AFS`.`gant` SET `start` = '2017-12-11 00:00:00', `duration` = '24', `resource` = 'Bob' WHERE (`task` = 'Staging');
DELETE FROM `AFS`.`gant` WHERE (`task` = 'Staging');




