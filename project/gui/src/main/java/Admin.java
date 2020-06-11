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
    private JRadioButton radioQuery;
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
                if(radioQuery.isSelected()){
                    ResultSet rs = handler.callQuery(queryTextField.getText());
                    TableBuilder tb = new TableBuilder();
                    try {
                        table1.setModel(tb.buildTableModel(rs));

                    } catch (SQLException e1) {
                        e1.printStackTrace();//inform client of problem
                    }
                }else{

                    boolean res = handler.updateQuery(queryTextField.getText());
                    if(res){
                        System.out.println("Success!");
                    }
                    else{
                       System.out.println("No rows changed!");
                    }
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
                }
                else{
                    System.out.println("No rows changed!");
                }
            }
        });
        kierowcaAdd.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                StringBuilder sb = new StringBuilder();
                sb.append("INSERT INTO kierowca VALUES(\'");
                sb.append(kierowcaID.getText());
                sb.append("\',\'");
                sb.append(kierowcaNazwa.getText());
                sb.append("\');");
                if(handler.updateQuery(sb.toString())){
                    System.out.println("Success!");
                }
                else{
                    System.out.println("No rows changed!");
                }
            }
        });
        liniaAdd.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                StringBuilder sb = new StringBuilder();
                sb.append("INSERT INTO linia VALUES(");
                sb.append(liniaID.getText());
                sb.append(");");
                if(handler.updateQuery(sb.toString())){
                    System.out.println("Success!");
                }
                else{
                    System.out.println("No rows changed!");
                }
            }
        });
        przystanekAdd.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                StringBuilder sb = new StringBuilder();
                sb.append("INSERT INTO przystanek VALUES(\'");
                sb.append(przystanekID.getText());
                sb.append("\',\'");
                sb.append(przystanekNazwa.getText());
                sb.append("\');");
                if(handler.updateQuery(sb.toString())){
                    System.out.println("Success!");
                }
                else{
                    System.out.println("No rows changed!");
                }
            }
        });
    }

    void setVisible(boolean vis){
        frame.setVisible(vis);
    }

}


