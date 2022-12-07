public class TestPortal {

    // enable this to make pretty printing a bit more compact
    private static final boolean COMPACT_OBJECTS = false;

    // This class creates a portal connection and runs a few operation

    public static void main(String[] args) {
        try{
            PortalConnection c = new PortalConnection();

            // Write your tests here. Add/remove calls to pause() as desired.
            // Use println instead of prettyPrint to get more compact output (if your raw JSON is already readable)


            System.out.println("List info for a student");
            prettyPrint(c.getInfo("2222222222"));
            pause();

            System.out.println("Register the student for an unrestricted course, and check that they end up registered (print info again)");
            System.out.println(c.register("3333333333", "CCC111")); // Student 3333333333 do not read the course CCC111
            pause();

            System.out.println("Register the same student for the same course again, and check that you get an error response");
            System.out.println(c.register("3333333333", "CCC111")); // Should expect an error
            pause();


            System.out.println("Unregister the student from the course, and then unregister again from the same course. ");
            System.out.println(c.unregister("3333333333", "CCC111")); // Should delete it sucessfully
            pause();

            System.out.println("Unregister the student from the course, and then unregister again from the same course. ");
            System.out.println(c.unregister("3333333333", "CCC111")); // Should delete it sucessfully
            pause();

            System.out.println("Register the student for a course that they don't have the prerequisites for, and check that an error is generated");
            System.out.println(c.register("6666666666", "CCC999")); // Should expect an error
            pause();

            System.out.println("Unregister a student from a restricted course that they are registered to, and which has at least two students in the queue.");
            System.out.println(c.unregister("2222222222", "CCC777")); // Should expect an error
            pause();


            System.out.println("Register again to the same course and check that the student gets the correct (last) position in the waiting list");
            System.out.println(c.register("2222222222", "CCC777"));
            pause();


            System.out.println("Unregister and re-register the same student for the same restricted course, and check that the student is first removed and then ends up in the same position as before (last)");
            System.out.println(c.unregister("2222222222", "CCC777"));
            pause();

            System.out.println("Unregister and re-register the same student for the same restricted course, and check that the student is first removed and then ends up in the same position as before (last)");
            System.out.println(c.register("2222222222", "CCC777"));
            pause();


            System.out.println("Unregister a student from an overfull course, i.e. one with more students registered than there are places on the course (you need to set this situation up in the database directly). Check that no student was moved from the queue to being registered as a result");
            System.out.println(c.register_direct("1111111111", "CCC777"));
            pause();

            System.out.println("Unregister a student from an overfull course, i.e. one with more students registered than there are places on the course (you need to set this situation up in the database directly). Check that no student was moved from the queue to being registered as a result");
            System.out.println(c.unregister("1111111111", "CCC777"));
            pause();


            System.out.println("Unregister with the SQL injection you introduced, causing all (or almost all?) registrations to disappear");
            System.out.println(c.SQLinjection("1111111111", "CCC777' OR 'a' = 'a"));
            pause();


            /*

            System.out.println(c.unregister("2222222222", "CCC333"));
            pause();

            prettyPrint(c.getInfo("2222222222"));
            pause();

            System.out.println(c.register("2222222222", "CCC333"));
             */






        } catch (ClassNotFoundException e) {
            System.err.println("ERROR!\nYou do not have the Postgres JDBC driver (e.g. postgresql-42.2.18.jar) in your runtime classpath!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }



    public static void pause() throws Exception{
        System.out.println("PRESS ENTER");
        while(System.in.read() != '\n');
    }

    // This is a truly horrible and bug-riddled hack for printing JSON.
    // It is used only to avoid relying on additional libraries.
    // If you are a student, please avert your eyes.
    public static void prettyPrint(String json){
        System.out.print("Raw JSON:");
        System.out.println(json);
        System.out.println("Pretty-printed (possibly broken):");

        int indent = 0;
        json = json.replaceAll("\\r?\\n", " ");
        json = json.replaceAll(" +", " "); // This might change JSON string values :(
        json = json.replaceAll(" *, *", ","); // So can this

        for(char c : json.toCharArray()){
            if (c == '}' || c == ']') {
                indent -= 2;
                breakline(indent); // This will break string values with } and ]
            }

            System.out.print(c);

            if (c == '[' || c == '{') {
                indent += 2;
                breakline(indent);
            } else if (c == ',' && !COMPACT_OBJECTS)
                breakline(indent);
        }

        System.out.println();
    }

    public static void breakline(int indent){
        System.out.println();
        for(int i = 0; i < indent; i++)
            System.out.print(" ");
    }
}