BEGIN TRY
    BEGIN TRANSACTION;
      USE master;
            
      DECLARE @Commit           BIT,
				@ShowDetails    BIT,
                @TrackingID     Varchar(7),
                @Developer      Varchar(50),
				@RowCount		INT
                 
      Select @Commit            = 1,
             @ShowDetails       = 0,
             @TrackingID        = 'ABC123',
             @Developer         = 'Paul Butler'
               
      If @ShowDetails = 1
            BEGIN
				Select 'BEFORE' As Result
            END

		--Do stuff
		SELECT 'Doing Stuff'

		--Trap error
		Select @RowCount = @@ROWCOUNT
	
		If @RowCount != 1
		BEGIN
			RAISERROR ('Action Failed', 16, 1)
		END
				         
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
	SELECT 'ERROR with TrackingID: ' + @TrackingID + ' Please contact ' + @Developer

END CATCH;

 

