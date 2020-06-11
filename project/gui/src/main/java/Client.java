import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Client {
    private JPanel panel;
    private JButton backButton;
    private JTextField timeSchedule;
    private JTabbedPane tabbedPane1;
    private JTable table;
    private JTextField fromRoute;
    private JTextField toRoute;
    private JTextField liniaSchedule;
    private JTextField przystanekSchedule;
    private JButton routeButton;
    private JButton scheduleButton;
    private JFrame frame;

    Client(final ActionsHandler handler, boolean visibleOnStart){
        frame = new JFrame("Client");
        frame.setContentPane(panel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(visibleOnStart);

        backButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                handler.goToMenu();
            }
        });

        routeButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                StringBuilder sb = new StringBuilder();
                sb.append("call Select_CzasJazdy(\'");
                sb.append(fromRoute.getText());
                sb.append("\', \'");
                sb.append(toRoute.getText());
                sb.append("\');");
                ResultSet rs = handler.callQuery(sb.toString());
                TableBuilder tb = new TableBuilder();
                try {
                    table.setModel(tb.buildTableModel(rs));

                } catch (SQLException e1) {
                    e1.printStackTrace();//inform client of problem
                }
            }
        });
        scheduleButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                StringBuilder sb = new StringBuilder();
                sb.append("call Select_Terminarz(\'");
                sb.append(przystanekSchedule.getText());
                sb.append("\', \'");
                sb.append(timeSchedule.getText());
                sb.append("\', \'");
                sb.append(liniaSchedule.getText());
                sb.append("\');");
                ResultSet rs = handler.callQuery(sb.toString());
                TableBuilder tb = new TableBuilder();
                try {
                    table.setModel(tb.buildTableModel(rs));

                } catch (SQLException e1) {
                    e1.printStackTrace();//inform client of problem
                }

            }
        });
    }

    void setVisible(boolean vis){
        frame.setVisible(vis);
    }
}
