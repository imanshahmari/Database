
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






CREATE FUNCTION update_registrations() RETURNS TRIGGER AS $$
    /*
	DECLARE 
        myStudent CHAR(10);
        myCourse CHAR(6);
    */

    BEGIN
        --
        -- Perform the required operation on emp, and create a row in emp_audit
        -- to reflect the change made to emp.
        --
        /*
        SELECT student INTO myStudent FROM Registered;
        SELECT course INTO myCourse FROM Registered;
        
        IF (myStudent = NEW.student) THEN
        */
        IF (EXISTS (SELECT student FROM Registered WHERE student = NEW.student AND Registered.course = NEW.course)) THEN
			RAISE EXCEPTION 'student already registered or is waiting in that course';

        /*
        ELSIF (NOT EXISTS(SELECT student
            FROM PassedCourses,Prerequisites 
            WHERE Prerequisites.prerequisiteCourse = PassedCourses.course AND Prerequisites.course = NEW.Course AND student = NEW.student)
            ) THEN
        */
        ELSIF (NOT EXISTS(SELECT PassedCourses.student
            FROM PassedCourses,Prerequisites,Registrations 
            WHERE Prerequisites.prerequisiteCourse = PassedCourses.course AND Prerequisites.course = NEW.Course AND PassedCourses.student = NEW.student OR NEW.course != Registrations.course)
            ) THEN
            --RAISE NOTICE 'I was here';
            RAISE EXCEPTION 'Prerequisites doesnt match';
        /*
            
            NEW.last_updated = now();
            INSERT INTO emp_audit VALUES('U', user, NEW.*);
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO emp VALUES(NEW.empname, NEW.salary);

            NEW.last_updated = now();
            INSERT INTO emp_audit VALUES('I', user, NEW.*);
            RETURN NEW;
        */
        ELSE
            IF ((SELECT COUNT(*) >= LimitedCourses.capacity FROM LimitedCourses,Registrations 
                WHERE LimitedCourses.code = Registrations.course AND Registrations.status = 'registered' AND LimitedCourses.code = NEW.course 
                GROUP BY LimitedCourses.code) = TRUE) THEN

                INSERT INTO WaitingList VALUES(NEW.student,NEW.course);

                RAISE NOTICE 'inserted sucessfully as waiting';

            ELSE

            	INSERT INTO Registered VALUES(NEW.student,NEW.course);
            	--RETURN NEW;
            	RAISE NOTICE 'inserted sucessfully as registered';


            END IF;
        END IF;

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER insert_update
INSTEAD OF INSERT ON Registrations 
    FOR EACH ROW EXECUTE FUNCTION update_registrations();




















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
SELECT * FROM ResearchCreditsHelper;
SELECT * FROM RecommendedCoursesHelper ORDER BY student;


DROP VIEW RecommendedCoursesHelper CASCADE;
DROP VIEW PathToGraduation CASCADE;
DROP VIEW BasicInformation;
DROP VIEW FinishedCourses;
DROP VIEW Registrations;
DROP VIEW PassedCourses CASCADE;
DROP VIEW UnreadMandatory CASCADE;
DROP VIEW MathCreditsHelper;
DROP VIEW ResearchCreditsHelper;
DROP VIEW RecommendedCoursesHelper;



*/