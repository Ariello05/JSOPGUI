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
    private JTextField ipTextField;
    private JTextField portTextField;
    private JTextField dataBaseName;
    private JFrame frame;

    Login(final ActionsHandler handler, boolean visibleOnStart){
        frame = new JFrame("Login");
        frame.setContentPane(panel);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.pack();
        frame.getRootPane().setDefaultButton(connectButton);

        connectButton.addActionListener(e -> {
            String str = (String) comboBox1.getSelectedItem();
            DataConnection dc;

            if(str.equals("Manager")) {
                String pass = String.valueOf(passwordTextField.getPassword());
                dc = new DataConnection(
                        ipTextField.getText(),
                        portTextField.getText(),
                        dataBaseName.getText(),
                        "Manager",
                        passwordTextField.getPassword()
                );

                handler.requestConnection(UserType.MANAGER, dc);
            }
            else if(str.equals("Passenger")) {
                String pass = String.valueOf(passwordTextField.getPassword());
                dc = new DataConnection(
                        ipTextField.getText(),
                        portTextField.getText(),
                        dataBaseName.getText(),
                        "Passenger",
                        passwordTextField.getPassword()
                );

                handler.requestConnection(UserType.USER, dc);
            }
            else if(str.equals("Root")) {
                String pass = String.valueOf(passwordTextField.getPassword());
                dc = new DataConnection(
                        ipTextField.getText(),
                        portTextField.getText(),
                        dataBaseName.getText(),
                        "root",
                        passwordTextField.getPassword()
                );

                handler.requestConnection(UserType.ROOT, dc);
            }
        });

        setVisible(visibleOnStart);
    }

    void setVisible(boolean vis){
        frame.setVisible(vis);
        passwordTextField.requestFocusInWindow();
    }
}
