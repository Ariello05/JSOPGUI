public class ActionsHandler {
    private FrameManager gui;
    private DBConnector db;

    private boolean set;

    ActionsHandler(){
        set = false;
    }

    ActionsHandler(FrameManager gui, DBConnector db){
        setLink(gui, db);
    }

    public void setLink(FrameManager gui, DBConnector db){
        this.gui = gui;
        this.db = db;
        set = true;
    }

    public void print(String si){
        System.out.println(si);
    }

    public void requestConnection(UserType type, DataConnection dc){
        if(!set)
            return;

        switch (type){
            case ROOT:
                    if(db.connect(dc))
                        gui.focusOnClientPanel();
                break;
            case MANAGER:
                   if(db.connect(dc))
                       gui.focusOnAdminPanel();
                break;
            case USER:
                   if(db.connect(dc))
                       gui.focusOnClientPanel();
                break;
        }
    }

    public void goToMenu(){
        gui.focusOnLoginPanel();
    }
}

