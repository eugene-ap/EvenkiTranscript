{
   EvenkiProc.pas
   
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

unit EvenkiProc;

Interface
uses StrUtilsEv,Classes;
Const
  //sSonant = 'АаĀāИиӢӣЙйЕеĒēЁёОоŌōУуӮӯЫыЭэЮюЯя';
  //sNoSound = 'ьъ';
  //sDiacrit = '̄ ';
  //sDiacrit:string[2] = Chr(204)+Chr(132);
  //sConsonant ='БбВвГгДдЗзКкЛлМмНнҢңӇӈӉӊҤҥПпРрСсТтФфХхHhЦцЧчШшЩщ';
  //sFullAlphabet = sSonant+sConsonant+sNoSound;
  //sWordStop = ' ,.!?-‐‑‒–—―'; 
  sIotedStr = 'ИиӢӣИ'#204#132'и'#204#132'ЕеĒēЕ'#204#132'е'#204#132'ЁёЁ̄ё̄Ё'#204#132'ё'#204#132'ЮюЮ'#204#132'ю'#204#132'ЯяЯ'#204#132'я'#204#132;
  sStop = '˺';
  sIoteSymbol = 'ʲ';
  IMaxProcs = 18;
  sChSymbol: String = 'ʧ';
type

  TProc = procedure(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);

Procedure MainWork(var sInput:String;var sOutput:String;var tsDetail,tsStatIn,tsStatOut:TStrings);


var AllProcs:Array[1..IMaxProcs] of TProc;

implementation

Function IsIotedSon(sIn:String):Boolean;
var sTmp,sTmp1:String;
begin
  sTmp:=sIn;
  sTmp1:=StrInsertBegEnd(sIotedStr);
  IsIotedSon:=StrExistInStr(sTmp,sTmp1);
end;//IsIotedSon

Procedure Evenki_simple(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const IMaxSimpleChar = 23;
  AStrINp:array[1..IMaxSimpleChar] of String = (
    '^А$^а$',
	'^Ā$^ā$',
	'^И$^и$',
	'^Ӣ$^ӣ$^И'#204#132'$^и'#204#132'$',
	'^Ё$^ё$',
	'^Ё'#204#132'$^ё'#204#132'$',
	'^О$^о$',
	'^Ō$^ō$',
	'^У$^у$',
	'^Ӯ$^ӯ$',
	'^Ы$^ы$',
	'^Ы'#204#132'$^ы'#204#132'$',
	'^Ю$^ю$',
	'^Ю'#204#132'$^ю'#204#132'$',
	'^Я$^я$',
	'^Я'#204#132'$^я'#204#132'$',
	'^Б$^б$',
	'^В$^в$',
	'^З$^з$',
	'^Ф$^ф$',
	'^Ц$^ц$',
	'^Ш$^ш$',
	'^Щ$^щ$'
  );
  AStrOut:array[1..IMaxSimpleChar] of String = (
    'a',
	'aː',
	'i',
	'iː',
	'ⁱo',
	'ⁱoː',
	'o',
	'oː',
	'u',
	'uː',
	'ɨ',
	'ɨː',
	'ⁱu',
	'ⁱuː',
	'ⁱæ',
	'ⁱæː',
	'b',
	'β',
	'z',
	'f',
	's',
	'ʃ',
	'ʃʲ'
  );
var iTmp:Integer;
begin
  sOut:='';
  for iTmp:=1 to IMaxSimpleChar do begin
	  If StrExistInStr(tCtr.sCur,AStrInp[iTmp]) then begin
	    sOut:=AStrOut[iTmp];
	    // Exit;
	  end;
  end;
end;//Evenki_simple

Procedure Evenki_Proc_e(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp:String='^Е$^е$^Ē$^ē$';
var st,st1,st2,st3:String;
ist1:Integer;
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,sTmp) then begin
    //сначала проверка на слово ēха
    If (tCtr.iWordBeg=tCtr.iCurrent)  then begin
      //writeLn(tCtr.iWordBeg,tCtr.iCurrent);debug
      st:=sIn;ist1:=iIndx;
      GetNextSymbol(st,ist1,st1);//первая буква
      GetNextSymbol(st,ist1,st1);//вторая буква
      GetNextSymbol(st,ist1,st2);//третья буква
      GetNextSymbol(st,ist1,st3);//четвертая буква
      if (StrExistInStr(tCtr.sCur,'^Ē$^ē$')) and (StrExistInStr(st1,'^Х$^х$')) and (StrExistInStr(st2,'^А$^а$')) and ((Length(sIn)<ist1+Length(st3)) or ((Length(st3)>0) and (Pos(st3,sFullAlphabet)=0)))
        then begin // слово еха
          sOut:='eː';
        end else begin
          sOut:='ɛː';
        end;
    end//e-первая буква
    else begin
      sOut:='eː';
    end;//не первая буква
    //writeLn(sOut); дебаг
  end;
end;//Evenki_Proc_a

Procedure Evenki_Proc_eh(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const 
  sTmpEh = '^Э$^э$';
  sTmpEh1 = '^Э̄$^э̄$';
  sTmp = sTmpEh+sTmpEh1;
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,sTmp) then begin
    //если конец слова - то
    if not (StrSimpleExistInStr(tCtr.sNext,sFullAlphabet)) or (Length(sIn)<tCtr.iCurrent+Length(tCtr.SCur))
      then begin
        sOut:='ⁱæ';
      end else begin
        If StrExistInStr(tCtr.sCur,sTmpEh)
          then begin
            sOut:='ɜ';
          end else begin
            sOut:='a';
          end;
      end;
    If StrExistInStr(tCtr.sCur,sTmpEh1) then begin
      sOut:=sOut+'ː';
    end;
  end;
end;//Evenki_Proc_eh

Procedure Evenki_Proc_g(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Гг';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp)) then begin
    If 
      not StrSimpleExistInStr(tCtr.sNext,sFullAlphabet) //конец слова
      then begin // конец слова - конец
        If (tCtr.sPrev='а') and (tCtr.iSonCnt>1)
          then begin
            sOut:='x';
          end else begin
            If tCtr.iSonCnt<2
              then begin
                sOut:='k';
              end else begin
                sOut:='ɡ';
              end;
          end;
      end else begin //не конец слова
        If StrExistInStr(tCtr.sPrev,StrInsertBegEnd(sSonant))
          and StrExistInStr(tCtr.sNext,StrInsertBegEnd(sSonant))
          then begin // между гласными
            sOut:='ɣ';
          end else begin // не между гласными
            sOut:='ɡ';
          end;
      end;//не конец слова - конец
  end;//обнаружен Г
end;//Evenki_Proc_g

Procedure Evenki_Proc_punct(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
begin
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sWordStop))
    then begin
      sOut:=tCtr.sCur;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_punct

Procedure Evenki_Proc_d(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Дд';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:='d';
      If IsIotedSon(tCtr.sNext) then begin sOut:=sOut+sIoteSymbol end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_d

Procedure Evenki_Proc_k(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Кк';
  sIoTmp = 'Э'#204#132'э'#204#132'ИиӢӣИ'#204#132'и'#204#132'ЕеĒēЕ'#204#132'е'#204#132;
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:='k';
      If StrExistInStr(tCtr.sNext,StrInsertBegEnd(sIoTmp)) then begin sOut:=sOut+sIoteSymbol end;
      If (iIndx<Length(sIn))
         and not StrExistInStr(tCtr.sNext,StrInsertBegEnd(sFullAlphabet))
         then begin
           sOut:=sOut+sStop;
         end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_k

Procedure Evenki_Proc_l(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Лл';
  sIoTmp = 'Э'#204#132'э'#204#132;
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:='l';
      If StrExistInStr(tCtr.sNext,StrInsertBegEnd(sIoTmp)) then begin sOut:=sOut+sIoteSymbol end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_l

Procedure Evenki_Proc_m(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Мм';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:='m';
      If IsIotedSon(tCtr.sNext) then begin sOut:=sOut+sIoteSymbol end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_m

Procedure Evenki_Proc_n(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Нн';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:='n';
      If IsIotedSon(tCtr.sNext) then begin sOut:=sOut+sIoteSymbol end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_n

Procedure Evenki_Proc_ng(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
var sTmp:String;
begin
  sTmp:='^Нг$^нг$'+StrInsertBegEnd('ҢңӇӈӉӊҤҥ');
  sOut:='';
  If StrExistInStr(tCtr.sCur,sTmp)
    then begin
      sOut:='ŋ';
      If IsIotedSon(tCtr.sNext) then begin sOut:=sOut+sIoteSymbol end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_ng

Procedure Evenki_Proc_p(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Пп';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:='p';
      //If StrExistInStr(tCtr.sNext,StrInsertBegEnd(sIoTmp)) then begin sOut:=sOut+sIoteSymbol end; Здесь йотировать не надо
      If (iIndx<Length(sIn))
         and not StrExistInStr(tCtr.sNext,StrInsertBegEnd(sFullAlphabet))
         then begin
           sOut:=sOut+sStop;
         end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_p

Procedure Evenki_Proc_t(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Тт';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:='t';
      //If StrExistInStr(tCtr.sNext,StrInsertBegEnd(sIoTmp)) then begin sOut:=sOut+sIoteSymbol end; Здесь йотировать не надо
      If (iIndx<Length(sIn))
         and not StrExistInStr(tCtr.sNext,StrInsertBegEnd(sFullAlphabet))
         then begin
           sOut:=sOut+sStop;
         end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_t

Procedure Evenki_Proc_r(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Рр';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:='r';
      If IsIotedSon(tCtr.sNext) then begin sOut:=sOut+sIoteSymbol end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_r

Procedure Evenki_Proc_s(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Сс';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:='s';
      If IsIotedSon(tCtr.sNext) then begin sOut:=sOut+sIoteSymbol end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_s

Procedure Evenki_Proc_h(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'ХхHh';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp)) then begin
	If StrExistInStr(tCtr.sPrev,StrInsertBegEnd(sSonant))
	  and StrExistInStr(tCtr.sNext,StrInsertBegEnd(sSonant))
	  then begin // между гласными
		sOut:='ʕ';
	  end else begin // не между гласными
		sOut:='ħ';
	  end;
  end;//обнаружен Х
end;//Evenki_Proc_h

Procedure Evenki_Proc_ch(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'Чч';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:=sChSymbol;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_ch

Procedure Evenki_Proc_softsign(var sIn,sOut:String;const iIndx:Integer;const tCtr:TControlStruct);
const sTmp = 'ь';
begin
  sOut:='';
  If StrExistInStr(tCtr.sCur,StrInsertBegEnd(sTmp))
    then begin
      sOut:='';
      If StrExistInStr(tCtr.sPrev,StrInsertBegEnd(sConsonant)) then begin sOut:=sOut+'ʲ';end;
      If StrExistInStr(tCtr.sNext,StrInsertBegEnd(sSonant))  then begin sOut:=sOut+'j'; end;
    end else begin
      sOut:='';
    end;
end;//Evenki_Proc_softsign

Procedure WriteStat(const tStIn:TStatType;var tsStat:TStrings);
var 
  i,Total:Integer;
  Perc:Real;
begin
  with tStIn do begin
    Total:=0;
    for i:=1 to iMax do begin
      Total:=Total+ACntArr[i];
    end;//for
    for i:=1 to iMax do begin
      Perc:=ACntArr[i]/Total*100.0;
      tsStat.Append('#'+i2str(i)+':'+AStrArr[i]+':'+i2str(ACntArr[i])+':'+r2str(Perc)+'%');
      //WriteLn('#',i2str(i),':',AStrArr[i],':',ACntArr[i],':',r2str(Perc),'%');
    end;//for
  end;//with
end;//WriteStat

//Detalization, StatIn, StatOut
Procedure MainWork(var sInput:String;var sOutput:String;var tsDetail,tsStatIn,tsStatOut:TStrings);
var 
  tCtrl:TControlStruct;
  iInd:Integer;
  sTmp,sTmp1,sTmp2:String;
  iProc,i1:Integer;
  tIn,tOut:TStatType;
begin
  InitStruc(tCtrl);
  InitStat(tIn);
  InitStat(tOut);
  //Writeln('begin');
  tsDetail.Clear;
  tsStatIn.Clear;
  tsStatOut.Clear;
  //Writeln('end');
  iInd:=1;
  sOutput:='';
  sTmp:='';
  sTmp1:='';
  UpdateStruc(tCtrl,sInput,iInd);
  //writeln('len=',Length(sInput));
  //GetNextSymbol(sInput,iInd,sTmp);
  repeat
    sTmp1:='';
    for iProc:=1 to IMaxProcs do begin
      AllProcs[iProc](sInput,sTmp,iInd,tCtrl);
      If Length(sTmp)>0 then begin sOutput:=sOutput+sTmp;sTmp1:=sTmp; end;
    end;
    if length(sTmp1)=0 then begin sTmp:='#';sOutput:=sOutput+sTmp;sTmp1:=sTmp;end;
    UpdStat(tIn,tCtrl.sCur);
    UpdStat(tOut,sTmp1);
    sTmp2:=i2str(iInd)+'|('+tCtrl.sCur+')|'+sTmp+'/'+sTmp1+'/';
    //write(iInd:1,'|(',tCtrl.sCur,')|',sTmp,'/',sTmp1,'/');
    for i1:=1 to Length(tCtrl.sCur) do sTmp2:=sTmp2+'|'+i2str(Ord(tCtrl.sCur[i1])); //write('|',Ord(tCtrl.sCur[i1]));
    //write(tCtrl.iWordBeg,':',tCtrl.iCurrent);
    tsDetail.Add(sTmp2);
    //WriteLn(sTmp2);
    GetNextSymbol(sInput,iInd,sTmp);
    UpdateStruc(tCtrl,sInput,iInd);
    sTmp:='';
  until iInd>Length(sInput);
  //writeln('Input token statistic');
  WriteStat(tIn,tsStatIn);
  //writeln('Output token statistic');
  WriteStat(tOut,tsStatOut);
end;//MainWork


begin
  sChSymbol:='ʨ';
  AllProcs[1]:=@Evenki_simple;
  AllProcs[2]:=@Evenki_Proc_e;
  AllProcs[3]:=@Evenki_Proc_eh;
  AllProcs[4]:=@Evenki_Proc_g;
  AllProcs[5]:=@Evenki_Proc_punct;
  AllProcs[6]:=@Evenki_Proc_d;
  AllProcs[7]:=@Evenki_Proc_k;
  AllProcs[8]:=@Evenki_Proc_l;
  AllProcs[9]:=@Evenki_Proc_m;
  AllProcs[10]:=@Evenki_Proc_n;
  AllProcs[11]:=@Evenki_Proc_ng;
  AllProcs[12]:=@Evenki_Proc_p;
  AllProcs[13]:=@Evenki_Proc_t;
  AllProcs[14]:=@Evenki_Proc_r;
  AllProcs[15]:=@Evenki_Proc_s;
  AllProcs[16]:=@Evenki_Proc_h;
  AllProcs[17]:=@Evenki_Proc_ch;
  AllProcs[18]:=@Evenki_Proc_softsign;
end.
