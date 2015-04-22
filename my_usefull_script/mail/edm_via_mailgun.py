# -*- coding: utf-8 -*-  
from smtplib import SMTP
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import base64

def render_by_mail(source_html, to_mail):
    encode_to_mail = base64.b64encode(to_mail, 'utf-8')
    html = source_html.replace('__ENCODE_EMAIL__', encode_to_mail)
    return html

def get_html_from_file():
    edm_content_file = '/tmp/edmfor1111.html.WebQQ'
    return open(edm_content_file, 'r').read()

def send_message_via_smtp():
    from_mail = 'noreply@msun-inc.com'
    smtp = SMTP('smtp.mailgun.org', 587)
    smtp.login('postmaster@msun.mailgun.org', '2r8rps8mu5k4')
    source_html = get_html_from_file()
    edm_fileh = open('/tmp/edm.mail')
    for to_mail in edm_fileh:
        to_mail = to_mail.strip()
        msg = MIMEMultipart('alternative')
        msg['Subject'] = u'光棍节，购物有保障，敢降就敢赔！— msun'
        msg['From'] = u'msun <noreplay@msun.com>'
        msg['To'] = to_mail
        html = render_by_mail(source_html, to_mail)
        mail_body = MIMEText(html, 'html', 'utf-8')
        msg.attach(mail_body)
        smtp.sendmail(from_mail, to_mail, msg.as_string())
        print to_mail
    smtp.quit()

if __name__ == '__main__':
    send_message_via_smtp()

