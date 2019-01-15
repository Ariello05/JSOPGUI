import java.sql.*;

public class DBConnector {
    Connection conn;

    DBConnector(){
    }

    DBConnector(DataConnection dc){
        connect(dc);
    }

    void dropConnection(){
        try {
            conn.close();
        } catch (SQLException e) {
            System.out.println("Unsuccessful connection");
        }
    }

    boolean connect(DataConnection dc){
        try {
            conn = DriverManager.getConnection(
                    "jdbc:mysql://"+dc.getIp()+":"+dc.getPort()+"/"+dc.getDatabaseName()+"?useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=UTC",
                    dc.getUser(),
                    String.valueOf(dc.getPassword()));
            System.out.println("Successful connection");
            return true;
        }
        catch(SQLException ex) {
            System.out.println("CANNOT CONNECT: " + ex.getMessage());
            return  false;
        }

    }

    /*
    void dummy(){
        Statement stmt = conn.createStatement();

        String testquery = "Select name, lastname, score From Tests";
        ResultSet res = stmt.executeQuery(testquery);
        int rowCount = 0;
        while(res.next()) {
            String n = res.getString("name");
            String l = res.getString("lastname");
            int score = res.getInt("score");
            ++rowCount;
        }
    }
    */

}
