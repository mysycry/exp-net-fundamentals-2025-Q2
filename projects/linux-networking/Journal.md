## Linux Firewall Rules

### Goal

We want to see how easy or difficult it is to manage Azure firewall rules and linux firewall rules


### Considerations

We launch Ubuntu VM in Azure, We aren't sure what is installed by default.



## Steps Performed

1. **Created an Azure Ubuntu VM**  
   - Deployed an Ubuntu server in Azure.

2. **Configured Network Security Group (NSG)**  
   - Allowed inbound traffic for:
     - SSH (TCP/22)
     - HTTP server (TCP/8000)
     - ICMP (Ping)

3. **Deployed a Simple Website**
   - Created an `index.html` file with a "Hello World!" message.
   - Started the Python HTTP server using:
     ```bash
     python3 -m http.server 8000
     ```

4. **Accessed the Website**
   - Retrieved the public IP of the VM.
   - Opened `http://<VM_IP>:8000` in a browser to verify the site is accessible from outside.

## Screenshots

![inbound rules](assets/added%20inbound%20rules.png)
- This screenshot shows the inbound security rules configured for the Azure Ubuntu VM's Network Security Group (NSG). It allows SSH (port 22), HTTP traffic on port 8000, and ICMP (ping) from any source to enable remote access and testing.


![inbound rules](assets/http.server%20on%20ssh,%20curl%20outside,%20and%20check%20ip%20address%20on%20the%20browser.png)

- This screenshot confirms that the Python HTTP server running on port 8000 is serving the index.html file. The website displays “Hello World!” in a browser, and both PowerShell and the VM terminal show successful HTTP requests, proving the site is reachable from the internet.


## Outcomes

We able to open port 7000,8000 in GCP firewall rules

We were able to use curl outside of the server(in my local machine) and reach the website with port 8000

We were able to block port 8000 on iptables

We were able to redirect from 7000 externally to 8000 using iptables

We could not combine port 8000 block and redirect 7000 to 8000 but we suspect its possible.

It seems that iptables is easy when utilizing a AI Coding Assistant eg. ChatGPT so there is no need for ufw unless we didn't have access to an LLM and we wanted to simply use man to quickly learn how to chnage rules or have an easy to remember how to change rules.