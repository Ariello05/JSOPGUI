
public class DataConnection{
    private String ip;
    private String port;
    private String user;
    private String db;
    private char[] password;

        /**
         *
         * @param ip databaseIP
         * @param port databasePort
         * @param db databaseName
         * @param user loginName
         * @param password password
         */
    DataConnection(String ip, String port, String db, String user, char[] password) {
        this.ip = ip;
        this.port = port;
        this.db = db;
        this.user = user;
        this.password = password;
    }

    public String getIp(){
        return ip;
    }

    public String getPort() {
        return port;
    }

    public String getUser(){
        return user;
    }

    public String getDatabaseName() {
        return db;
    }

    public char[] getPassword() {
        return password;
    }

}
