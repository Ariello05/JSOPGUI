import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/*
Admin
Manager
Passenger
 */

public class Login {
    private JComboBox comboBox1;
    private JPasswordField passwordTextField;
    private JButton connectButton;
    private JPanel panel;
    private JPasswordField ipTextField;
    private JPasswordField portTextField;
    private JFrame frame;

    Login(final ActionsHandler handler, boolean visibleOnStart){
        frame = new JFrame("Login");
        frame.setContentPane(panel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.setVisible(visibleOnStart);

        connectButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                String str = (String) comboBox1.getSelectedItem();
                DataConnection dc;

                if(str.equals("Manager")) {
                    dc = new DataConnection(
                            ipTextField.getSelectedText(),
                            portTextField.getSelectedText(),
                            "Hardcoded",
                            "Manager",
                            passwordTextField.getSelectedText()
                    );

                    handler.requestConnection(UserType.MANAGER, dc);
                }
                else if(str.equals("Passenger")) {
                    dc = new DataConnection(
                            ipTextField.getSelectedText(),
                            portTextField.getSelectedText(),
                            "Hardcoded",
                            "Passenger",
                            passwordTextField.getSelectedText()
                    );

                    handler.requestConnection(UserType.USER, dc);
                }
            }
        });

    }

    void setVisible(boolean vis){
        frame.setVisible(vis);
    }
}
