BEGIN TRY
    BEGIN TRANSACTION;
      USE master;
            
      DECLARE @Commit           BIT,
				@ShowDetails    BIT,
                @TrackingID     VARCHAR(7),
                @Developer      Varchar(50)
                 
      Select @Commit            = 0,
             @ShowDetails       = 1,
             @TrackingID        = 'ABC123',
             @Developer         = 'Paul Butler'

         
      If @ShowDetails = 1
            BEGIN
				Select 'BEFORE' As Result
            END

		--PERFORM ACTIONS
		DECLARE curRequest INSENSITIVE Cursor FOR 

		SELECT TOP 5 obj.name
		FROM sys.sysobjects AS obj
		WHERE obj.name LIKE 'a%'
				
		Open curRequest

		DECLARE @Name VARCHAR(255)

		While 1 = 1
			BEGIN
				Fetch NEXT FROM curRequest INTO @Name
				IF (@@FETCH_STATUS <> 0)
					Break

					--Add any logic here to handle row by row changes			
					SELECT @Name
				     		 
			END

		CLOSE curRequest
		DEALLOCATE curRequest
		         
      If @ShowDetails = 1
            BEGIN
                Select 'AFTER' As Result;
            END

      If @Commit = 1
            BEGIN
                COMMIT TRANSACTION;
                Select @TrackingID + ' Transaction Completed' As TransactionStatus;
            END
      Else
            BEGIN
                  ROLLBACK TRANSACTION;
                  Select @TrackingID + ' Transaction Rolled Back' As TransactionStatus;
          END
          
END TRY
BEGIN CATCH

	ROLLBACK TRAN
	SELECT 'ERROR: Please contact ' + @Developer + ' For Tracking number' + @TrackingID

END CATCH;
