import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class Client {
    private JPanel panel;
    private JButton backButton;
    private JComboBox comboBox1;
    private JComboBox comboBox2;
    private JTextField textField1;
    private JTextField textField2;
    private JButton generateButton;
    private JTabbedPane tabbedPane1;
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

    }

    void setVisible(boolean vis){
        frame.setVisible(vis);
    }
}
