program BigAddApp;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  uBigMath in 'uBigMath.pas';

var
  F : TextFile;
  N1, N2 : TBigInt;
begin
  try
    // создаем объекты - большие числа
    N1 := TBigInt.Create;
    N2 := TBigInt.Create;
    try

      // открываем файл на чтение
      Assign(f, 'numbers.txt');
      Reset(f);

      try

        //  Читаем числа
        N1.ReadFromFile(f);
        N2.ReadFromFile(f);

      finally
        //  Закрываем файл на чтение
        CloseFile(f);
      end;

      //  Складываем два числа
      N1.Add(N2);

      //  открываем файл на запись
      Append(f);
      try

        //  Добавляем итог в файл
        Writeln(f);
        N1.WriteToFile(f);

        Flush(f);

      finally
        //  закрываем файл на запись
        CloseFile(f);
      end;

    finally
      //  Освобождаем память
      N1.Free;
      N2.Free;
    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
