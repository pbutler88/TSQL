DECLARE @BODY Varchar(1000),
		@FROM Varchar(255),
		@TO Varchar(255),
		@SUBJECT Varchar(255)

SET @BODY = 'This is a test email'   
SET @FROM = 'Paul_Butler@YourDomain.com'  
SET @TO = 'Paul_Butler@YourDomain.com;'  
SET @SUBJECT = 'Test' 
     
PRINT 'MAIL SENT'  
EXEC sp_send_cdosysmail @FROM, @TO, @SUBJECT, @BODY  
