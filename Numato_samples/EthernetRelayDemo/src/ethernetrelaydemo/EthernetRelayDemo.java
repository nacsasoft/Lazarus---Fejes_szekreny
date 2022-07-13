/*

   License                                                                             
                                                                                       
   Copyright © 2018, Numato Systems Private Limited. All rights reserved.              
                                                                                       
   This software including all supplied files, Intellectual Property, know-how         
   Or part of thereof as applicable (collectively called SOFTWARE) in source           
   And/Or binary form with accompanying documentation Is licensed to you by            
   Numato Systems Private Limited (LICENSOR) subject To the following conditions.      
                                                                                       
   1. This license permits perpetual use of the SOFTWARE if all conditions in this     
       license are met. This license stands revoked In the Event Of breach Of any      
       of the conditions.                                                              
   2. You may use, modify, copy the SOFTWARE within your organization. This            
       SOFTWARE shall Not be transferred To third parties In any form except           
       fully compiled binary form As part Of your final application.                   
   3. This SOFTWARE Is licensed only to be used in connection with/executed on         
       supported products manufactured by Numato Systems Private Limited.              
       Using/ executing this SOFTWARE On/In connection With custom Or third party      
       hardware without the LICENSORs prior written permission Is expressly            
       prohibited.                                                                     
   4. You may Not download Or otherwise secure a copy of this SOFTWARE for the         
       purpose of competing with Numato Systems Private Limited Or subsidiaries in     
       any way such As but Not limited To sharing the SOFTWARE With competitors,       
       reverse engineering etc... You may Not Do so even If you have no gain           
       financial Or otherwise from such action.                                        
   5. DISCLAIMER                                                                       
   5.1. USING THIS SOFTWARE Is VOLUNTARY And OPTIONAL. NO PART OF THIS SOFTWARE        
       CONSTITUTE A PRODUCT Or PART Of PRODUCT SOLD BY THE LICENSOR.                   
   5.2. THIS SOFTWARE And DOCUMENTATION ARE PROVIDED “AS IS” WITH ALL FAULTS,          
       DEFECTS And ERRORS And WITHOUT WARRANTY OF ANY KIND.                            
   5.3. THE LICENSOR DISCLAIMS ALL WARRANTIES EITHER EXPRESS Or IMPLIED, INCLUDING     
       WITHOUT LIMITATION, ANY WARRANTY Of MERCHANTABILITY Or FITNESS For ANY          
       PURPOSE.                                                                        
   5.4. IN NO EVENT, SHALL THE LICENSOR, IT'S PARTNERS OR DISTRIBUTORS BE LIABLE OR    
       OBLIGATED FOR ANY DAMAGES, EXPENSES, COSTS, LOSS Of MONEY, LOSS OF TANGIBLE     
       Or INTANGIBLE ASSETS DIRECT Or INDIRECT UNDER ANY LEGAL ARGUMENT SUCH AS BUT    
       Not LIMITED TO CONTRACT, NEGLIGENCE, STRICT LIABILITY, CONTRIBUTION, BREACH     
       OF WARRANTY Or ANY OTHER SIMILAR LEGAL DEFINITION.  

    Java code demonstrating basic Relay features Of Numato Lab Ethernet Relay Module.

    Prerequisites                                       
    -------------  
   install JDK
   install Netbeans 
*/
package ethernetrelaydemo;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.net.telnet.TelnetClient;

/**
 *
 * @author Numato Lab
 */
public class EthernetRelayDemo {

    /**
     * @param args the command line arguments
     */
    static OutputStream outstr;
    static InputStream intstr;
    static TelnetClient tc;

    public static void main(String[] args) throws IOException {
        // TODO code application logic here

        tc = new TelnetClient(); //new TELNET object 
        String ipAddress = "169.254.1.1"; //IP Address
        int port = 23; //Telnet Port Number
        String relayNumber = "1"; //Change the Relay Number here when required
        
        try {
            //Telnet Connection
            tc.connect(ipAddress, port);
            outstr = tc.getOutputStream();
            intstr = tc.getInputStream();
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            if (tc != null) {
                // Buffer to store the response bytes.
                byte[] data = new byte[256];
                // Read the first batch of the TcpServer response bytes.
                int bytes = intstr.read(data, 0, data.length);
                String responseData = new String(data, 0, bytes);
                String result = responseData;
                if (responseData.contains("User Name: ")) {
                    String message = "admin"; //Device telnet user name
                    // Translate the passed message into ASCII and store it as a Byte array.
                    data = (new String(message + "\r\n")).getBytes("UTF-8");
                    // Send the message to the connected TcpServer. 
                    outstr.write(data, 0, data.length);
                    outstr.flush();
                }
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                data = new byte[256];

                // Read the first batch of the TcpServer response bytes.
                bytes = intstr.read(data, 0, data.length);
                responseData = new String(data, 0, bytes);
                result = result + responseData;
                if (responseData.contains("Password: ")) {
                    String message = "admin"; //Device telnet password
                    // Translate the passed message into ASCII and store it as a Byte array.
                    data = (new String(message + "\r\n")).getBytes("UTF-8");
                    // Send the message to the connected TcpServer. 
                    outstr.write(data, 0, data.length);
                    outstr.flush();
                }
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                data = new byte[256];
                bytes = intstr.read(data, 0, data.length);
                responseData = new String(data, 0, bytes);
                result = result + responseData;
                
                if(tc.isConnected())
                    System.out.println("Info: Connection (" + ipAddress + ") opened successfully...");            
            }
        } catch (IOException e) {
        }
        try {
            relayNumber = relayNumber.toUpperCase(); //Converts the relay_number(A to V) to upper case if user entered it as lower case.
            // Buffer to store the response bytes.
            byte[] data = new byte[256];

            //Relay on
            data = new byte[256];
            data = (new String("relay on " + relayNumber + "\r\n")).getBytes("UTF-8");
            System.out.println("Info: Command sent to relay on " + relayNumber);
            outstr.write(data, 0, data.length);
            outstr.flush();

            //Relay Read
            data = new byte[256];
            data = (new String("relay read " + relayNumber + "\r\n")).getBytes("UTF-8");
            System.out.println("Info: Command sent to relay read " + relayNumber);
            outstr.write(data, 0, data.length);
            outstr.flush();

            try {
                Thread.sleep(50);
            } catch (InterruptedException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

            data = new byte[256];
            int bytes = intstr.read(data, 0, data.length);
            String value = new String(data, 0, bytes);

            if (value.contains("on")) {
                System.out.println("ON");
            } else {
                System.out.println("OFF");
            }

            //Relay off
            data = new byte[256];
            data = (new String("relay off " + relayNumber + "\r\n")).getBytes("UTF-8");
            System.out.println("Info: Command sent to relay off " + relayNumber);
            outstr.write(data, 0, data.length);
            outstr.flush();

            //Relay Read
            data = new byte[256];
            data = (new String("relay read " + relayNumber + "\r\n")).getBytes("UTF-8");
            System.out.println("Info: Command sent to relay read " + relayNumber);
            outstr.write(data, 0, data.length);
            outstr.flush();

            try {
                Thread.sleep(50);
            } catch (InterruptedException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

            data = new byte[256];
            bytes = intstr.read(data, 0, data.length);
            String relayvalue = new String(data, 0, bytes);

            if (relayvalue.contains("on")) {
                System.out.println("ON");
            } else {
                System.out.println("OFF");
            }
            tc.disconnect(); //Telnet connection disconnect
            System.out.println("Info: Connection (" + ipAddress + ") closed successfully...");
        } catch (UnsupportedEncodingException ex) {
            Logger.getLogger(EthernetRelayDemo.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
