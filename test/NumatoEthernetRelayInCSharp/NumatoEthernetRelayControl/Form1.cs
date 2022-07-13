using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MinimalisticTelnet;

namespace NumatoEthernetRelayControl
{
    public partial class Form1 : Form
    {
        //Change the following specific to your system:
        String HostName = "192.168.51.35";
        String UserName = "admin";
        String Password = "admin";
        int PortNum = 23;

        Color StartBackColor = Color.LightGray;
        public Form1()
        {
            InitializeComponent();
            StartBackColor = BTRelayOff00.BackColor;
            SendCommand("relay readall "); //get started.
        }
      //create a new telnet connection to hostname on port "23"
        TelnetConnection tc = null;


        private void BTConnect_Click(object sender, EventArgs e)
        {
            LBResponse.Text = SendCommand("relay on 0");
        }

        private void BTRelayOff00_Click(object sender, EventArgs e)
        {
            LBResponse.Text = SendCommand("relay off 0");
        }

        private void BTRelayOn01_Click(object sender, EventArgs e)
        {
            LBResponse.Text = SendCommand("relay on 1");
        }

        private void BTRelayOff01_Click(object sender, EventArgs e)
        {
            LBResponse.Text = SendCommand("relay off 1");
        }
        private void BTReadRelays_Click(object sender, EventArgs e)
        {
            if (tc != null) LBResponse.Text = SendCommand("relay readall "); // the space at the end is important for some reason!
        }

        bool DoingCommand = false;
        String SendCommand(String Command)
        {
            if (DoingCommand) return "Busy";
            DoingCommand = true;

            try
            {
                if (tc == null)
                {
                    //create a new telnet connection to hostname "gobelijn" on port "23"
                    tc = new TelnetConnection(HostName, PortNum);
                    //login with user "root",password "rootpassword", using a timeout of 100ms, and show server output
                    string s = tc.Login(UserName, Password, 100);

                    // server output should end with "$" or ">", otherwise the connection failed

                    String prompt = s.TrimEnd();
                    prompt = s.Substring(prompt.Length - 1, 1);
                    if (prompt != "$" && prompt != ">")
                    {
                        tc.TelnetClose();
                        DoingCommand = false;
                        return "Connection to Relay Board Failed";
                    }
                }
                tc.WriteLine(Command);
                string s2 = tc.Read();
                if (s2 == null) s2 = "Problem With Socket!";
                DoingCommand = false;
                return s2;
            }
            catch (Exception e)
            {
                return "Exeption! Mess=" + e.Message;
            }
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (tc != null)
            {
                String s = "";
                s = SendCommand("relay readall "); // the space at the end is important for some reason!
                if(s != null && s.Length > 4)
                {
                    s = s.Substring(0, 4);
                    try
                    {
                        int r = Convert.ToInt32(s, 16);
                        if ((r & 1) > 0)
                        {
                            BTRelayOn00.BackColor = Color.LightGreen;
                            BTRelayOff00.BackColor = StartBackColor;
                        }
                        else
                        {
                            BTRelayOn00.BackColor = StartBackColor;
                            BTRelayOff00.BackColor = Color.LightGreen;
                        }
                        if ((r & 2) > 0)
                        {
                            BTRelayOn01.BackColor = Color.LightGreen;
                            BTRelayOff01.BackColor = StartBackColor;
                        }
                        else
                        {
                            BTRelayOn01.BackColor = StartBackColor;
                            BTRelayOff01.BackColor = Color.LightGreen;
                        }
                    }
                    catch
                    {

                    }
                }
            }
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            if(tc != null ) tc.TelnetClose();
        }

    }

}
