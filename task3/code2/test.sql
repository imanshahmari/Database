--SOME INTIAL INSERTS TO MAKE IT WORK
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');
INSERT INTO Courses VALUES ('CCC777','C4',25,'Dep1');
INSERT INTO Courses VALUES ('CCC888','C6',25,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC777',2);
INSERT INTO LimitedCourses VALUES ('CCC888',3);

INSERT INTO Prerequisites VALUES('CCC111','CCC222');
INSERT INTO Prerequisites VALUES('CCC333','CCC444');




SELECT * FROM Registrations ORDER BY course;

--TEST IF INSERT WORKS
INSERT INTO Registrations VALUES('6666666666','CCC111');


--TEST IF PREREQUISIT GIVES ERROR 
INSERT INTO Registrations VALUES('3333333333','CCC222');
--SHOULD RETURN PREREQISITES NOT MET



--TEST IF COURSE IS FULL WORKS WHEN REGISTERING FOR A COURSE THAT HAS NO STUDENTS REGISTERED
INSERT INTO Registrations VALUES('3333333333','CCC777');
INSERT INTO Registrations VALUES('1111111111','CCC777');
--SHOULD INSERT THEM SUCCESSFULLY

--TEST IF IT PUTS TO WAITING LIST IF FULL
INSERT INTO Registrations VALUES('2222222222','CCC777');
--SHOULD PUT TO WAITLING LIST


SELECT * FROM Registrations ORDER BY course;

SELECT * FROM PassedCourses;
SELECT * FROM Prerequisites;

SELECT * FROM LimitedCourses;


SELECT * FROM WaitingList;





SELECT * FROM Registrations ORDER BY course;
SELECT * FROM LimitedCourses;
SELECT * FROM WaitingList;


--TEST IF DELTEING FROM A NON-LIMITED COURSE WORKS
DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC111';
--THis should delete sucessfully 


SELECT * FROM Registrations ORDER BY course;
SELECT * FROM LimitedCourses;
SELECT * FROM WaitingList;



--TEST TO UNREGISTER STUDENT THAT IS NOT IN WATINIGN LIST AND CHECK IF THE UPDATE WORKS

INSERT INTO Registrations VALUES('6666666666','CCC888');
INSERT INTO Registrations VALUES('5555555555','CCC888');
INSERT INTO Registrations VALUES('2222222222','CCC888');
INSERT INTO Registrations VALUES('3333333333','CCC888');
--INSERT INTO Registrations VALUES('1111111111','CCC888');


SELECT * FROM Registrations ORDER BY course;
SELECT * FROM LimitedCourses;
SELECT * FROM WaitingList;



DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC888';


SELECT * FROM Registrations ORDER BY course;
SELECT * FROM LimitedCourses;
SELECT * FROM WaitingList;







--TEST TO UNREGISTER STUDENT WHICH THAT IS IN WAITING LIST AND DELETE THEM FROM WAITING LIST
INSERT INTO Registrations VALUES('6666666666','CCC777');

SELECT * FROM Registrations ORDER BY course;
SELECT * FROM LimitedCourses;
SELECT * FROM WaitingList;


DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC777';


SELECT * FROM Registrations ORDER BY course;
SELECT * FROM LimitedCourses;
SELECT * FROM WaitingList;


/*
SELECT Students.idnr FROM PassedCourses,Prerequisites,Registrations, Students
WHERE Prerequisites.prerequisiteCourse = PassedCourses.course AND Prerequisites.course = 'CCC777' AND PassedCourses.student = '6666666666' 
OR NOT EXISTS(SELECT course FROM Prerequisites WHERE course = 'CCC777');

*/


/*
SELECT LimitedCourses.code, COUNT(*) >= LimitedCourses.capacity AS numberOfRegistrations FROM LimitedCourses,Registrations 
WHERE LimitedCourses.code = Registrations.course AND Registrations.status = 'registered' GROUP BY LimitedCourses.code;
*/

/*

SELECT COUNT(*) >= LimitedCourses.capacity AS numberOfRegistrations FROM LimitedCourses,Registrations 
WHERE LimitedCourses.code = Registrations.course AND Registrations.status = 'registered' AND LimitedCourses.code = 'CCC222' GROUP BY LimitedCourses.code;
*/

/*
SELECT PassedCourses.student, Prerequisites.course
FROM PassedCourses,Prerequisites,Registrations
WHERE Prerequisites.prerequisiteCourse = PassedCourses.course AND Prerequisites.course = 'CCC777' AND PassedCourses.student = '1111111111' OR 'CCC777' != Registrations.course;
*/
/*

SELECT student FROM Registered,LimitedCourses WHERE student = '6666666666' AND Registered.course = 'CCC888' AND 'CCC888' IN (SELECT code FROM  LimitedCourses) = FALSE;

SELECT student FROM WaitingList,LimitedCourses WHERE student = '6666666666' AND WaitingList.course = 'CCC888' AND LimitedCourses.code = 'CCC888';

SELECT Registered.student FROM Registered,WaitingList,LimitedCourses WHERE Registered.student = '6666666666' AND Registered.course = 'CCC888' 
AND LimitedCourses.code = 'CCC888' AND  WaitingList.student != '6666666666';


*/
