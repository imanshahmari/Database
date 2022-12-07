
import java.sql.*; // JDBC stuff.
import java.util.Properties;

public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "postgres";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode){
        String query = "INSERT INTO Registrations VALUES(?,?);";
        try(PreparedStatement st = conn.prepareStatement(query)){
            st.setString(1, student);
            st.setString(2, courseCode);
            int rowsInserted = st.executeUpdate();
            return "{\"success\":true, \"rowsInserted\":" + rowsInserted + "}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
    }


    public String register_direct(String student, String courseCode){
        String query = "INSERT INTO Registered VALUES(?,?);";
        try(PreparedStatement st = conn.prepareStatement(query)){
            st.setString(1, student);
            st.setString(2, courseCode);
            int rowsInserted = st.executeUpdate();
            return "{\"success\":true, \"rowsInserted\":" + rowsInserted + "}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
    }

    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode){
        String query = "DELETE FROM Registrations WHERE student=? AND course=?";
        try(PreparedStatement st = conn.prepareStatement(query)){
            st.setString(1, student);
            st.setString(2, courseCode);
            int nr_deleted_rows = st.executeUpdate();
            if(nr_deleted_rows== 0)
                return "{\"success\":false,"
                        + " \"error\":\"" +"The student is not registered or wating." + "\"}";
            else
                return "{\"success\":true, \"rowsDeleted\":" + nr_deleted_rows + "}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
    }


    public String SQLinjection(String student, String courseCode){
        String query = "DELETE FROM Registered WHERE student = ? AND course = ?;";
        try(PreparedStatement st = conn.prepareStatement(query)){
            st.setString(1, student);
            st.setString(2, courseCode);
            int rowsInserted = st.executeUpdate();
            return "{\"success\":true, \"rowsDeleted\":" + rowsInserted + "}";
        } catch (SQLException e) {
            return "{\"success\":false, \"error\":\"" + getError(e) + "\"}";
        }
    }





    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException{

        try(PreparedStatement st = conn.prepareStatement(


//                "SELECT jsonb_build_object('student',idnr,'name',name) AS jsondata FROM BasicInformation WHERE idnr=?"
                // replace this with something more useful


"                WITH"
+"                b AS (SELECT * FROM BasicInformation WHERE idnr = ?),"

+"                f AS (SELECT jsonb_agg(json_build_object('course',Courses.name,'code',Taken.course,'credits',Courses.credits,'grade',Taken.grade)) AS finished"
+"                      FROM Taken,Courses WHERE student = ? AND Courses.code = Taken.course),"

+"                r AS (SELECT jsonb_agg(json_build_object('course',Courses.name, 'code',Courses.code, 'status', status, 'position', place)) AS registered"
+"                        FROM Registrations NATURAL LEFT OUTER JOIN WaitingList, Courses "
+"                        WHERE Registrations.course = Courses.code and Registrations.student = ?),"
+"                p AS (SELECT * FROM PathToGraduation WHERE student = ?)"

+"                SELECT jsonb_build_object('student',idnr,'name',name,'login', login , 'program',program,'branch', branch, 'finished' , f.finished, 'registered' , r.registered ,"
+"                'seminarCourses', p.seminarcourses, 'mathCredits', p.mathcredits, 'researchCredits', p.researchcredits, 'totalCredits', p.totalcredits, 'canGraduate', p.qualified) AS jsondata"
+"                FROM b"
+"                NATURAL LEFT OUTER JOIN f"
+"                NATURAL LEFT OUTER JOIN r"
+"                NATURAL LEFT OUTER JOIN p;"


        );){

            st.setString(1, student);
            st.setString(2, student);
            st.setString(3, student);
            st.setString(4, student);
            //st.setString(2, student);

            ResultSet rs = st.executeQuery();

            if(rs.next())
                return rs.getString("jsondata");
            else
                return "{\"student\":\"does not exist :(\"}";

        }
    }

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
        String message = e.getMessage();
        int ix = message.indexOf('\n');
        if (ix > 0) message = message.substring(0, ix);
        message = message.replace("\"","\\\"");
        return message;
    }
}