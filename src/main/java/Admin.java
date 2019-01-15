import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class Admin {
    private JButton backButton;
    private JPanel panel;
    private JTabbedPane tabbedPane1;
    private JComboBox comboBox1;
    private JButton callButton;
    private JTable table1;
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

    }

    void setVisible(boolean vis){
        frame.setVisible(vis);
    }
}
