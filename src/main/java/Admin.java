import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class Admin {
    private JButton backButton;
    private JPanel panel;
    private JTabbedPane tabbedPane1;
    private JTextField queryTextField;
    private JButton callButton;
    private JTable res;
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
                handler.
            }
        });
    }

    void setVisible(boolean vis){
        frame.setVisible(vis);
    }
}
