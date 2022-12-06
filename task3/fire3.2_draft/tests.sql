--SOME INTIAL INSERTS TO MAKE IT WORK
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');
INSERT INTO Courses VALUES ('CCC777','C4',25,'Dep1');
INSERT INTO Courses VALUES ('CCC888','C6',25,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC777',2);
INSERT INTO LimitedCourses VALUES ('CCC888',3);

INSERT INTO Prerequisites VALUES('CCC111','CCC222');
INSERT INTO Prerequisites VALUES('CCC333','CCC444');


--Registered to unlimited course
INSERT INTO Registrations VALUES('2222222222','CCC111');

--Registered to limited course
INSERT INTO Registrations VALUES('1111111111','CCC888');
INSERT INTO Registrations VALUES('3333333333','CCC888');
INSERT INTO Registrations VALUES('6666666666','CCC888');
INSERT INTO Registrations VALUES('1111111111','CCC777');
INSERT INTO Registrations VALUES('5555555555','CCC888');
INSERT INTO Registrations VALUES('2222222222','CCC888');



--Waiting for limited course
INSERT INTO Registrations VALUES('4444444444','CCC888');

--Removed from waiting list (with additional students in it)
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC333';

--Unregistered from unlimited course
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';

--Unregistered from limited course without waiting list
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC777';

--Unregistered from limited course with waiting list
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC333';

--Unregistered from overfull course with waiting list
DELETE FROM Registrations WHERE student = '3333333333' AND course = 'CCC888';

--Student is not registered or waiting
--DELETE FROM Registrations WHERE student = '3333333333' AND course = 'CCC444';

--Student has already passed course
INSERT INTO Registrations VALUES('4444444444','CCC111');

--Student already registered/waiting on course
INSERT INTO Registrations VALUES('5555555555','CCC333');

--Student has not read all prerequired courses
INSERT INTO Registrations VALUES('6666666666','CCC444');


SELECT * FROM Registered;
SELECT * FROM WaitingList;
SELECT * FROM Registrations;




SELECT student FROM Registrations WHERE student = '3333333333' AND 'CCC444' = Registrations.course;
DELETE FROM Registrations WHERE student = '3333333333' AND course = 'CCC444';