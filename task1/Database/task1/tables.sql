-- This script deletes everything in your database
\set QUIET true
SET client_min_messages TO WARNING; -- Less talk please.
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;
\set ON_ERROR_STOP ON
SET client_min_messages TO NOTICE; -- More talk
\set QUIET false


CREATE TABLE Students(
	--why doesnt sql store values this big in an int it shouldnt be a problem? 
	--idnr INT NOT NULL,
	--CHECK (idnr > 1000000000 AND idnr < 9999999999),
	idnr CHAR(10),
	name TEXT NOT NULL, 
	login TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (idnr)
);

CREATE TABLE Branches(
	name TEXT NOT NULL,
	program TEXT NOT NULL, 
	PRIMARY KEY (name, program)
);

CREATE TABLE Courses(
	code CHAR(6) NOT NULL,
	name TEXT NOT NULL,
	credits REAL NOT NULL,
	department TEXT NOT NULL,
	PRIMARY KEY (code)
);

CREATE TABLE LimitedCourses(
	code CHAR(6) NOT NULL,
	capacity INT
	CHECK (capacity > 0),
	PRIMARY KEY (code),
	FOREIGN KEY (code) REFERENCES Courses(code)
);

CREATE TABLE StudentBranches(
	student CHAR(10) NOT NULL,
	branch TEXT NOT NULL,
	program TEXT NOT NULL,
	PRIMARY KEY (student),
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (branch,program) REFERENCES Branches(name,program)
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
	FOREIGN KEY (student) REFERENCES Students(idnr),
	FOREIGN KEY (course) REFERENCES Courses(code)
);



