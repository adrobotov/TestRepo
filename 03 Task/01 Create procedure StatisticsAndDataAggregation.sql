SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		А.В.  Дроботов
-- Create date: 05.06.2026
-- Description:	Решение третьей задачи тестового задания
-- =============================================

-- удаляем процедуру если она существует
IF OBJECT_ID(N'dbo.StatisticsAndDataAggregation', N'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.StatisticsAndDataAggregation
END
GO

CREATE PROCEDURE StatisticsAndDataAggregation 
AS
BEGIN
    -- объявляем переменные необходимы во вреемя расчетов
    DECLARE @numMaxClient bigint = 0
	DECLARE @numMaxGood   bigint = 0
	DECLARE @numI         bigint = 0
	DECLARE @numMaxRows   bigint = 1000000 -- кол-во добавляемых заказов

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- удаляем таблицу заказов если она существует
	IF OBJECT_ID(N'dbo.orders', N'U') IS NOT NULL
    BEGIN
      DROP TABLE dbo.orders
    END

	-- удаляем таблицу клиентов если она существует
	IF OBJECT_ID(N'dbo.clients', N'U') IS NOT NULL
    BEGIN
      DROP TABLE dbo.clients
    END

	-- удаляем таблицу товаров если она существует
	IF OBJECT_ID(N'dbo.goods', N'U') IS NOT NULL
    BEGIN
      DROP TABLE dbo.goods
    END

	-- создаем таблицу клиентов
	CREATE TABLE dbo.clients(
	  id_clients bigint IDENTITY(1,1) NOT NULL,
	  name varchar(50) NOT NULL,
      CONSTRAINT PK_clients PRIMARY KEY (id_clients)
	) 
	
	-- Добавляем данные в таблицу клиентов
	INSERT INTO clients(name) VALUES ('Иван')
	INSERT INTO clients(name) VALUES ('Федор')
	INSERT INTO clients(name) VALUES ('Степан')
	INSERT INTO clients(name) VALUES ('Марья')
	INSERT INTO clients(name) VALUES ('Антон')
	INSERT INTO clients(name) VALUES ('Николай')
	INSERT INTO clients(name) VALUES ('Петр')
	INSERT INTO clients(name) VALUES ('Анна')
	INSERT INTO clients(name) VALUES ('Мария')
	INSERT INTO clients(name) VALUES ('Дмитрий')

	-- создаем таблицу товаров
	CREATE TABLE dbo.goods(
	  id_goods bigint IDENTITY(1,1) NOT NULL,
	  name varchar(50) NOT NULL,
      CONSTRAINT PK_goods PRIMARY KEY (id_goods)
	) 
	 
	-- Добавляем данные в таблицу товаров
	INSERT INTO goods(name) VALUES ('Масло моторное')
	INSERT INTO goods(name) VALUES ('Масло трансмиссионное')
	INSERT INTO goods(name) VALUES ('Антифриз')
	INSERT INTO goods(name) VALUES ('Жидкость тормозная')
	INSERT INTO goods(name) VALUES ('Стекло лобовое')
	INSERT INTO goods(name) VALUES ('Колодки тормозные')
	INSERT INTO goods(name) VALUES ('Бампер')
	INSERT INTO goods(name) VALUES ('Свеча зажигания')
	INSERT INTO goods(name) VALUES ('Аккумулятор')
	INSERT INTO goods(name) VALUES ('Фильтр масляный')
	INSERT INTO goods(name) VALUES ('Фильтр воздушный')

	-- создаем таблицу товаров
	CREATE TABLE dbo.orders(
	  id_orders bigint IDENTITY(1,1) NOT NULL,
	  id_clients bigint  NOT NULL,
	  id_goods bigint  NOT NULL,
	  CONSTRAINT PK_orders PRIMARY KEY (id_orders),
	  CONSTRAINT FK_orders_goods FOREIGN KEY(id_goods) REFERENCES dbo.goods (id_goods),
	  CONSTRAINT FK_orders_clients FOREIGN KEY(id_clients) REFERENCES dbo.clients (id_clients)
	)
	
	-- вычисляем максимального номер клиента
	SELECT @numMaxClient = MAX(c.id_clients) from clients c

	-- вычисляем максимального номер товара
	SELECT @numMaxGood = MAX(g.id_goods) from goods g

	-- добавляем случайные заказы
	WHILE @numI < @numMaxRows
	BEGIN
	  INSERT INTO orders(id_clients, id_goods) VALUES(RAND()*@numMaxClient+1, RAND()*@numMaxGood+1)
	  SET @numI = @numI + 1 
	END

	-- ускоряет работу внутреннего запроса, строим после заполнения данными чтобы не замедлять вставку
	CREATE INDEX idx_clients_orders ON dbo.orders
		(
			id_clients ASC,
			id_orders ASC
		)

	-- собственно сам запрос на статистику и агрегацию
	SELECT top 5 c.name, t.count_orders
	  FROM (SELECT o.id_clients as id_clients, COUNT(o.id_orders) as count_orders
	          FROM orders o
		    GROUP BY o.id_clients) as t
      INNER JOIN clients as c on c.id_clients = t.id_clients
	  ORDER BY t.count_orders


	-- удаляем таблицу заказов если она существует
	IF OBJECT_ID(N'dbo.orders', N'U') IS NOT NULL
    BEGIN
      DROP TABLE dbo.orders
    END

	-- удаляем таблицу товаров
	IF OBJECT_ID(N'dbo.goods', N'U') IS NOT NULL
    BEGIN
      DROP TABLE dbo.goods
    END

	-- удаляем таблицу клиентов
	IF OBJECT_ID(N'dbo.clients', N'U') IS NOT NULL
    BEGIN
      DROP TABLE dbo.clients
    END

END
GO
