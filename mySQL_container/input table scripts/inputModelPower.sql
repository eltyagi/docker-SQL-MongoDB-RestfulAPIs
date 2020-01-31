SELECT * FROM AFS.inputModelPower;
INSERT INTO `AFS`.`inputModelPower` (`metric`, `value`, `status`, `grade`, `engStatus`) VALUES ('Heteroscedasticity', '97', 'Pass', '5', 'success');
INSERT INTO `AFS`.`inputModelPower` (`metric`, `value`, `status`, `grade`, `engStatus`) VALUES ('Normality', '90', 'Watchlist', '3', 'warning');
DELETE FROM `AFS`.`inputModelPower` WHERE (`metric` = 'Normality') and (`value` = '90');
UPDATE `AFS`.`inputModelPower` SET `metric` = 'MAPE', `value` = '95' WHERE (`metric` = 'Heteroscedasticity') and (`value` = '97');


