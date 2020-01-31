SELECT * FROM AFS.vatStatus;

INSERT INTO `AFS`.`vatStatus` (`metrics`, `score`, `status`) VALUES ('Lat_exp', '67', 01);
INSERT INTO `AFS`.`vatStatus` (`metrics`, `score`, `status`) VALUES ('qoq_exp', '58', 1);

DELETE FROM `AFS`.`vatStatus` WHERE (`metrics` = 'qoq_exp');

UPDATE `AFS`.`vatStatus` SET `metrics` = 'lat_ecl', `score` = '50' WHERE (`metrics` = 'Lat_exp');


