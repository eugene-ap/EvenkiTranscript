{
   StrUtils.pas
   
   Copyright 2023 user <eugene_ap@mail.ru>
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
   
   
}

//йотированные гласные - еёюя

unit StrUtilsEv;

Interface

Const
  sSonant = 'АаĀāИиӢӣЙйЕеĒēЁёОоŌōУуӮӯЫыЭэЭ̄э̄ЮюЮ'#204#132'ю'#204#132'ЯяЯ'#204#132'я'#204#132;
  //sNoSound = 'ьъ';
  sNoSound = 'ь';
  //sDiacrit = '̄nf ';
  sDiacrit = Chr(204)+Chr(132);
  sConsonant ='БбВвГгДдЗзКкЛлМмНнҢңӇӈӉӊҤҥПпРрСсТтФфХхHhЦцЧчШшЩщ';
  sFullAlphabet = sSonant+sConsonant+sNoSound+sDiacrit;
  sWordStop = ' ,.!?-‐‑‒–—―'; 
  iMaxStat = 200;// максимальное количество токенов

Type
  TControlStruct = record
	iWordBeg:Integer;
	iSonCnt: Integer;
	iCurrent: Integer;
	sPrev: String;
	sCur: String;
	sNext: String;
	iWordCnt: Integer;
	iCharCnt:Integer;
  end;
  
  TStatType = record
    iMax: Integer;
    AStrArr: Array[1..iMaxStat] of String;
    ACntArr: Array[1..iMaxStat] of Integer;
  end;

Function StrInsertBegEnd(sInp:String):String;
Function StrExistInStr(const sInp:String; const StrFindIn:String):Boolean;
Function StrSimpleExistInStr(const sInp:String; const StrFindIn:String):Boolean;
Procedure GetNextSymbol(var sIn:String;var iIndex:Integer;var sOut:String);
Function GetNextSymbol2(const sIn:String; const iIndex:Integer):String;
Procedure UpdateStruc(var TCtrStr: TControlStruct;const sIn: String; const iIndex:Integer);
Procedure InitStruc(var TCtrStr: TControlStruct);
Procedure InitStat(var tSt:TStatType);
Procedure UpdStat(var tSt:TStatType;const sIn:String);
Function i2str(i:Integer):String;
Function r2str(r:Real):String;


implementation

// вставляет ^ и $ между буквами в строке
Function StrInsertBegEnd(sInp:String):String;
var 
  sTmp:String;
  i: Integer;
begin
  If Length(sInp)>0 then begin sTmp:='^'+sInp[1]; end else begin sTmp:='';end;
  For i:=2 to Length(sInp) do begin
    case (ord(sInp[i]) and $c0) of
      $40,0 : sTmp:=sTmp+'$^'+sInp[i];
      $80 : sTmp:=sTmp+sInp[i];
      $c0 : If (i+2<Length(sInp)) and (sInp[i]+sInp[i+1]=sDiacrit)
        then begin// если дальше диакритик, продолжаем
          sTmp:=sTmp+sInp[i];
        end else begin //начался новый символ UTF8 и не диакритик, заканчиваем предыдущий
          sTmp:=sTmp+'$^'+sInp[i];
        end;
      else sTmp:=sTmp+'$^'+sInp[i];
    end;
  end;//for
  StrInsertBegEnd:=sTmp+'$';
end;//StrInsertBegEnd

Function StrExistInStr(const sInp:String; const StrFindIn:String):Boolean;
begin
  StrExistInStr:=Pos('^'+sInp+'$',StrFindIn) <> 0;
end;

Function StrSimpleExistInStr(const sInp:String; const StrFindIn:String):Boolean;
begin
  StrSimpleExistInStr:=Pos(sInp,StrFindIn) <> 0;
end;

Procedure GetNextSymbol(var sIn:String;var iIndex:Integer;var sOut:String);
const sG:string = 'г';
var iTmp:Integer;bTmp:Boolean;
begin
  sOut:='';
  if iIndex <= Length(sIn) then begin
	  //c:=sIn[iIndex];
	  sOut:=sOut+sIn[iIndex];
	  iIndex:=iIndex+1;
	  while (iIndex<=Length(sIn)) And ((Byte(sIn[iIndex]) and $c0)=$80) do begin
	    sOut:=sOut+sIn[iIndex];
	    iIndex:=iIndex+1;
	  end;
  end;//if
  //добавляем диакритик, если есть
  If iIndex+Length(sDiacrit)-1<=Length(sIn) then begin
    bTmp:=True;
    for iTmp:=1 to Length(sDiacrit) do begin bTmp:=bTmp and (sIn[iIndex+iTmp-1]=sDiacrit[iTmp]);end;
    If bTmp then begin
      sOut:=sOut+sDiacrit;
      iIndex:=iIndex+Length(sDiacrit);
    end else begin
      If ((sOut='Н') or (sOut='н'))
        and ((sIn[iIndex]+sIn[iIndex+1])=sG)
        then begin
          sOut:=sOut+sIn[iIndex]+sIn[iIndex+1];
          iIndex:=iIndex+2;
        end;
    end;
  end;
end; //GetNextSymbol

Function GetNextSymbol2(const sIn:String; const iIndex:Integer):String;
var
  sInTmp, sOutTmp:String;
  iIndexTmp:Integer;
begin
  sInTmp:=sIn;
  iIndexTmp:=iIndex;
  GetNextSymbol(sInTmp,iIndexTmp,sOutTmp);
  if iIndexTmp<=Length(sInTmp)
    Then GetNextSymbol(sInTmp,iIndexTmp,sOutTmp)
    else sOutTmp:='';
  GetNextSymbol2:=sOutTmp;
end; // GetNextSymbol2

Procedure UpdateStruc(var TCtrStr: TControlStruct;const sIn: String; const iIndex:Integer);
var 
  iTmp: Integer;
  sTmpIn,sTmpOut: String;
begin
  sTmpIn:=sIn;
  iTmp:=iIndex;
  GetNextSymbol(sTmpIn,iTmp,sTmpOut);
  if iTmp>iIndex then begin //если успешно, обновляем структуру
    // кейс 1 - не символ алфавита - соответственно слово закончилось, надо полностью обнулить структуру
    If not StrSimpleExistInStr(sTmpOut,sFullAlphabet) then begin
      with TCtrStr do begin
        iWordBeg:=-iIndex;
        iSonCnt:=0;
        iCurrent:=iIndex;
        sPrev:='';
        sCur:=sTmpOut;
        iWordCnt:=iWordCnt+1;
        sNext:=GetNextSymbol2(sTmpIn,iIndex);
      end;
    end //обнуление структуры
    else begin
      if TCtrStr.iWordBeg<=0 then begin //начало слова
        with TCtrStr do begin
          iWordBeg:=iIndex;
          iSonCnt:=Integer(StrSimpleExistInStr(sTmpOut,sSonant));
          iCurrent:=iIndex;
          sPrev:='';
          sCur:=sTmpOut;
          sNext:=GetNextSymbol2(sTmpIn,iIndex);
        end;
      end//начало слова
      else begin // середина-конец слова
        with TCtrStr do begin
          // iWordBeg:=iIndex; - не меняем
          iSonCnt+=Integer(StrSimpleExistInStr(sTmpOut,sSonant)); // добавляем, если сонорный
          iCurrent:=iIndex;
          sPrev:=sCur;//сдвигаем текущий в предыдущий
          sCur:=sTmpOut;//текущему присваиваем текущий
          sNext:=GetNextSymbol2(sTmpIn,iIndex);
        end;
      end;// середина-конец слова
    end;//алфавитный символ
    //здесь надо дописать?
  end;//if
end;//UpdateStruc

Procedure InitStruc(var TCtrStr: TControlStruct);
begin
  with TCtrStr do begin
	iWordBeg:=0;
	iSonCnt:=0;
	iCurrent:=0;
	sPrev:='';
	sCur:='';
	sNext:='';
	iWordCnt:=0;
	iCharCnt:=0;
  end;
end;//InitStruc

Procedure InitStat(var tSt:TStatType);
var i:Integer;
begin
  with tSt do begin
    iMax:=0;
    For i:=1 to iMaxStat do begin
      AStrArr[i]:='';
      ACntArr[i]:=0;
    end;
  end;//with
end;//InitStat

Procedure UpdStat(var tSt:TStatType;const sIn:String);
var 
  i:Integer;
  bTmp:Boolean;
begin
  bTmp:=True;
  with tSt do begin
    For i:=1 to iMax do begin
      If sIn=AStrArr[i] then begin
        ACntArr[i]:=ACntArr[i]+1;
        bTmp:=False;
      end;//if
    end;//for
    If bTmp And (iMax<iMaxStat) then begin
      iMax:=iMax+1;
      AStrArr[iMax]:=sIn;
      ACntArr[iMax]:=1;
    end;//add new symbol
    If iMax=iMaxStat then begin writeln('warning!!!!! no room space for statistic!!!!');end;
  end;
end;//UpdStat

Function i2str(i:Integer):String;
var s:String;
begin
  Str(i:1,s);
  i2str:=s;
end;//i2str
Function r2str(r:Real):String;
var s:String;
begin
  Str(r:5:3,s);
  r2str:=s;
end;//r2str

end.
