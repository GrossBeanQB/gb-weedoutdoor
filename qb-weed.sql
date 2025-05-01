CREATE TABLE IF NOT EXISTS `weed_plants` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `coords` JSON NOT NULL,
    `model` VARCHAR(50) NOT NULL,
    `label` VARCHAR(50) NOT NULL,
    `stage` INT NOT NULL DEFAULT 1,
    `health` INT NOT NULL DEFAULT 100,
    `food` INT NOT NULL DEFAULT 100,
    `water` INT NOT NULL DEFAULT 100,
    `progress` INT NOT NULL DEFAULT 0,
    `sort` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id`)
);
