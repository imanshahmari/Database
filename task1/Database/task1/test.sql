CREATE VIEW MyTest1 AS
(SELECT course FROM MandatoryBranch)
UNION
(SELECT course FROM MandatoryProgram);

SELECT * FROM MyTest1;

DROP VIEW MyTest1;


/*
Is there any alternative way of doing this without union ?
*/