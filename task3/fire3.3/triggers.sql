

CREATE FUNCTION register() RETURNS TRIGGER AS $$

    BEGIN

        IF (EXISTS (SELECT student FROM Registrations WHERE student = NEW.student AND Registrations.course = NEW.course)) THEN
			RAISE EXCEPTION 'STUDENT ALREADY REGISTERED OR IS WAITING IN THAT COURSE';

        ElSEIF (EXISTS (SELECT student FROM PassedCourses WHERE student = NEW.student AND PassedCourses.course = NEW.course)) THEN
            RAISE EXCEPTION 'STUDENT HAS ALREADY PASSED THE COURSE';

        ELSIF (EXISTS((SELECT student FROM Registrations, Prerequisites WHERE Prerequisites.prerequisiteCourse = Registrations.course AND Prerequisites.course = NEW.course AND student = NEW.student)
                    UNION
                    (SELECT student FROM Taken,Prerequisites WHERE Taken.grade = 'U' AND  Prerequisites.prerequisiteCourse = Taken.course AND Prerequisites.course = NEW.course AND student = NEW.student))
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
            	RAISE NOTICE 'INSERTED SUCESSFULLY AS REGISTERED';


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

        IF (EXISTS (SELECT student FROM Registered WHERE student = OLD.student AND Registered.course = OLD.course AND OLD.course IN (SELECT code FROM  LimitedCourses) = FALSE)) THEN
            DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
            RAISE NOTICE 'DELETED SUCESSFULLY';


        ELSEIF ((SELECT COUNT(student) FROM Registered WHERE course = OLD.course) > (SELECT capacity FROM LimitedCourses WHERE code = OLD.course) ) THEN
            DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
            RAISE NOTICE 'DELETED SUCESSFULLY FROM OVERFULL COURSE';

        ELSE
            IF (EXISTS (SELECT Registered.student FROM Registered,WaitingList,LimitedCourses WHERE Registered.student = OLD.student AND Registered.course = OLD.course 
                AND LimitedCourses.code = OLD.course AND  WaitingList.student != OLD.student)) THEN

            WITH studentToRegister AS (DELETE FROM WaitingList WHERE course = OLD.course AND place = 1 RETURNING student, course)
            INSERT INTO Registered(student, course) SELECT student, course FROM studentToRegister;
            
            UPDATE WaitingList SET place = place - 1 WHERE course = OLD.course;

        	DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
            RAISE NOTICE 'REMOVED FROM REGISTERED LIST';


    		
            ELSIF (EXISTS (SELECT student FROM WaitingList WHERE student = OLD.student AND WaitingList.course = OLD.course)) THEN
            	DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
                WITH studentToUnregister AS (DELETE FROM WaitingList WHERE course = OLD.course AND student = OLD.student RETURNING student, place AS myplace)
                UPDATE WaitingList SET place = place - 1 FROM studentToUnregister WHERE WaitingList.course = OLD.course AND place > studentToUnregister.myplace;
                RAISE NOTICE 'REMOVED FROM WAITING LIST';

            END IF;

        END IF;
        RETURN OLD;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unregister_update
INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION unregister();































