

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
	program TEXT NOT NULL, 
	FOREIGN KEY (program) REFERENCES Programs(name),
	PRIMARY KEY (name, program)
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
	department TEXT NOT NULL,
	PRIMARY KEY (code)
);




CREATE TABLE DepartmentCourse(
	course TEXT NOT NULL,
	department TEXT NOT NULL,
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (department) REFERENCES Departments(name),
	PRIMARY KEY (course, department)
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
	program TEXT NOT NULL,
	FOREIGN KEY (program) REFERENCES Programs(name),
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


CREATE TABLE StudentPrograms(
	student CHAR(10) NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (student,program),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (program) REFERENCES Programs(name)
);



CREATE TABLE StudentBranches(
	student CHAR(10) NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (branch,program) REFERENCES Branches(name,program),
	FOREIGN KEY (student,program) REFERENCES StudentPrograms(student,program),
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
	program TEXT NOT NULL,
	PRIMARY KEY (course,branch,program),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (branch,program) REFERENCES Branches(name,program)
);

CREATE TABLE RecommendedBranch(
	course TEXT NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (course,branch,program),
	FOREIGN KEY (course) REFERENCES Courses(code),
	FOREIGN KEY (branch,program) REFERENCES Branches(name,program)
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



