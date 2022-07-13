namespace NumatoEthernetRelayControl
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.BTRelayOn00 = new System.Windows.Forms.Button();
            this.BTRelayOff00 = new System.Windows.Forms.Button();
            this.BTRelayOff01 = new System.Windows.Forms.Button();
            this.BTRelayOn01 = new System.Windows.Forms.Button();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.LBResponse = new System.Windows.Forms.Label();
            this.BTReadRelays = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // BTRelayOn00
            // 
            this.BTRelayOn00.Location = new System.Drawing.Point(27, 55);
            this.BTRelayOn00.Name = "BTRelayOn00";
            this.BTRelayOn00.Size = new System.Drawing.Size(75, 23);
            this.BTRelayOn00.TabIndex = 0;
            this.BTRelayOn00.Text = "Relay 0 ON";
            this.BTRelayOn00.UseVisualStyleBackColor = true;
            this.BTRelayOn00.Click += new System.EventHandler(this.BTConnect_Click);
            // 
            // BTRelayOff00
            // 
            this.BTRelayOff00.Location = new System.Drawing.Point(136, 55);
            this.BTRelayOff00.Name = "BTRelayOff00";
            this.BTRelayOff00.Size = new System.Drawing.Size(75, 23);
            this.BTRelayOff00.TabIndex = 1;
            this.BTRelayOff00.Text = "Relay 0 Off";
            this.BTRelayOff00.UseVisualStyleBackColor = true;
            this.BTRelayOff00.Click += new System.EventHandler(this.BTRelayOff00_Click);
            // 
            // BTRelayOff01
            // 
            this.BTRelayOff01.Location = new System.Drawing.Point(136, 111);
            this.BTRelayOff01.Name = "BTRelayOff01";
            this.BTRelayOff01.Size = new System.Drawing.Size(75, 23);
            this.BTRelayOff01.TabIndex = 3;
            this.BTRelayOff01.Text = "Relay 1 Off";
            this.BTRelayOff01.UseVisualStyleBackColor = true;
            this.BTRelayOff01.Click += new System.EventHandler(this.BTRelayOff01_Click);
            // 
            // BTRelayOn01
            // 
            this.BTRelayOn01.Location = new System.Drawing.Point(27, 111);
            this.BTRelayOn01.Name = "BTRelayOn01";
            this.BTRelayOn01.Size = new System.Drawing.Size(75, 23);
            this.BTRelayOn01.TabIndex = 2;
            this.BTRelayOn01.Text = "Relay 1 ON";
            this.BTRelayOn01.UseVisualStyleBackColor = true;
            this.BTRelayOn01.Click += new System.EventHandler(this.BTRelayOn01_Click);
            // 
            // timer1
            // 
            this.timer1.Enabled = true;
            this.timer1.Interval = 1000;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // LBResponse
            // 
            this.LBResponse.AutoSize = true;
            this.LBResponse.Location = new System.Drawing.Point(27, 161);
            this.LBResponse.Name = "LBResponse";
            this.LBResponse.Size = new System.Drawing.Size(55, 13);
            this.LBResponse.TabIndex = 5;
            this.LBResponse.Text = "Response";
            // 
            // BTReadRelays
            // 
            this.BTReadRelays.Location = new System.Drawing.Point(136, 151);
            this.BTReadRelays.Name = "BTReadRelays";
            this.BTReadRelays.Size = new System.Drawing.Size(112, 23);
            this.BTReadRelays.TabIndex = 6;
            this.BTReadRelays.Text = "Read Relays";
            this.BTReadRelays.UseVisualStyleBackColor = true;
            this.BTReadRelays.Click += new System.EventHandler(this.BTReadRelays_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(290, 232);
            this.Controls.Add(this.BTReadRelays);
            this.Controls.Add(this.LBResponse);
            this.Controls.Add(this.BTRelayOff01);
            this.Controls.Add(this.BTRelayOn01);
            this.Controls.Add(this.BTRelayOff00);
            this.Controls.Add(this.BTRelayOn00);
            this.Name = "Form1";
            this.Text = "Form1";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Form1_FormClosing);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button BTRelayOn00;
        private System.Windows.Forms.Button BTRelayOff00;
        private System.Windows.Forms.Button BTRelayOff01;
        private System.Windows.Forms.Button BTRelayOn01;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.Label LBResponse;
        private System.Windows.Forms.Button BTReadRelays;
    }
}

