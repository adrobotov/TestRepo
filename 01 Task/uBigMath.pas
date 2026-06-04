{*******************************************************}
{                                                       }
{       Модуль длинной арифметики для тестового задания }
{                                                       }
{       Copyright (C) 2026 A.V. Drobotov                }
{                                                       }
{*******************************************************}

unit uBigMath;

interface

type
  TBigInt = class
  private
    FSign: Integer; // 1 для положительного, -1 для отрицательного, 0 для нуля
    FDigits: array of Integer; // Массив цифр по основанию 1 000 000 000

    procedure Normalize;
    function CompareAbs(const Other: TBigInt): Integer;
  public
    constructor Create; overload;
    constructor Create(const AValue: string); overload;
    destructor Destroy; override;

    // Основной метод: сложение с учетом знака (универсальная операция)
    procedure Add(const Other: TBigInt);
    
    // Преобразование в строку и из строки
    procedure FromString(const S: string);
    function ToString: string;

    // Чтение из файла значения и запись значения в файл
    procedure ReadFromFile(var f:TextFile);
    procedure WriteToFile(var f:TextFile);

    // Свойства только для чтения
    property Sign: Integer read FSign;
  end;

implementation

uses
  SysUtils;

const
  BASE = 1000000000;
  SIGN_MINUS = -1;
  SIGN_ZERO  = 0;
  SIGN_PLUS  = 1;
{ TBigInt }

{-------------------------------------------------------------------------------
  Конструктор : TBigInt.Create
  Автор       : А.В. Дроботов
  Дата        :  2026.06.04
  Входные параметры: нет
  Результат   :    Объект типа TBigInt
-------------------------------------------------------------------------------}
constructor TBigInt.Create;
begin
  inherited Create;
  FSign := SIGN_ZERO;
  SetLength(FDigits, 0);
end;

{-------------------------------------------------------------------------------
  Конструктор : TBigInt.Create
  Автор       : А.В. Дроботов
  Дата        : 2026.06.04
  Входные параметры: const AValue: string
  Результат   : Объект типа TBigInt
-------------------------------------------------------------------------------}
constructor TBigInt.Create(const AValue: string);
begin
  Create;
  FromString(AValue);
end;

{-------------------------------------------------------------------------------
  Деструктор  : TBigInt.Create
  Автор       : А.В. Дроботов
  Дата        : 2026.06.04
  Входные параметры: нет
  Результат   : Освобождение ресурсов объекта
-------------------------------------------------------------------------------}
destructor TBigInt.Destroy;
begin
  SetLength(FDigits, 0);
  inherited Destroy;
end;

{-------------------------------------------------------------------------------
  Процедура   : TBigInt.Normalize
  Автор       : А.В. Дроботов
  Дата        : 2026.06.04
  Входные параметры: Нет
  Результат   : Нормализация хранимого числа удалением незначащих разрядов
-------------------------------------------------------------------------------}
procedure TBigInt.Normalize;
var
  i: Integer;
begin
  i := Length(FDigits);
  // Удаляем ведущие нули в массиве разрядов
  while (i > 0) and (FDigits[i - 1] = 0) do
    Dec(i);

  SetLength(FDigits, i);

  // Если все разряды нулевые, число равно нулю (знак обнуляется)
  if i = 0 then
    FSign := SIGN_ZERO;
end;

{-------------------------------------------------------------------------------
  Функция     : TBigInt.CompareAbs
  Автор       : А.В. Дроботов
  Дата        : 2026.06.04
  Входные параметры: const Other: TBigInt - что сравниваем
  Результат   : 0 - равны, 1 - текущее значение, -1 - сравниваемое значение
-------------------------------------------------------------------------------}
function TBigInt.CompareAbs(const Other: TBigInt): Integer;
var
  lenSelf, lenOther, i: Integer;
begin
  lenSelf := Length(FDigits);
  lenOther := Length(Other.FDigits);

  // Сравнение по количеству значащих разрядов
  if lenSelf > lenOther then
    Result := 1
  else if lenSelf < lenOther then
    Result := -1
  else
  begin
    // Если длина одинакова, сравниваем поразрядно от старшего к младшему
    Result := 0;
    for i := lenSelf - 1 downto 0 do
    begin
      if FDigits[i] > Other.FDigits[i] then
      begin
        Result := 1;
        Exit;
      end
      else if FDigits[i] < Other.FDigits[i] then
      begin
        Result := -1;
        Exit;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Процедура   : TBigInt.Add
  Автор       : А.В. Дроботов
  Дата        : 2026.06.04
  Входные параметры: const Other: TBigInt - что прибавляем
  Результат   : сумма текущего и прибавляемого значений
-------------------------------------------------------------------------------}
procedure TBigInt.Add(const Other: TBigInt);
var
  i, carry, maxLen: Integer;
  OldDigits: array of Integer;
begin
  // Если прибавляем ноль, ничего не меняем
  if Other.FSign = SIGN_ZERO then
    Exit;

  // Если текущее число ноль, просто копируем другой операнд
  if FSign = SIGN_ZERO then
  begin
    FSign := Other.FSign;
    SetLength(FDigits, Length(Other.FDigits));
    for i := 0 to High(Other.FDigits) do
      FDigits[i] := Other.FDigits[i];
    Exit;
  end;

  // Случай 1: Знаки совпадают -> складываем модули, знак сохраняем
  if FSign = Other.FSign then
  begin
    maxLen := Length(FDigits);
    if Length(Other.FDigits) > maxLen then
      maxLen := Length(Other.FDigits);

    // Резервируем место под возможный перенос
    SetLength(FDigits, maxLen + 1);
    carry := 0;

    for i := 0 to maxLen - 1 do
    begin
      carry := carry + FDigits[i];
      if i < Length(Other.FDigits) then
        carry := carry + Other.FDigits[i];

      FDigits[i] := carry mod BASE;
      carry := carry div BASE;
    end;
    FDigits[maxLen] := carry;
    Normalize;
  end
  // Случай 2: Знаки разные -> вычитаем меньший модуль из большего
  else
  begin
    if CompareAbs(Other) < 0 then
    begin
      // |Other| > |Self|: результат будет иметь знак Other.
      // Сохраняем текущие данные Self во временный массив
      SetLength(OldDigits, Length(FDigits));
      for i := 0 to High(FDigits) do
        OldDigits[i] := FDigits[i];

      // Копируем данные Other в Self
      FSign := Other.FSign;
      SetLength(FDigits, Length(Other.FDigits));
      for i := 0 to High(Other.FDigits) do
        FDigits[i] := Other.FDigits[i];

      // Вычитаем сохраненный модуль из нового Self
      carry := 0;
      for i := 0 to Length(FDigits) - 1 do
      begin
        carry := FDigits[i] - carry;
        if i < Length(OldDigits) then
          carry := carry - OldDigits[i];

        if carry < 0 then
        begin
          FDigits[i] := carry + BASE;
          carry := 1;
        end
        else
        begin
          FDigits[i] := carry;
          carry := 0;
        end;
      end;
      Normalize;
    end
    else
    begin
      // |Self| >= |Other|: знак Self сохраняется
      carry := 0;
      for i := 0 to Length(FDigits) - 1 do
      begin
        carry := FDigits[i] - carry;
        if i < Length(Other.FDigits) then
          carry := carry - Other.FDigits[i];

        if carry < 0 then
        begin
          FDigits[i] := carry + BASE;
          carry := 1;
        end
        else
        begin
          FDigits[i] := carry;
          carry := 0;
        end;
      end;
      Normalize;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Процедура   : TBigInt.FromString
  Автор       : А.В. Дроботов
  Дата        : 2026.06.04
  Входные параметры: const S: string - строковое представление числа
  Результат   : массив внутреннего представления значения соответствующего строке
-------------------------------------------------------------------------------}
procedure TBigInt.FromString(const S: string);
var
  i, startIdx, len, digitCount: Integer;
  tempSign: Integer;
  chunk: string;
begin
  FSign := SIGN_ZERO;
  SetLength(FDigits, 0);

  len := Length(S);
  if len = 0 then
    Exit;

  startIdx := 1;
  tempSign := SIGN_PLUS;

  if S[1] = '-' then
  begin
    tempSign := SIGN_MINUS;
    Inc(startIdx);
  end
  else if S[1] = '+' then
  begin
    Inc(startIdx);
  end;

  // Читаем строку справа налево блоками по 9 символов
  i := len;
  while i >= startIdx do
  begin
    digitCount := i - startIdx + 1;
    if digitCount > 9 then
      digitCount := 9;

    chunk := Copy(S, i - digitCount + 1, digitCount);
    SetLength(FDigits, Length(FDigits) + 1);
    FDigits[High(FDigits)] := StrToInt(chunk);

    i := i - digitCount;
  end;

  FSign := tempSign;
  Normalize;
end;

{-------------------------------------------------------------------------------
  Функция     : TBigInt.ToString
  Автор       : А.В. Дроботов
  Дата        : 2026.06.04
  Входные параметры: Нет
  Результат   : строковое представление хранимого значения
-------------------------------------------------------------------------------}
function TBigInt.ToString: string;
var
  i: Integer;
  chunk: string;
begin
  if FSign = SIGN_ZERO then
  begin
    Result := '0';
    Exit;
  end;

  Result := '';
  if FSign = SIGN_MINUS then
    Result := '-';

  if Length(FDigits) > 0 then
  begin
    // Старший разряд выводится без ведущих нулей
    Result := Result + IntToStr(FDigits[High(FDigits)]);

    // Остальные разряды дополняются ведущими нулями до 9 символов
    for i := High(FDigits) - 1 downto 0 do
    begin
      chunk := IntToStr(FDigits[i]);
      while Length(chunk) < 9 do
        chunk := '0' + chunk;
      Result := Result + chunk;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  Процедура   : TBigInt.ReadFromFile
  Автор       : А.В. Дроботов
  Дата        : 2026.06.04
  Входные параметры: var f: TextFile
  Результат   : чтение большого числа из текстового файла
-------------------------------------------------------------------------------}
procedure TBigInt.ReadFromFile(var f: TextFile);
var
  chunk : string; // временный буфер для чтения числа
  ch    : Char;
begin

  chunk := ''; // для начала введено пустая строка
  // пропускаем начальные "пробелы"
  ch := ' ';
  while (ch in [' ', #9, #10, #13]) and not Eof(f) do
  begin
    read(f, ch);
  end;
  // читаем знак если он есть
  if (ch in [ '+', '-' ]) and not Eof(f) then
  begin
    chunk := chunk + ch;
    read(f, ch);
  end;
  // бежим по циферкам
  while (ch in ['0'..'9']) and not Eof(f) do
  begin
    chunk := chunk + ch;
    read(f, ch);
  end;
  if ch in ['0'..'9'] then
  begin
    chunk := chunk + ch;
  end;
  // окончание числа: пробелы или перевод строки
  // в противном случае ошибка записи числа
  if (not (ch in [' ', #9, #10, #13])) and not Eof(f) then
  begin
    Writeln('Ошибочное число!!!');
    Halt(1);
  end;
  // если последний символ из связки символов "перевод строки"
  // пропустим ещё один символ
  if (ch in [#10, #13]) and not Eof(f) then
  begin
    read(f, ch);
  end;

  // преобразуем из строки в большое число
  FromString(chunk);

end;

{-------------------------------------------------------------------------------
  Процедура   : TBigInt.WriteToFile
  Автор       : А.В. Дроботов
  Дата        : 2026.06.04
  Входные параметры: var f: TextFile
  Результат   : запись внутреннего представления большого числа в файл
-------------------------------------------------------------------------------}
procedure TBigInt.WriteToFile(var f: TextFile);
begin
  Write(f, ToString);
end;

end.
