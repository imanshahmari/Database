

CREATE FUNCTION register() RETURNS TRIGGER AS $$

    BEGIN

        IF (EXISTS (SELECT student FROM Registered WHERE student = NEW.student AND Registered.course = NEW.course)
            OR EXISTS(SELECT student FROM PassedCourses WHERE student = NEW.student AND PassedCourses.course = NEW.course)
            ) THEN
            RAISE EXCEPTION 'STUDENT ALREADY REGISTERED OR IS WAITING IN THAT COURSE';

        ELSIF (NOT EXISTS(SELECT PassedCourses.student
            FROM PassedCourses,Prerequisites
            WHERE Prerequisites.prerequisiteCourse = PassedCourses.course AND Prerequisites.course = NEW.Course AND PassedCourses.student = NEW.student OR
            NOT EXISTS( SELECT course FROM Prerequisites WHERE NEW.course = course))
            ) THEN
            RAISE EXCEPTION 'PREREQUISITES DOESNT MATCH';
        ELSE
            IF ((SELECT COUNT(*) >= LimitedCourses.capacity FROM LimitedCourses,Registrations 
                WHERE LimitedCourses.code = Registrations.course AND Registrations.status = 'registered' AND LimitedCourses.code = NEW.course 
                GROUP BY LimitedCourses.code) = TRUE) THEN

                INSERT INTO WaitingList VALUES(NEW.student,NEW.course, (SELECT Count(student) FROM WaitingList WHERE course = NEW.course) + 1);

                RAISE NOTICE 'INSERTED SUCESSFULLY AS WAITING';

            ELSE

            	INSERT INTO Registered VALUES(NEW.student,NEW.course);
            	--RETURN NEW;
            	RAISE NOTICE 'INSERTED SUCESSFULLY AS REGISTERE';


            END IF;
        END IF;

        RETURN NEW;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER register_update
INSTEAD OF INSERT ON Registrations 
    FOR EACH ROW EXECUTE FUNCTION register();





CREATE FUNCTION unregister() RETURNS TRIGGER AS $$
    BEGIN
        IF(NOT EXISTS(SELECT student FROM Registrations WHERE student = OLD.student AND OLD.course = Registrations.course)) THEN
            RAISE EXCEPTION 'NO STUDENT TO UNREGISTER';


        ELSEIF (EXISTS (SELECT student FROM Registered,LimitedCourses WHERE student = OLD.student AND Registered.course = OLD.course AND OLD.course IN (SELECT code FROM  LimitedCourses) = FALSE)) THEN
			DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
			RAISE NOTICE 'DELETED SUCESSFULLY';


        ELSE
            IF (EXISTS (SELECT Registered.student FROM Registered,WaitingList,LimitedCourses WHERE Registered.student = OLD.student AND Registered.course = OLD.course 
                AND LimitedCourses.code = OLD.course AND  WaitingList.student != OLD.student)) THEN

            WITH studentToRegister AS (DELETE FROM WaitingList WHERE course = OLD.course AND position = 1 RETURNING student, course)
            INSERT INTO Registered(student, course) SELECT student, course FROM studentToRegister;
            
            UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course;

        	DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
            RAISE NOTICE 'REMOVED FROM REGISTERED LIST';


    		
            ELSIF (EXISTS (SELECT student FROM WaitingList,LimitedCourses WHERE student = OLD.student AND WaitingList.course = OLD.course
    		AND LimitedCourses.code = OLD.course AND  WaitingList.student = OLD.student)) THEN
            	DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;



                DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
                RAISE NOTICE 'REMOVED FROM WAITINGLIST';

            END IF;

        END IF;
        RETURN OLD;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unregister_update
INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION unregister();































