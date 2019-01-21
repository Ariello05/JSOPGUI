import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Admin {
    private JButton backButton;
    private JPanel panel;
    private JTabbedPane tabbedPane1;
    private JTextArea queryTextField;
    private JButton callButton;
    private JTable table1;
    private JPanel tablePanel;
    private JButton BusAdd;
    private JTextField busType;
    private JTextField busID;
    private JButton kierowcaAdd;
    private JTextField kierowcaNazwa;
    private JTextField kierowcaID;
    private JTextField liniaID;
    private JButton liniaAdd;
    private JTextField przystanekID;
    private JButton przystanekAdd;
    private JTextField przystanekNazwa;
    private JFrame frame;

    Admin(final ActionsHandler handler, boolean visibleOnStart){
        frame = new JFrame("Admin");
        frame.setContentPane(panel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(visibleOnStart);

        backButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                handler.goToMenu();
            }
        });

        callButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                ResultSet rs = handler.callQuery(queryTextField.getText());
                TableBuilder tb = new TableBuilder();
                try {
                    table1.setModel(tb.buildTableModel(rs));

                } catch (SQLException e1) {
                    e1.printStackTrace();//inform client of problem
                }
            }
        });
        BusAdd.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                StringBuilder sb = new StringBuilder();
                sb.append("INSERT INTO pojazd VALUES(\'");
                sb.append(busID.getText());
                sb.append("\',\'");
                sb.append(busType.getText());
                sb.append("\');");
                if(handler.updateQuery(sb.toString())){
                    System.out.println("Success!");
                };
            }
        });
    }

    void setVisible(boolean vis){
        frame.setVisible(vis);
    }

}


