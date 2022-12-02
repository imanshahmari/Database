SELECT * FROM Registrations ORDER BY course;
/*
--TEST IF INSERT WORKS
INSERT INTO Registrations VALUES('6666666666','CCC222');

--TEST IF PREREQUISIT GIVES ERROR 
INSERT INTO Registrations VALUES('3333333333','CCC222');

*/
--TEST IF COURSE IS FULL WORKS WHEN REGISTERING FOR A COURSE THAT HAS NO STUDENTS REGISTERED
INSERT INTO Registrations VALUES('3333333333','CCC777');
INSERT INTO Registrations VALUES('1111111111','CCC777');
INSERT INTO Registrations VALUES('2222222222','CCC777');

SELECT * FROM Registrations ORDER BY course;

SELECT * FROM PassedCourses;
SELECT * FROM Prerequisites;

SELECT * FROM LimitedCourses;


SELECT * FROM WaitingList;
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