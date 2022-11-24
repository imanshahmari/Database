
CREATE VIEW BasicInformation AS
SELECT idnr, name, login, Students.program, StudentBranches.branch FROM StudentBranches 
FULL OUTER JOIN Students ON (idnr=StudentBranches.student);


CREATE VIEW FinishedCourses AS
SELECT student, course, grade, credits FROM Taken,Courses
WHERE course = Courses.code;


CREATE VIEW PassedCourses AS
SELECT student, course, credits FROM Taken,Courses
WHERE course = Courses.code AND Taken.grade != 'U';


CREATE VIEW Registrations AS
(SELECT student, course, 'Registered' AS status
FROM Registered)
UNION ALL
(SELECT student, course, 'Waiting' AS status
FROM WaitingList);


CREATE VIEW UnreadMandatory AS
(SELECT idnr AS student, course FROM Students NATURAL JOIN MandatoryProgram)
UNION
(SELECT student, course FROM StudentBranches NATURAL JOIN MandatoryBranch)
EXCEPT
(SELECT student, course FROM Taken WHERE Taken.grade != 'U');



CREATE VIEW SumHelperView AS
SELECT student, SUM(credits) AS credits FROM PassedCourses GROUP BY student;

CREATE VIEW NoCreditPeople AS
SELECT idnr, 0 AS credits FROM Students AS Temp WHERE NOT EXISTS
(SELECT student FROM SumHelperView WHERE student = Temp.idnr);

CREATE VIEW MergeSumNoCred AS
(SELECT student, credits FROM SumHelperView)
UNION
(SELECT idnr, credits FROM NoCreditPeople);



CREATE VIEW MandatoryLeftHelper AS
SELECT student, COUNT(*) AS mandatoryleft FROM UnreadMandatory GROUP BY student;

CREATE VIEW MandatoryNotLeftHelper AS
SELECT idnr, 0 AS mandatoryleft FROM Students AS Temp1 WHERE NOT EXISTS
(SELECT student FROM MandatoryLeftHelper WHERE student = Temp1.idnr);

CREATE VIEW MergeMandatory AS
(SELECT student, mandatoryleft FROM MandatoryLeftHelper)
UNION
(SELECT idnr AS student, mandatoryleft FROM MandatoryNotLeftHelper);



CREATE VIEW MathCreditsHelper AS
SELECT PassedCourses.student, SUM(credits) AS mathcredits 
FROM PassedCourses
WHERE PassedCourses.course IN (SELECT course FROM Classified WHERE classification = 'math')
GROUP BY PassedCourses.student;


CREATE VIEW ResearchCreditsHelper AS
SELECT PassedCourses.student, SUM(credits) AS researchcredits 
FROM PassedCourses
WHERE PassedCourses.course IN (SELECT course FROM Classified WHERE classification = 'research')
GROUP BY PassedCourses.student;



CREATE VIEW SeminarCoursesHelper AS
SELECT PassedCourses.student, COUNT(*) AS seminarcourses
FROM PassedCourses
WHERE PassedCourses.course IN (SELECT course FROM Classified WHERE classification = 'seminar')
GROUP BY PassedCourses.student;


CREATE VIEW RecommendedCoursesHelper AS
SELECT PassedCourses.student, SUM(credits) AS recommended
FROM PassedCourses
WHERE PassedCourses.course IN (SELECT course FROM RecommendedBranch)
GROUP BY PassedCourses.student;



CREATE VIEW QualifiedHelper AS
SELECT DISTINCT PassedCourses.student, TRUE AS qualified
FROM PassedCourses
WHERE 
PassedCourses.course IN ((SELECT course FROM MandatoryBranch) UNION (SELECT course FROM MandatoryProgram))
AND
PassedCourses.course IN(SELECT course FROM RecommendedBranch WHERE PassedCourses.credits >= 10)
AND
PassedCourses.student IN(SELECT student FROM MathCreditsHelper WHERE MathCreditsHelper.mathcredits >= 20)

AND
PassedCourses.student IN(SELECT student FROM ResearchCreditsHelper WHERE ResearchCreditsHelper.researchcredits  >= 10)

AND
PassedCourses.student IN(SELECT student FROM SeminarCoursesHelper WHERE SeminarCoursesHelper.seminarcourses >= 1);


SELECT * FROM RecommendedCoursesHelper;

CREATE VIEW PathToGraduation AS
WITH
Student AS
(SELECT idnr AS student FROM Students),
TotalCredits AS
(SELECT student, credits FROM MergeSumNoCred),
MandatoryLeft AS
(SELECT student, mandatoryleft FROM MergeMandatory),
MathCredits AS
(SELECT student, mathcredits  FROM MathCreditsHelper),
ResearchCredits AS
(SELECT student, researchcredits  FROM ResearchCreditsHelper),
SeminarCourses AS
(SELECT student, seminarcourses  FROM SeminarCoursesHelper),
Qualified AS
(SELECT student, qualified  FROM QualifiedHelper)



SELECT student, credits AS totalcredits, mandatoryleft, COALESCE(mathcredits,0) AS mathcredits , COALESCE(researchcredits,0) AS researchcredits,
COALESCE(seminarcourses,0) AS seminarcourses, COALESCE(qualified,FALSE) AS qualified
FROM Student 
NATURAL LEFT OUTER JOIN TotalCredits 
NATURAL LEFT OUTER JOIN MandatoryLeft
NATURAL LEFT OUTER JOIN MathCredits
NATURAL LEFT OUTER JOIN ResearchCredits
NATURAL LEFT OUTER JOIN SeminarCourses

NATURAL LEFT OUTER JOIN Qualified;




/*
Jonas 

SELECT student, credits AS TotalCredits, mandatoryleft, COALESCE(mathcredits,0) AS mathcredits , COALESCE(researchcredits,0) AS researchcredits,
COALESCE(seminarcourses,0) AS seminarcourses, ((credits > 10) AND ()) AS qualified


*/


/*

SELECT * FROM BasicInformation ORDER BY idnr;
SELECT * FROM FinishedCourses ORDER BY student;
SELECT * FROM PassedCourses ORDER BY student;
SELECT * FROM Registrations ORDER BY student;
SELECT * FROM UnreadMandatory ORDER BY student;
SELECT * FROM PathToGraduation ORDER BY student;
SELECT * FROM SumHelperView ORDER BY student;
SELECT * FROM NoCreditPeople ORDER BY idnr;
SELECT * FROM MergeSumNoCred ORDER BY student;
SELECT * FROM MergeMandatory;
SELECT * FROM MathCreditsHelper;


DROP VIEW PathToGraduation CASCADE;
DROP VIEW BasicInformation;
DROP VIEW FinishedCourses;
DROP VIEW Registrations;
DROP VIEW PassedCourses CASCADE;
DROP VIEW UnreadMandatory CASCADE;
DROP VIEW MathCreditsHelper;
DROP VIEW ResearchCreditsHelper;
--Is there anyway to drop all views faster ?


*/
