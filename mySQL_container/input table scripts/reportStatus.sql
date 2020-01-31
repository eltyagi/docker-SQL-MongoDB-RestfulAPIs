SELECT * FROM AFS.reportStatus;

INSERT INTO `AFS`.`reportStatus` (`component`, `status`) VALUES ('Qualitative', 01);
INSERT INTO `AFS`.`reportStatus` (`component`, `status`) VALUES ('Quant_static', 01);

DELETE FROM `AFS`.`reportStatus` WHERE (`component` = 'Quant_static');

UPDATE `AFS`.`reportStatus` SET `component` = 'VAT' WHERE (`component` = 'Qualitative');


