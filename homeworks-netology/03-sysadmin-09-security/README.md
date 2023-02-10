## Ответы на задания 03-sysadmin-09-security  
1. Регистрация прошла успешно, пароли сохраняются:  
![BIT](img/bitwarden.jpg)  
2. Настройка двухфакторной аутентификации прошла успешно:  
![2FA](img/bitwarden.jpg)  
3. Настройка apache сервера и https на самоподписанном сертификате прошла успешно:  
![HTTPSs](img/httpssite.jpg)  
4. Тестирование на TLS уязвимости произвольного сайта прошло успешно:  
![TLStest](img/testingsite.jpg)  
5. Сервер SSH устанавливается с помощью команды *sudo apt-get install ssh*  
Удалось подключиться к серверу по ранее сгенеренному сертификату:  
![SSHsrv](img/sshsrv.jpg)  
6. Файлы ключей переименованы, что отражено на скриншоте:  
![RNamekf](img/renemakf.jpg)  
Подключение к ssh серверу по hostname:  
![SSHhn](img/sshhostname.jpg)  
7. Захват пакетов в файл командой *sudo tcpdump -w enp0s3.pcap -c 100 -i enp0s3* представлен на скриншоте:  
![TCPd](img/dcpdump.jpg)  
Открытие enp0s3.pcap файла в Wireshark выглядит следующим образом:  
![WIREsh](img/wshark.jpg)  

