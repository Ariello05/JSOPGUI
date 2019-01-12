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

    void focusOnAdminPanel(){
        adminPanel.setVisible(true);
        clientPanel.setVisible(false);
        loginPanel.setVisible(false);
    }

    void focusOnClientPanel(){
        adminPanel.setVisible(false);
        clientPanel.setVisible(true);
        loginPanel.setVisible(false);
    }

    void focusOnLoginPanel(){
        adminPanel.setVisible(false);
        clientPanel.setVisible(false);
        loginPanel.setVisible(true);
    }

}
