SELECT * FROM AFS.reportValues;

INSERT INTO `AFS`.`reportValues` (`valueId`, `valueName`, `value`, `createdAt`, `createdBy`, `updatedAt`, `updatedBy`) VALUES ('1', 'abcd', '1.656', '2019-10-2', '1', '2019-11-3', '1');
INSERT INTO `AFS`.`reportValues` (`valueId`, `valueName`, `value`, `createdAt`, `createdBy`, `updatedAt`, `updatedBy`) VALUES ('2', 'efgh', '3', '2019-12-1', '1', '2019-12-3', '1');

DELETE FROM `AFS`.`reportValues` WHERE (`valueId` = '2');

UPDATE `AFS`.`reportValues` SET `valueId` = '2', `valueName` = 'abce', `value` = '23' WHERE (`valueId` = '1');

