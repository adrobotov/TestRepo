SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		А.В. Дроботов (оптимизировано)
-- Create date: 04.06.2026
-- Description:	Скалярная функция проверки значения на принадлежность к числам Фибоначчи
-- =============================================

-- Для многоразового использования при тестировании и обновлении на проде
IF OBJECT_ID(N'dbo.isFibonacciNumber', N'FN') IS NOT NULL
BEGIN
    DROP FUNCTION dbo.isFibonacciNumber
END
GO

CREATE FUNCTION dbo.isFibonacciNumber
(
    @pnumValueForCheck BIGINT
)
RETURNS BIT
AS
BEGIN
    -- 1. Обработка граничных и отрицательных значений
    -- Отрицательные числа не являются числами Фибоначчи
    IF @pnumValueForCheck < 0
        RETURN 0;

    -- 0 и 1 являются числами Фибоначчи по математическому определению (F0 и F1)
    IF @pnumValueForCheck = 0 OR @pnumValueForCheck = 1
        RETURN 1;

    -- 2. Инициализация переменных для расчета
    DECLARE @numN1 BIGINT = 1;
    DECLARE @numN2 BIGINT = 1;
    DECLARE @numN3 BIGINT;

    -- 3. Цикл генерации чисел Фибоначчи
    WHILE @pnumValueForCheck > @numN2
    BEGIN
        -- КРИТИЧЕСКАЯ ЗАЩИТА ОТ ПЕРЕПОЛНЕНИЯ ТИПА BIGINT:
        -- 93-е число Фибоначчи превышает максимальное значение BIGINT (9 223 372 036 854 775 807).
        -- Если (Целевое число - текущее число Фибоначчи) < предыдущее число,
        -- то следующее число Фибоначчи (@numN1 + @numN2) заведомо превысит целевое.
        -- Мы прерываем цикл досрочно, избегая фатальной ошибки переполнения 
        -- и экономя процессорное время.
        IF @pnumValueForCheck - @numN2 < @numN1
            BREAK;

        SET @numN3 = @numN1 + @numN2;
        SET @numN1 = @numN2;
        SET @numN2 = @numN3;
    END

    -- 4. Проверка на точное совпадение после завершения цикла
    IF @pnumValueForCheck = @numN2
        RETURN 1;

    -- Если совпадения не найдено, возвращаем 0 (False)
    RETURN 0;
END
GO