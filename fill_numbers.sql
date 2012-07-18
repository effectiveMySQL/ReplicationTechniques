DROP TABLE IF EXISTS numbers;
CREATE TABLE numbers ( id INT NOT NULL PRIMARY KEY);
DELIMITER $$
DROP PROCEDURE IF EXISTS fill_numbers $$
CREATE PROCEDURE fill_numbers()
DETERMINISTIC
BEGIN
  DECLARE counter INT DEFAULT 1;
  TRUNCATE TABLE numbers;
  INSERT INTO numbers VALUES (1);
  WHILE counter < 1000000
  DO
  	INSERT INTO numbers (id)
      	SELECT id + counter
      	FROM numbers;
  	SELECT COUNT(*) INTO counter FROM numbers;
  	SELECT counter;
  END WHILE;
END $$
DELIMITER ;
