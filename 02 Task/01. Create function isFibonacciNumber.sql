SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		А.В. Дроботов
-- Create date: 04.06.2026
-- Description:	Проверка значениям на число Фибоначчи
-- =============================================

-- для многоразового использования при тестировании и обновлении на проде
IF OBJECT_ID(N'dbo.isFibonacciNumber', N'FN') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.isFibonacciNumber
END
GO

CREATE FUNCTION isFibonacciNumber
(
	-- Параметры функции
	@pnumValueForCheck BIGINT
)
RETURNS BIT
AS
BEGIN
	-- временное хранилище возвращаемого значения
	DECLARE @boolResult BIT
	-- переменные для расчета числ Фибаначчи
	DECLARE @numN1 BIGINT = 1
	DECLARE @numN2 BIGINT = 1
	DECLARE @numN3 BIGINT = 1

	-- по умолчанию определим что число не принадлежит множеству чисел Фибоначчи
	SELECT @boolResult = 0

	IF @pnumValueForCheck >= 1
	BEGIN
	  WHILE @pnumValueForCheck > @numN2
	  BEGIN
	    SET @numN3 = @numN1 + @numN2
		SET @numN1 = @numN2
		SET @numN2 = @numN3
	  END
	  IF @pnumValueForCheck = @numN2
	  BEGIN
	    SET @boolResult = 1
	  END
	END

	-- Return the result of the function
	RETURN @boolResult

END
GO

