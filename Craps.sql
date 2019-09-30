DECLARE @Dice1 INT
DECLARE @Dice2 INT
DECLARE @DiceTotal INT

DECLARE @i INT = 1
DECLARE @PointStatus VARCHAR (3) = 'Off'
DECLARE @PointNumber INT
DECLARE @BetStatus VARCHAR(10)

DECLARE @WalletAmount MONEY = 200.00
DECLARE @PassLineBetAmount MONEY = 5.00

DECLARE @ShowAllDetails BIT = 0

WHILE @i <= 100
BEGIN
	SET @Dice1 = ROUND(RAND(CONVERT(VARBINARY,NEWID()))*6,0,1)+1
	SET @Dice2 = ROUND(RAND(CONVERT(VARBINARY,NEWID()))*6,0,1)+1
	SET @DiceTotal = @Dice1 + @Dice2

	--Place the bet the first time and after every loss
	IF ISNULL(@BetStatus,'Lose') = 'Lose'
	BEGIN
		SELECT @WalletAmount = @WalletAmount - @PassLineBetAmount
	END
		
	--Resolve Bet
	IF @PointStatus = 'Off'
		BEGIN 
			IF @DiceTotal IN (7,11)
				BEGIN
					SELECT @BetStatus = 'Win'
					SELECT @WalletAmount = @WalletAmount + @PassLineBetAmount
				END 
			IF @DiceTotal IN (2,3,12)
				BEGIN
					SELECT @BetStatus = 'Lose'
				END 
			IF @DiceTotal NOT IN (7,11,2,3,12)
				BEGIN 
					SELECT @BetStatus = 'Push'
					SELECT @PointStatus = 'On'
					SELECT @PointNumber = @DiceTotal
				END
		END
	ELSE --Point is On
		BEGIN
			IF @DiceTotal NOT IN (7, @PointNumber)
				BEGIN
					SELECT @BetStatus = 'Push'
				END

			IF @DiceTotal = 7
				BEGIN
					SELECT @BetStatus = 'Lose'
					SELECT @PointNumber = 0
					SELECT @PointStatus = 'Off'
				END

			IF @DiceTotal = @PointNumber
				BEGIN
					SELECT @BetStatus = 'Win'
					SELECT @PointNumber = 0
					SELECT @PointStatus = 'Off'
					SELECT @WalletAmount = @WalletAmount + @PassLineBetAmount
				END
			
		END

	IF @ShowAllDetails = 1
		BEGIN
			SELECT @i AS RollAttempt, 
					@Dice1 AS Dice1_Roll, 
					@Dice2 AS Dice2_Roll, 
					@Dice1 + @Dice2 AS DiceTotal, 
					@PointStatus AS PointStatus, 
					@PointNumber AS PointNumber, 
					@BetStatus AS BetStatus,
   					@PassLineBetAmount AS PassLineBetAmount,
					@WalletAmount AS WalletAmount
		END

	SELECT @i = @i + 1

	--Check wallet
	IF @WalletAmount <= 0.00
		BEGIN
			SELECT @i = 101
		END

END

		SELECT 'SUMMARY'
		SELECT @i AS RollAttempt, 
					@Dice1 AS Dice1_Roll, 
					@Dice2 AS Dice2_Roll, 
					@Dice1 + @Dice2 AS DiceTotal, 
					@PointStatus AS PointStatus, 
					@PointNumber AS PointNumber, 
					@BetStatus AS BetStatus,
   					@PassLineBetAmount AS PassLineBetAmount,
					@WalletAmount AS WalletAmount