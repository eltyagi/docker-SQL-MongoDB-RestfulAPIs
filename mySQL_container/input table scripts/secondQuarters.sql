SELECT * FROM AFS.secondQuarters;

INSERT INTO `AFS`.`secondQuarters` (`quarter`, `dealNo`, `onBalanceExposure`, `limit`, `provision`, `collateral`, `custCode`, `baseFullLoss`, `upturnFullLoss`, `downturnFullLoss`, `wgtFullLoss`, `ammortizeType`, `offBalExposure`, `onBalEcl`, `offBalEcl`) VALUES ('1', '1', '6291477.21', '8699959.963', '0', '6291477.21', '102030', '13.28496181', '5.992054618', '28.21034355', '15.63958021', 'C', '481696.5506', '14.52731997', '1.112260235');
INSERT INTO `AFS`.`secondQuarters` (`quarter`, `dealNo`, `onBalanceExposure`, `limit`, `provision`, `collateral`, `custCode`, `baseFullLoss`, `upturnFullLoss`, `downturnFullLoss`, `wgtFullLoss`, `ammortizeType`, `offBalExposure`, `onBalEcl`, `offBalEcl`) VALUES ('2', '1', '1863028.64', '0', '37260.5728', '0', '102145', '1306.720591', '664.3568254', '2473.260709', '1468.428996', 'C', '0', '1468.428996', '0');

DELETE FROM `AFS`.`secondQuarters` WHERE (`quarter` = '2') and (`dealNo` = '1');

UPDATE `AFS`.`secondQuarters` SET `quarter` = '1.02', `onBalanceExposure` = '5194860.74', `limit` = '8525960.764', `collateral` = '5194860.74', `baseFullLoss` = '23.27625622', `upturnFullLoss` = '10.49860654', `downturnFullLoss` = '49.4259352', `wgtFullLoss` = '27.40152726', `offBalExposure` = '666220.0048', `onBalEcl` = '24.28683794', `offBalEcl` = '3.114689324' WHERE (`quarter` = '1') and (`dealNo` = '1');
