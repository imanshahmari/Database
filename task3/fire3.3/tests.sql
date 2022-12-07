--SOME INTIAL INSERTS TO MAKE IT WORK
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');
INSERT INTO Courses VALUES ('CCC777','C4',25,'Dep1');
INSERT INTO Courses VALUES ('CCC888','C6',25,'Dep1');
INSERT INTO Courses VALUES ('CCC999','C6',25,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC777',2);
INSERT INTO LimitedCourses VALUES ('CCC888',3);

INSERT INTO Prerequisites VALUES('CCC111','CCC222');
INSERT INTO Prerequisites VALUES('CCC333','CCC444');
INSERT INTO Prerequisites VALUES('CCC111','CCC999');
INSERT INTO Prerequisites VALUES('CCC333','CCC999');


INSERT INTO Taken VALUES('6666666666','CCC333','3');
INSERT INTO Registrations VALUES('6666666666','CCC111');
--INSERT INTO Taken VALUES('6666666666','CCC111','U');


--Registered to unlimited course
INSERT INTO Registrations VALUES('2222222222','CCC111');

--Student has already passed the course
INSERT INTO Registrations VALUES('6666666666','CCC333');


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

INSERT INTO Registrations VALUES('1111111111','CCC777');
INSERT INTO Registrations VALUES('2222222222','CCC777');
INSERT INTO Registrations VALUES('3333333333','CCC777');

INSERT INTO Registered VALUES('4444444444','CCC777');

DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC777';

--Student has already passed course
INSERT INTO Registrations VALUES('4444444444','CCC111');

--Student already registered/waiting on course
INSERT INTO Registrations VALUES('5555555555','CCC333');

--Student has not read all prerequired courses
INSERT INTO Registrations VALUES('6666666666','CCC222');

--Student has not read all prerequired courses
INSERT INTO Registrations VALUES('6666666666','CCC999');

--Unregistered from limited course with waiting list and update the list
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC888';
