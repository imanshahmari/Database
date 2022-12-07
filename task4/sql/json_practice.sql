--SELECT * FROM STUDENTS;
/*
SELECT * FROM BasicInformation;
SELECT * FROM Taken;
SELECT * FROM Registered;
SELECT * FROM WaitingList;
SELECT * FROM PathToGraduation;
SELECT * FROM Prerequisites;
*/

/*
WITH
b AS (SELECT * FROM BasicInformation WHERE idnr = '4444444444'),
f AS (SELECT jsonb_agg(json_build_object('course',Courses.name,'code',Taken.course,'credits',Courses.credits,'grade',Taken.grade)) AS readCourses 
	FROM Taken,Courses WHERE student = '4444444444' AND Courses.code = Taken.course)

SELECT jsonb_build_object('student',idnr,'name',name, 'program',program,'branch', branch, 'read courses' , f.readCourses) 
FROM b
NATURAL LEFT OUTER JOIN f;
*/




/*

WITH
b AS (SELECT * FROM BasicInformation WHERE idnr = '4444444444'),

f AS (SELECT jsonb_agg(json_build_object('course',Courses.name,'code',Taken.course,'credits',Courses.credits,'grade',Taken.grade)) AS finished 
	FROM Taken,Courses WHERE student = '4444444444' AND Courses.code = Taken.course),

r AS (SELECT jsonb_agg(json_build_object('course',Courses.name, 'code',Courses.code, 'status', status, 'position', place)) AS registered
	FROM Registrations NATURAL LEFT OUTER JOIN WaitingList, Courses 
	WHERE Registrations.course = Courses.code and Registrations.student = '2222222222'),

p AS (SELECT * FROM PathToGraduation WHERE student = '2222222222')


SELECT jsonb_build_object('student',idnr,'name',name, 'program',program,'branch', branch, 'finished' , f.finished, 'registered' , r.registered,
'seminarCourses', p.seminarcourses, 'mathCredits', p.mathcredits, 'researchCredits', p.researchcredits, 'totalCredits', p.totalcredits, 'canGraduate', p.qualified) 
FROM b
NATURAL LEFT OUTER JOIN f
NATURAL LEFT OUTER JOIN r
NATURAL LEFT OUTER JOIN p;



--SELECT * FROM PathToGraduation;



SELECT Courses.name, Courses.code, status, place AS position 
FROM Registrations NATURAL LEFT OUTER JOIN WaitingList, Courses 
WHERE Registrations.course = Courses.code and Registrations.student = '2222222222';





WITH
b AS (SELECT * FROM BasicInformation WHERE idnr = '1111111111')

SELECT jsonb_build_object('student',idnr,'name',name, 'program',program,'branch', branch) 
FROM b;





TotalCredits AS
(SELECT student, credits FROM MergeSumNoCred),
MandatoryLeft AS
(SELECT student, mandatoryleft FROM MergeMandatory),
MathCredits AS
(SELECT student, mathcredits  FROM MathCreditsHelper),
ResearchCredits AS
(SELECT student, researchcredits  FROM ResearchCreditsHelper),
SeminarCourses AS
(SELECT student, seminarcourses  FROM SeminarCoursesHelper)
*/
SELECT * FROM LimitedCourses;
SELECT * FROM Registered;
SELECT * FROM WaitingList;
