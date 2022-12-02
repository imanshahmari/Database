
-- This script deletes everything in your database
\set QUIET true
SET client_min_messages TO WARNING; -- Less talk please.
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
\set ON_ERROR_STOP ON
SET client_min_messages TO NOTICE; -- More talk
\set QUIET false



CREATE TABLE Programs(
	name TEXT NOT NULL, 
	abbreviation TEXT NOT NULL,
	PRIMARY KEY (name)
);

CREATE TABLE Branches(
	name TEXT NOT NULL,
	programName TEXT NOT NULL, 
	FOREIGN KEY (programName) REFERENCES Programs(name),
	PRIMARY KEY (name, programName)
);


CREATE TABLE Departments(
	name TEXT NOT NULL,
	abbreviation TEXT NOT NULL UNIQUE, 
	PRIMARY KEY (name)
);



CREATE TABLE Courses(
	code CHAR(6) NOT NULL,
	name TEXT NOT NULL,
	credits REAL NOT NULL,
	departmentName TEXT NOT NULL,
	FOREIGN KEY (departmentName) REFERENCES Departments(name),
	PRIMARY KEY (code)
);



CREATE TABLE DepartmentProgram(
	program TEXT NOT NULL,
	department TEXT NOT NULL,
	FOREIGN KEY (program) REFERENCES Programs(name),
	FOREIGN KEY (department) REFERENCES Departments(name),
	PRIMARY KEY (program, department)
);




CREATE TABLE Students(
	idnr CHAR(10),
	name TEXT NOT NULL, 
	login TEXT NOT NULL UNIQUE,
	programName TEXT NOT NULL,
	FOREIGN KEY (programName) REFERENCES Programs(name),
	UNIQUE(idnr, programName),
	PRIMARY KEY (idnr)
);



CREATE TABLE Prerequisites(
	prerequisiteCourse CHAR(6) NOT NULL,
	course TEXT NOT NULL,
	FOREIGN KEY (prerequisiteCourse) REFERENCES Courses(code),
	FOREIGN KEY (course) REFERENCES Courses(code),
	PRIMARY KEY (prerequisiteCourse,course)
);


CREATE TABLE LimitedCourses(
	code CHAR(6) NOT NULL,
	capacity INT NOT NULL,
	CHECK (capacity > 0),
	FOREIGN KEY (code) REFERENCES Courses(code),
	PRIMARY KEY (code)
);


CREATE TABLE StudentBranches(
	student CHAR(10) NOT NULL,
	branch TEXT NOT NULL,
	programNameBranch TEXT NOT NULL,
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (branch,programNameBranch) REFERENCES Branches(name,programName),
	FOREIGN KEY (student,programNameBranch) REFERENCES Students(idnr,programName),
	PRIMARY KEY (student)
);

CREATE TABLE Classifications(
	name TEXT NOT NULL,
	PRIMARY KEY (name)
);

CREATE TABLE Classified(
	course TEXT NOT NULL,
	classification TEXT NOT NULL,
	PRIMARY KEY (course,classification),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (classification) REFERENCES Classifications(name)
);

CREATE TABLE MandatoryProgram(
	course TEXT NOT NULL,
	program TEXT NOT NULL, 
	PRIMARY KEY (course,program),
	FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE MandatoryBranch(
	course TEXT NOT NULL,
	branch TEXT NOT NULL,
	programName TEXT NOT NULL,
	PRIMARY KEY (course,branch,programName),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (branch,programName) REFERENCES Branches(name,programName)
);

CREATE TABLE RecommendedBranch(
	course TEXT NOT NULL,
	branch TEXT NOT NULL,
	programName TEXT NOT NULL,
	PRIMARY KEY (course,branch,programName),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (branch,programName) REFERENCES Branches(name,programName)
);

CREATE TABLE Registered(
	student CHAR(10) NOT NULL,
	course TEXT NOT NULL, 
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (course) REFERENCES Courses(code)
);


CREATE TABLE Taken(
	student CHAR(10) NOT NULL,
	course TEXT NOT NULL,
	grade CHAR(1) NOT NULL,
	CHECK (grade IN ('U','3','4','5')),
	PRIMARY KEY (student, course),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (course) REFERENCES Courses(code)
);


CREATE TABLE WaitingList(
	student CHAR(10) NOT NULL,
	course TEXT NOT NULL,
	position SERIAL NOT NULL,
	PRIMARY KEY (student, course),
	UNIQUE(course,position),
	UNIQUE(course,student),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (course) REFERENCES LimitedCourses(code)
);






INSERT INTO Programs VALUES ('Prog1','MPCS');
INSERT INTO Programs VALUES ('Prog2','MPSYS');



INSERT INTO Departments VALUES ('ComputerScience','CS');
INSERT INTO Departments VALUES ('Physics','F');
INSERT INTO Departments VALUES ('Dep1','D');



INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');


INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2');



INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');


INSERT INTO DepartmentProgram VALUES ('Prog1','ComputerScience');
INSERT INTO DepartmentProgram VALUES ('Prog2','Physics');




INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);


INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');



INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');


INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Prog2');


INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');


INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');


INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');


INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');
INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');
INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');


INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
INSERT INTO WaitingList VALUES('3333333333','CCC333',1);
INSERT INTO WaitingList VALUES('2222222222','CCC333',2);






CREATE VIEW BasicInformation AS
SELECT idnr, name, login, Students.programName, StudentBranches.branch FROM StudentBranches 
FULL OUTER JOIN Students ON (idnr=StudentBranches.student);


CREATE VIEW FinishedCourses AS
SELECT student, course, grade, credits FROM Taken,Courses
WHERE course = Courses.code;


CREATE VIEW PassedCourses AS
SELECT student, course, credits FROM Taken,Courses
WHERE course = Courses.code AND Taken.grade != 'U';


CREATE VIEW Registrations AS
(SELECT student, course, 'registered' AS status
FROM Registered)
UNION ALL
(SELECT student, course, 'waiting' AS status
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
SELECT PassedCourses.student, SUM(credits) AS sum
FROM StudentBranches,RecommendedBranch,PassedCourses
WHERE (PassedCourses.course = RecommendedBranch.course AND StudentBranches.programNameBranch = RecommendedBranch.programName 
AND StudentBranches.branch = RecommendedBranch.branch AND PassedCourses.student = StudentBranches.student)
GROUP BY PassedCourses.student;



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
(SELECT student, seminarcourses  FROM SeminarCoursesHelper)



SELECT student, credits AS totalcredits, mandatoryleft, COALESCE(mathcredits,0) AS mathcredits , COALESCE(researchcredits,0) AS researchcredits,
COALESCE(seminarcourses,0) AS seminarcourses,
COALESCE((mandatoryleft = 0) AND (mathcredits >= 20) AND (seminarcourses >=1) AND (researchcredits >=10) AND (sum >= 10),false) AS qualified
FROM Student 
NATURAL LEFT OUTER JOIN TotalCredits 
NATURAL LEFT OUTER JOIN MandatoryLeft
NATURAL LEFT OUTER JOIN MathCredits
NATURAL LEFT OUTER JOIN ResearchCredits
NATURAL LEFT OUTER JOIN SeminarCourses
NATURAL LEFT OUTER JOIN RecommendedCoursesHelper;



CREATE VIEW CourseQueuePositions AS
SELECT * FROM WaitingList;
