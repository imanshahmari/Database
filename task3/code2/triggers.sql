

CREATE FUNCTION register() RETURNS TRIGGER AS $$

    BEGIN

        IF (EXISTS (SELECT student FROM Registered WHERE student = NEW.student AND Registered.course = NEW.course)) THEN
			RAISE EXCEPTION 'student already registered or is waiting in that course';

        ELSIF (NOT EXISTS(SELECT PassedCourses.student
            FROM PassedCourses,Prerequisites
            WHERE Prerequisites.prerequisiteCourse = PassedCourses.course AND Prerequisites.course = NEW.Course AND PassedCourses.student = NEW.student OR
            NOT EXISTS( SELECT course FROM Prerequisites WHERE NEW.course = course))
            ) THEN
            RAISE EXCEPTION 'Prerequisites doesnt match';
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

CREATE TRIGGER register_update
INSTEAD OF INSERT ON Registrations 
    FOR EACH ROW EXECUTE FUNCTION register();







CREATE FUNCTION unregister() RETURNS TRIGGER AS $$
    BEGIN

        IF (EXISTS (SELECT student FROM Registered,LimitedCourses WHERE student = OLD.student AND Registered.course = OLD.course AND OLD.course != LimitedCourses.code)) THEN
			DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
			RAISE NOTICE 'deleted sucessfully';


        ELSIF (EXISTS (SELECT student FROM WaitingList,LimitedCourses WHERE student = OLD.student AND WaitingList.course = OLD.course
		AND LimitedCourses.code = OLD.course AND  WaitingList.student != OLD.student)) THEN
        	DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
            RAISE NOTICE 'removed from registered list';


		
        ELSIF (EXISTS (SELECT student FROM WaitingList,LimitedCourses WHERE student = OLD.student AND WaitingList.course = OLD.course
		AND LimitedCourses.code = OLD.course AND  WaitingList.student = OLD.student)) THEN
        	DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
            DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
            RAISE NOTICE 'removed from waiting list';


        /*
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

		*/
        END IF;
        RETURN OLD;

    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unregister_update
INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION unregister();































