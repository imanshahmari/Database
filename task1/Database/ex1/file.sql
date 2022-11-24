-- This script deletes everything in your database
\set QUIET true
SET client_min_messages TO WARNING; -- Less talk please.
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
\set ON_ERROR_STOP ON
SET client_min_messages TO NOTICE; -- More talk
\set QUIET false


CREATE TABLE States(
	state TEXT, 
	biden INT, 
	trump INT, 
	nr_electors INT,
	PRIMARY KEY (state)
);

-- Test data
INSERT INTO States VALUES ('NV', 588252,  580605,  6);
INSERT INTO States VALUES ('AZ', 3215969, 3051555, 11);
INSERT INTO States VALUES ('GA', 2406774, 2429783, 16);
INSERT INTO States VALUES ('PA', 3051555, 3215969, 20);
-- Slightly simplified data
INSERT INTO States VALUES ('Red states',  0,  1,  232);
INSERT INTO States VALUES ('Blue states', 1, 0, 253);


--TO DO get the name of Trump and Biden with a condition

CREATE VIEW StateResults AS
SELECT state,nr_electors
FROM Election
WHERE condition;