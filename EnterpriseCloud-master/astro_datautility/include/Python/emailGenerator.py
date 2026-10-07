from email.message import EmailMessage
from smtplib import SMTP
import sys

def main(From:str,To:str,cc:str,subject:str,content:str):
    msg = EmailMessage()
    msg['From'] = From    
    msg['To'] = To
    msg['Subject'] = subject
    msg['CC']=cc
    server = SMTP('smtp.us.tel.com','25')
    msg.set_content(content)
    server.send_message(msg)
    server.quit()
if __name__ == "__main__":
    args = sys.argv[1:]
    From:str = args[0]
    To:str = args[1]
    cc:str = args[2]
    subject:str = args[3]
    content:str = args[4]
    main(From,To,cc,subject,content)