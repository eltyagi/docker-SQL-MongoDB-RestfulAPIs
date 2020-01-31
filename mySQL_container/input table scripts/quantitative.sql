SELECT * FROM AFS.quantitative;

INSERT INTO `AFS`.`quantitative` (`metric`, `status`, `value`, `score`, `desc`) VALUES ('AR', 01, '42.53290543', '46.33370823', 'AR Metric');
DELETE FROM `AFS`.`quantitative` WHERE (`metric` = 'AR');

UPDATE `AFS`.`quantitative` SET `value` = '28.85324306', `score` = '80.57426726' WHERE (`metric` = 'KS');

