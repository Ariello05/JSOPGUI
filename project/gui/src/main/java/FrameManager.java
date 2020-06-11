public class FrameManager {
    Admin adminPanel;
    Client clientPanel;
    Login loginPanel;

    FrameManager(){
        DBConnector db = new DBConnector();
        ActionsHandler handler = new ActionsHandler(this, db);

        loginPanel = new Login(handler,true);
        clientPanel = new Client(handler,false);
        adminPanel = new Admin(handler,false);
    }

    FrameManager(ActionsHandler handler){
        loginPanel = new Login(handler,true);
        clientPanel = new Client(handler,false);
        adminPanel = new Admin(handler,false);
    }

    void showAdminPanel(boolean bool){
        adminPanel.setVisible(bool);
    }

    void showClientPanel(boolean bool){
        clientPanel.setVisible(bool);
    }

    void showLoginPanel(boolean bool){
        loginPanel.setVisible(bool);
    }

}
